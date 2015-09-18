import csv
import collections
import pandas as pd

from collections import defaultdict
from intervaltree import Interval, IntervalTree
from os import listdir
from os.path import basename, isfile, join, splitext
from pandas import ExcelFile

def extract_informative_frames(labels_filepath):
    informative_frames = []
    with open(labels_filepath, 'rb') as f:        
        for row in csv.reader(f, delimiter=' '):
            if row[1] == '1':
                informative_frames.append(row[0])    
    return informative_frames

def extract_segment_invervals(xls_filepath):
    dataFrame = pd.read_excel(xls_filepath,parse_cols='B',skiprows=1)
    frames_column_name = dataFrame.columns[0]

    segment_intervals = IntervalTree()
    segment_id = 0
    for frames in dataFrame[frames_column_name]:
        interval = map(int,frames.strip().split(' '))
        segment_intervals[interval[0]:interval[1]] = segment_id
        segment_id += 1
    return segment_intervals

def intersect_segments_frames(segment_intervals, informative_frames):    
    frames_by_segment_id = defaultdict(list)
    unique_segments_ids = set()    
    
    for informative_frame in informative_frames:
        frame_filename = basename(informative_frame)
        frame_id = int(splitext(frame_filename)[0])

        if not segment_intervals.overlaps(frame_id):
            continue
        
        segment_interval ,= segment_intervals[frame_id]
        segment_id = segment_interval.data
        
        unique_segments_ids.add(segment_id)
        frames_by_segment_id[segment_id].append(frame_filename)
    return frames_by_segment_id, unique_segments_ids

def reference_frames_by_segments(images_dataset):
    labels_filepath = join(INFORMATIVE_IMAGES_PATH, images_dataset,'labels.txt')
    frames = extract_informative_frames(labels_filepath) 
    
    xls_filepath = join(GROUND_TRUTH_PATH, 'GT_' + images_dataset + '.xls')    
    segment_intervals = extract_segment_invervals(xls_filepath)

    frames_by_old_segment_id, unique_segments_ids = intersect_segments_frames(segment_intervals, frames)
        
    # Renumbering segment ids
    new_ids_by_old_id = dict()    
    new_segment_id = 0
    for old_segments_id in unique_segments_ids:
        new_ids_by_old_id[old_segments_id] = new_segment_id
        new_segment_id += 1
        
    frames_by_segment_ids = collections.OrderedDict()
    for old_id, frames in frames_by_old_segment_id.iteritems():
        new_id = new_ids_by_old_id[old_id]
        frames_by_segment_ids[(new_id,old_id)] = frames
    return frames_by_segment_ids
    
    
GROUND_TRUTH_PATH = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Narrative/GT'
INFORMATIVE_IMAGES_PATH = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Anotacions_Rememory'

images_datasets = ['Estefania1','Estefania2','MAngeles1','MAngeles2',\
                   'MAngeles3','Marc1','Mariella','Maya1','Petia1','Petia2']

for images_dataset in images_datasets:    
    frames_by_segment_ids = reference_frames_by_segments(images_dataset)
    
    # Printing informative frames per segment id
    for segment_ids, frames in frames_by_segment_ids.items():
        for frame in frames:            
            print images_dataset + ',' + str(segment_ids[0])+ ',' + str(segment_ids[1]) + ',' + frame