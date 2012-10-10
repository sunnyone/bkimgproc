#!/bin/sh
set -e
/usr/bin/convert "$1" -modulate 100,0 -level 10%,90%,0.6 -geometry 600x750 "$2"
