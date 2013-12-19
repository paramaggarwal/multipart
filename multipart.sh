#!/bin/sh
# Author: Param Aggarwal
# Multipart parallel downloader in Shell using cURL

if [[ $# -lt 1 ]]; then
    echo "$0: Pass URL to download as argument"
    exit 1
fi

url=$1
parts=20

name="$(expr $url : '.*/\(.*\)')"
size="$(curl --head --silent $url | grep Content-Length | sed 's/[^0-9]*//g')"
echo Size: $size
echo Filename: $name
echo Downloading in $parts parts

for (( c=1; c<=$parts; c++ ))
do
    from="$(echo $[$size*($c-1)/$parts])"
    if [[ $c != $parts ]]; then
        to="$(echo $[($size*$c/$parts)-1])"
    else
        to="$(echo $[$size*$c/$parts])"
    fi 

    out="$(printf 'temp.part'$c)"
    
   echo "curl --silent --range $from-$to -o $out $url &"
    curl --silent --range $from-$to -o $out $url &
    
done

wait

for (( c=1; c<=$parts; c++ ))
do
    cat $(printf 'temp.part'$c) >> $name
    rm $(printf 'temp.part'$c)
done
