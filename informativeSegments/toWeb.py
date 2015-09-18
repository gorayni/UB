import collections
import csv
import os
import shutil
import sys

from os.path import join, abspath, dirname, isfile
from jinja2 import Environment, FileSystemLoader
from wand.image import Image
from wand.display import display

 
PATH = dirname(abspath(__file__))
TEMPLATE_ENVIRONMENT = Environment(autoescape=False,loader=FileSystemLoader(PATH),trim_blocks=False)
WEB_DIRPATH=join(PATH,'web')
WEB_DATASETS_DIRPATH=join(WEB_DIRPATH,'datasets')
IMAGES_DATASET_DIRPATH='/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Narrative/imageSets'

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    WHITE = '\033[97m'

def read_segments(csv_filepath):	
	segments_by_datasets = collections.OrderedDict()
	with open(csv_filepath, 'r') as informative_segments_file:            
	    reader = csv.reader(informative_segments_file)
	    
	    for row in reader:
	        dataset = row[0]
	        new_segment_id = int(row[1])
	        frame_filename = row[3]
	        
	        if not dataset in segments_by_datasets:
	            segments_by_datasets[dataset] = collections.OrderedDict()
	        
	        if not new_segment_id in segments_by_datasets[dataset]:
	            segments_by_datasets[dataset][new_segment_id] = []

	        segments_by_datasets[dataset][new_segment_id].append(frame_filename)
	return segments_by_datasets


def render(datasets, selected_dataset, frames_by_segments):
	return TEMPLATE_ENVIRONMENT.get_template('template.html').render(selected_dataset=dataset, datasets=datasets, frames_by_segments=frames_by_segments)

def make_html(datasets, selected_dataset, frames_by_segments):
	output_html=render(datasets, selected_dataset, frames_by_segments)

	output_filepath=os.path.join(WEB_DIRPATH,dataset+'.html')
	with open(output_filepath, 'w') as outfile:
		outfile.write(output_html)


if len(sys.argv) < 2:	
	print bcolors.FAIL + "No argument supplied"
	sys.exit()

CSV_FILEPATH = sys.argv[1]

segments_by_datasets = read_segments(CSV_FILEPATH)

datasets=segments_by_datasets.keys()
for dataset, frames_by_segments in segments_by_datasets.items():

	web_dataset_dirpath=join(WEB_DATASETS_DIRPATH,dataset)
	if not os.path.exists(web_dataset_dirpath):
		os.makedirs(web_dataset_dirpath)

	# copy video file created previously
	video_filename = dataset+'.mp4'
	if not isfile(join(web_dataset_dirpath, video_filename)):
		if isfile(video_filename):
			shutil.move(video_filename, web_dataset_dirpath)
		else:
			print bcolors.WARNING + "WARNING: Not such video file named " + video_filename

	# make thumbnail images
	images_dataset_dirpath = join(IMAGES_DATASET_DIRPATH, dataset)
	for segment_id, frames in frames_by_segments.items():
		for frame in frames:						
			dst_filepath = join(web_dataset_dirpath, frame) 
			if not isfile(dst_filepath):
				src_filepath = join(images_dataset_dirpath, frame)
				with Image(filename=src_filepath) as img:
					img.compression_quality = 50
					img.resize(250, 250)
					img.save(filename=dst_filepath)

	make_html(datasets, dataset, frames_by_segments)