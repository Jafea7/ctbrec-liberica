#!/bin/bash
# caps.sh ${absoluteFilePath}

# Requirements: ffmpeg

dir=`echo "${1%/*}"`                  # get path
file=`echo "${1##*/}"`                # get file
output=`echo "${file%.*}"`            # remove extension from file name
pushd "$dir" >/dev/null 2>&1          # change to path
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file") # get video duration in seconds
size="$(du -m "$file" | cut -f1)"     # get file size in MB

for i in {01..56}                     # loop 56 times
do
  interval=`echo "scale=0; (($i-0.5) * $duration/56)/1" | bc` # calculate position of each frame capture
  name=`echo "image$i.png"`                                   # image capture name
#  ttext=`date -u -d @$interval +"%T"`                         # timecode
#  `ffmpeg -v quiet -y -skip_frame nokey -ss $interval -i "$file" -vf select="eq(pict_type\,I)" -vf drawtext="text=\'$ttext\': fontcolor=white: fontsize=48: box=1: boxcolor=black@0.5: \
#  boxborderw=5: x=(w-text_w)/2: y=(h-text_h-10)" -vframes 1 "$name"` # skip to calculated position, grab next key frame, burn in timecode
  `ffmpeg -v quiet -y -skip_frame nokey -ss $interval -i "$file" -vf select="eq(pict_type\,I)" -vframes 1 "$name"` # skip to calculated position, grab next key frame
done
ffmpeg -v quiet -y -i image%02d.png -vf "scale=317:-1,tile=8x7:color=0x333333:margin=2:padding=2,scale=2560:-1" -qscale:v 3 "$output.jpg" # create contact sheet from images -> file.jpg
rm -f image*.png                    # remove images
popd
