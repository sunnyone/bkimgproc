#!/bin/sh
set -e

if [ -z "$3" ] ; then
  WHITE=$3
else
  WHITE=90
fi

/usr/bin/convert "$1" -modulate 100,0 -level 10%,${WHITE}%,0.8 -quality 90 "$2"
