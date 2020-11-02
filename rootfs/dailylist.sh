#!/bin/sh -e

# NOTE: WIP

# $1 = /path/to/recordings/plus_as_much_filespec_as_needed_${localDateTime(yyy--MM--dd)}*.${fileSuffix}
# file = $(basename $1)
# dir = $(dirname $1)

# eg. dailylist.sh "/path/to/recordings/${modelSanitisedName}_${site_SanitisedName}_${localDateTime(yyyy-MM-dd)}*.${fileSuffix}"

# Creates a dailylist.m3u8 for appending multiple files with the same creation day

# [ -f "$1" ] && exit
cd "$1"

[ $(ls $1 | wc -l) -lt 2 ] && exit

header=$(printf '#EXTM3U\n#EXT-X-VERSION:4\n#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-TARGETDURATION:1\n#EXT-X-MEDIA-SEQUENCE:0')
trailer=$(printf '#EXT-X-ENDLIST')
#file=$(ls "$1" | head -1)
#duration=$(ffprobe -i $file -show_format -v quiet | sed -n 's/duration=//p')
 
printf '%s\n' "$header" > dailylist.m3u8
 
for i in $(ls $1)
do
  duration=$(ffprobe -i $i -show_format -v quiet | sed -n 's/duration=//p')
  item=$(printf "#EXTINF:$duration,$i\n$i")
  printf '%s\n' $item >> dailylist.m3u8
done
 
printf '%s' $trailer >> dailylist.m3u8
