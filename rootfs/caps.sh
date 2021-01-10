#!/bin/bash
# caps.sh ${absoluteFilePath}

# Requirements: ffmpeg

# https://stackoverflow.com/questions/4632028/how-to-create-a-temporary-directory
# Deletes temp work directory
function cleanup {      
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=`mktemp -d -p "$DIR"`

# check if temp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

fullpath=`echo ${1%}`
dir=`echo "${1%/*}"`                    # get path
file=`echo "${1##*/}"`                  # get file
output=`echo "${dir%}/${file%.*}.jpg"`  # full contact sheet path
#output=`echo "${file%.*}"`              # remove extension from file name
pushd "$WORK_DIR"                       # change to temp work dir

# pushd "$dir" >/dev/null 2>&1          # change to path
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$fullpath") # get video duration in seconds
size="$(du -m "$fullpath" | cut -f1)"     # get file size in MB

for i in {01..56}                     # loop 56 times
do
  interval=`echo "scale=0; (($i-0.5) * $duration/56)/1" | bc` # calculate position of each frame capture
  name=`echo "image$i.png"`                                   # image capture name
  `ffmpeg -v quiet -y -skip_frame nokey -ss $interval -i "$fullpath" -vf select="eq(pict_type\,I)" -vframes 1 "$name"` # skip to calculated position, grab next key frame
done
ffmpeg -v quiet -y -i image%02d.png -vf "scale=317:-1,tile=8x7:color=0x333333:margin=2:padding=2,scale=2560:-1" -qscale:v 3 "$output" # create contact sheet from images -> file.jpg
rm -f image*.png                    # remove images
popd
