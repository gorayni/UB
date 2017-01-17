#!/bin/bash

# Returns the number of frames from a video
function number_of_frames {
	video_filepath="$1"
    echo `ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$video_filepath"`
}

# Returns the number of left padding zeros wrt. the number of frames
function padding_zeros {
	video_filepath="$1"
	num_frames=`number_of_frames "$video_filepath"`
	echo "${#num_frames}"
}

# Returns the number of frames per second from a video
function frames_per_second {
	video_filepath="$1"
    echo `ffmpeg -i "$video_filepath" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`
}

# Extracts the frames from a video adding the precise number of padding zeros
function extract_frames {
    video_filepath="$1"
    
    if [ -z "$2" ]; then
        output_dirpath=`pwd`
    else
        output_dirpath="$2"
    fi

    if [ -z "$3" ]; then
        num_frames=`number_of_frames $video_filepath`
        num_padding_zeros="${#num_frames}"
    else
        num_padding_zeros="$3"
    fi

    fps=`frames_per_second $video_filepath`
    video_filename="${video_filepath%.*}"
    video_basename=`basename "${video_filename}"`
           
    mkdir -p "$output_dirpath"/"$video_basename"    

    ffmpeg -i $video_filepath -y -an -qscale 0 -r $fps/1 "$output_dirpath"/"$video_basename"/%0"$num_padding_zeros"d.jpg >&2

    echo $num_padding_zeros
}

# Removes the frames by range
function rm_frames {	
	basename="$1"
	file_extension="$2"
	start_frame="$3"
	end_frame="$4"
	num_padding_zeros="$5"

    for i in $(seq -f "%0""$num_padding_zeros""g" "$start_frame" "$end_frame")
    do
        rm "$basename""$i"."$file_extension"
    done
}

# Removes the frames by range
function rm_frames {
	basename="$1"
	file_extension="$2"
	start_frame="$3"
	end_frame="$4"
	num_padding_zeros="$5"

    for i in $(seq -f "%0""$num_padding_zeros""g" "$start_frame" "$end_frame")
    do
        rm "$basename""$i"."$file_extension"
    done
}
