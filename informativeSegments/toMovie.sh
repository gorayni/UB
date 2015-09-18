#!/bin/bash

if [ -z "$1" ]
  then
    >&2 echo "No argument supplied"
    exit 1
fi

IMAGES_DATASET_DIRPATH='/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Narrative/imageSets' 
CSV_FILENAME=$1 

function extract_num_of_frames {
	echo `awk -F "\"*,\"*" '{print $1}' $CSV_FILENAME | grep $1 | wc -l | sed 's/[^0-9]*//g'`
}

function num_of_digits {	
	echo -n $1 | wc -c | sed 's/[^0-9]*//g'
}

images_datasets=($(awk -F "\"*,\"*" '{print $1}' $CSV_FILENAME | uniq))

for dataset in "${images_datasets[@]}"
do
	echo $dataset

	temp_dir=`mktemp -d /tmp/image_dataset_$dataset.XXXXXXXX`
			
	num_of_frames=`extract_num_of_frames $dataset`
	num_of_padding_zeros=`num_of_digits $num_of_frames`

	frame_filenames=($(awk -F , '$1 == "'$dataset'" { print $4 }' $CSV_FILENAME))

	i=0
	for frame_filename in "${frame_filenames[@]}"
	do		
		image_index=`printf %0"$num_of_padding_zeros"d $i`
		extension="${frame_filename##*.}"

		frame_filepath=$IMAGES_DATASET_DIRPATH/$dataset/$frame_filename

		ln -s $frame_filepath $temp_dir/$image_index.$extension

		let i+=1
	done

	ffmpeg -pattern_type glob -framerate 0.75 -i "$temp_dir/"'*.'"$extension" -y -vcodec libx264 -vf "scale=trunc(iw/8)*2:trunc(ih/8)*2" -pix_fmt yuv420p "$dataset.mp4"
done