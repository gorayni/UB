#!/bin/bash
#
# Large Image Datasets Handler Library
# Written by Alejandro Cartas.
#

LIDHL_VERSION=0.1

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

# Massive files move
function mass_mv {
	filename_regex="$1"
	new_directory="$2"
	find . -type f -name "$filename_regex" | xargs -I '{}' mv {} "$new_directory"
}

# Massive list files
function mass_ls {
	ls_args="$1";
	filename_regex="$2";
	find . -type f -name "$filename_regex" | xargs ls "$ls_args";
}

# Massive rm files
function mass_rm {
    ls_args="$1";
    filename_regex="$2";
    find . -type f -name "$filename_regex" | xargs rm "$ls_args";
}

# Returns the number of bytes of the files provided by the arg
function number_of_bytes { wc -c $1 | tail -1 | sed -e 's/^[ \t]*//' | cut -d ' ' -f 1; }

# Returns the size in bytes of a download 
function download_filesize { curl --head $1 2> /dev/null | grep Content-Length | cut -d ' ' -f 2 | tr -d $'\r'; }

# Downloads a large file in chunks of max. 4 GB
function chunkie_download {
    FOUR_GB=4294967296

    URL=$1
    filename=$2
    if [ -z "$3" ]; then
        chunk_size=$FOUR_GB
    else
        chunk_size="$3"
    fi

    TOTAL_FILESIZE=`download_filesize $URL`

    num_files=`ls -1 "$filename".part* 2> /dev/null | wc -l | tail -1 | sed -e 's/^[ \t]*//'`
    if [ "$num_files" -gt 0 ]; then	   
        num_downloaded_bytes=`number_of_bytes "$filename".part"*"`

        part_number=`ls -1 "$filename".part* | sed -e "s/""$filename"".part//g" | sort -nr | head -1`
        part_number=`expr $part_number + 1`

    elif [ "$chunk_size" -lt "$TOTAL_FILESIZE" ]; then
    	num_downloaded_bytes=0
        part_number=0
    else
        curl -o  "$filename" "$URL"
        return;
    fi

    if [ "$num_downloaded_bytes" -lt "$TOTAL_FILESIZE" ]; then	
        upper_download_bound=`expr $num_downloaded_bytes + $chunk_size`
        while [ $upper_download_bound -lt $TOTAL_FILESIZE ]; do
            curl --range "$num_downloaded_bytes"-"$upper_download_bound" -o "$filename".part"$part_number" "$URL"

            num_downloaded_bytes=`number_of_bytes "$filename".part"*"`
            upper_download_bound=`expr $num_downloaded_bytes + $chunk_size`
            part_number=`expr $part_number + 1`
        done
        curl --range "$num_downloaded_bytes"- -o "$filename".part"$part_number" "$URL"
    fi
}

function join_chunks {
    filename=$1
    echo $filename
    ls -1 "$filename".part* | sed 's/\([0-9]\)/;\1/' | sort -n -t\; -k2,2 | tr -d ';'
    cat `ls -1 "$filename".part* | sed 's/\([0-9]\)/;\1/' | sort -n -t\; -k2,2 | tr -d ';'` > $filename;
}
