#!/bin/sh
set -e

if [ -z "$3" ] ; then
  WHITE=90
else
  WHITE="$3"
fi

/usr/bin/convert -trim -fuzz 40% "$1" -modulate 100,0 -level 10%,${WHITE}% '(' +clone -roll +0+1 '(' +clone -roll +1-1 ')' +composite -compose Multiply ')' +composite -compose Multiply -gamma 0.5 -geometry 600x750 "$2"

