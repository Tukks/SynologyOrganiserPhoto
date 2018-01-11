#!/bin/sh
# https://forum.synology.com/enu/viewtopic.php?t=132084 source
# to
tmpdir="/volume1/multimedia/tmp_photo/$1"
dir="/volume1/photo/$1"

now=`date +"%Y%m%d_%H%M"`
log=`dirname $0`"/log/$now.log"
thumbdir=$tmpdir/@eaDir


echo "Organizing photos and videos"
echo "  from:     $tmpdir"
echo "  to:       $dir"
echo "  log:      $log"
echo "  thumbdir: $thumbdir"


declare -a infos
infos+=("From: $tmpdir")
infos+=("To:   $dir")

for file in $tmpdir/*; do
    echo
    
    if [ -f "$file" ]; then

   # found a file
   filename=$(basename "$file")

   date=${filename#IMG_}
   date=${date#VID_}
   date=${date#PANO_}

   year=${date:0:4}
   month=${date:4:2}


   diryear="$year"
   dirmonth="$month"
        newdir="$dir/$diryear/$dirmonth"
        newfile=$newdir/$filename
   info="$filename --> $diryear --> $dirmonth"
   infos+=("$info")
        echo $info


        if [ ! -d "$newdir" ]; then
            # create newdir if it does not exist yet
            echo "  mkdir $newdir"
            mkdir $newdir

       synoindex -A $newdir
        fi
   
        mv $file $newfile



   thumbs=$thumbdir/$filename
   if [ -d "$thumbs" ]; then
       echo "clean synofile thumbs"
       rm -fr $thumbs
   fi



        echo "  update synology db"
        synoindex -d $file
        synoindex -a $newfile

    fi

done

echo
echo "Completed!"

( IFS=$'\n'; echo "${infos[*]}" > $log)

exit 0