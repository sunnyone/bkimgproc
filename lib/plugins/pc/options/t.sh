#!/bin/sh
set -e

if [ -z "$3" ] ; then
  WHITE=90
else
  WHITE=$3
fi

/usr/bin/convert "$1" -modulate 100,0 -deskew 40% -level 10%,${WHITE}%,0.8 -quality 90 "$2"
