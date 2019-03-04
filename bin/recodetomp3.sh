#!/usr/bin/env bash
# converts all .flac files to .mp3 and copies them to the
# OUT directory; copies all .mp3 files to the OUT directory.

LAMEOPTS="-V0 --quiet"

MAXJOBS=6

function jobidfromstring()
{
        local STRING;
        local RET; 
        STRING=$1;
        RET="$(echo $STRING | sed 's/^[^0-9]*//' | sed 's/[^0-9].*$//')"

        echo $RET;
}


function clearToSpawn
{
    local JOBCOUNT="$(jobs -r | grep -c .)"
    if [ $JOBCOUNT -lt $MAXJOBS ] ; then
        echo 1;
        return 1;
    fi
    echo 0;
    return 0;
}



if [ "$#" -ne 2 ]
then
echo "usage: $0 MUSIC_DIR OUTPUT_DIR"
exit 1
fi

IN=$1
if [ ! -d "$IN" ]
then
echo "$IN is not a directory"
exit 1
fi

OUT=$2
if [ ! -d "$OUT" ]
then
mkdir "$OUT"
fi


echo "checking mp3 links"
# first, find all .mp3s and hardlink them to the OUT dir
# unless they are already there
find "$IN" -iname "*.mp3" | while read mp3;
do
OF=`echo "$mp3" | sed s,"$IN","$OUT\/",g|sed s,\?,,g|sed s,\*,,g|sed s,:,,g`
dir=`dirname "$OF"`
if [ ! -d "$dir" ]
then
mkdir -p "$dir"
fi
if [ ! -e "$OF" ]
then
echo "linking $mp3 to $OF"
#cp "$mp3" "$OF"
cp "$mp3" "$OF"
fi
done
echo " done"

echo "checking flac file conversions"
# now, find all .flacs and convert them to .mp3
# unless they have already been converted
find "$IN" -iname "*.flac" | while read flac;
do
OF=`echo "$flac" | sed s/\.flac/\.mp3/g | sed s,"$IN","$OUT\/",g|sed s,\?,,g|sed s,\*,,g|sed s,:,,g`
dir=`dirname "$OF"`
if [ ! -d "$dir" ]
then
mkdir -p "$dir"
fi
if [ ! -e "$OF" ]
then
# retrieve ID3 tags
ARTIST=`metaflac "$flac" --show-tag=ARTIST | sed s/.*=//g`
TITLE=`metaflac "$flac" --show-tag=TITLE | sed s/.*=//g`
ALBUM=`metaflac "$flac" --show-tag=ALBUM | sed s/.*=//g`
GENRE=`metaflac "$flac" --show-tag=GENRE | sed s/.*=//g`
TRACKNUMBER=`metaflac "$flac" --show-tag=TRACKNUMBER | sed s/.*=//g`
DATE=`metaflac "$flac" --show-tag=DATE | sed s/.*=//g`

# convert to MP3, preserving ID3 tags
echo "encoding $flac to $OF"
flac -c -dF --silent "$flac" | lame $LAMEOPTS \
--add-id3v2 --pad-id3v2 --ignore-tag-errors --tt "$TITLE" --tn "${TRACKNUMBER:-0}" --ta \
"$ARTIST" --tl "$ALBUM" --ty "$DATE" --tg "${GENRE:-12}" \
- "$OF"
fi
done

echo "done"


JOBLIST=""

echo "checking ogg file conversions"
# now, find all .ogg and convert them to .mp3
# unless they have already been converted
find "$IN" -iname "*.ogg" | while read ogg;
do
OF=`echo "$ogg" | sed s/\.ogg/\.mp3/g | sed s,"$IN","$OUT\/",g|sed s,\?,,g|sed s,\*,,g|sed s,:,,g`
dir=`dirname "$OF"`
if [ ! -d "$dir" ]
then
mkdir -p "$dir"
fi
if [ ! -e "$OF" ]
then
# retrieve ID3 tags
ARTIST=`ogginfo "$ogg" |grep -i artist|grep "artist="|grep -v album | sed s/.*=//g`
TITLE=`ogginfo "$ogg" |grep -i title | sed s/.*=//g`
ALBUM=`ogginfo "$ogg" |grep -i album|grep -v artist|grep -v musicbr | sed s/.*=//g`
#GENRE=`metaflac "$flac" --show-tag=GENRE | sed s/.*=//g`
TRACKNUMBER=`ogginfo "$ogg" |grep -i tracknumber | sed s/.*=//g`
DATE=`ogginfo "$ogg" |grep -i date| sed s/.*=//g`

# convert to MP3, preserving ID3 tags

while [ `clearToSpawn` -ne 1 ]; do
	sleep 1
done

echo "encoding $ogg to $OF"
ogg123 -q -d wav -f - "$ogg" | lame $LAMEOPTS \
--add-id3v2 --pad-id3v2 --ignore-tag-errors --tt "$TITLE" --tn "${TRACKNUMBER:-0}" --ta \
"$ARTIST" --tl "$ALBUM" --ty "$DATE" \
- "$OF" &
fi
done



for JOB in $JOBLIST ; do
	wait %$JOB
        echo "finished"
done
