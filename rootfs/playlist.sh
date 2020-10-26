#!/bin/bash

# $1 = dir

# eg. playlist.sh ${absoluteFilePath}

# Creates a playlist.m3u8 significantly faster than CTBRec
# by only reading the duration of the first segment and
# using it for all following entries in playlist.m3u8
# This does not cause any problems when it comes to any
# further post-processing as ffmpeg will ignore the value.

# Requires: mediainfo

[ -f "$1" ] && exit
pushd "$1"
 
header=$(printf '#EXTM3U\n#EXT-X-VERSION:4\n#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-TARGETDURATION:1\n#EXT-X-MEDIA-SEQUENCE:0')
trailer=$(printf '#EXT-X-ENDLIST')
file=$(ls *.ts | head -1)
dur=$(mediainfo --Inform="General;%Duration%" $file)
dur=${dur%.*}

duration=${dur::(-3)}.${dur:(-3)}
 
printf '%s\n' "$header" > playlist.m3u8
 
for i in $(ls *.ts)
do
  item=$(printf "#EXTINF:$duration,$i\n$i")
  printf '%s\n' $item >> playlist.m3u8
done
 
printf '%s' $trailer >> playlist.m3u8
