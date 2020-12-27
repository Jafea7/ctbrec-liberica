#!/bin/bash
# caps.sh ${absoluteFilePath} [true]

# Requirements: ffmpeg

fast=$2                               # if arg2 exists use script over internal
dir=`echo "${1%/*}"`                  # get path
file=`echo "${1##*/}"`                # get file
output=`echo "${file%.*}"`            # remove extension from file name
pushd "$dir" >/dev/null 2>&1          # change to path
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file") # get video duration in seconds
size="$(du -m "$file" | cut -f1)"     # get file size in MB

if [[ $size -gt 250 ]] || [[ ! -z $fast ]]; then                # if file size greater than 250MB or arg2 exists do contact sheet new way
  for i in {01..56}                   # loop 56 times
  do
    interval=`echo "scale=0; (($i-0.5) * $duration/56)/1" | bc` # calculate position of each frame capture
    name=`echo "image$i.png"`         # image capture name
    `ffmpeg -v quiet -skip_frame nokey -ss $interval -i "$file" -vf select="eq(pict_type\,I)" -vframes 1 "$name"` # skip to calculated position and grab next key frame
  done
  ffmpeg -v quiet -y -i image%02d.png -vf "scale=317:-1,tile=8x7:color=0x333333:margin=2:padding=2,scale=2560:-1" -qscale:v 3 "$output.jpg" # create contact sheet from images -> file.jpg
  rm -f image*.png                    # remove images
else
  # size less than 250MB create contact sheet the old way
  ffmpeg -v quiet -y -skip_frame nokey -i "$file" -vf "fps=1/($duration/56),scale=317:-1,tile=8x7:color=0x333333:margin=2:padding=2,scale=2560:-1" -an -vsync 0 -qscale:v 3 -frames:v 1 "$output.jpg"
fi
