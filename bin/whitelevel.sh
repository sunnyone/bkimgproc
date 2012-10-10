#!/bin/bash

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.

if [ -z "$1" ]; then
  echo usage: $0 image
  exit 1
fi

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

FILE="$1"
INFOY=`convert -trim -fuzz 40% "$FILE" -format "%H %Y %h" info:`
if [ -z "$INFOY" ]; then
  echo -1
  exit 0
fi

ORIG_HEIGHT=`echo $INFOY | awk '{print $1}'`
TOP_BLANK=`echo $INFOY | awk '{print $2}' | tr -d '+'`
CROPPED_HEIGHT=`echo $INFOY | awk '{print $3}'`

# No blank detected. This page is all blank or gray.
if [ "$TOP_BLANK" -eq -1 ] ; then
  echo -1
  exit 0
fi

BOTTOM_OFFSET=`expr $TOP_BLANK + $CROPPED_HEIGHT`
BOTTOM_BLANK=`expr $ORIG_HEIGHT - $BOTTOM_OFFSET`

TOP_BLANK_PERCENT=`expr $TOP_BLANK \* 100 / $ORIG_HEIGHT`
BOTTOM_BLANK_PERCENT=`expr $BOTTOM_BLANK \* 100 / $ORIG_HEIGHT`

# Too large: Just white or totally image. Too small: useless
if [ $TOP_BLANK_PERCENT -le 1 -o $TOP_BLANK_PERCENT -ge 25 ] ; then
  TOP_INVALID=1
fi

if [ $BOTTOM_BLANK_PERCENT -le 1 -o $BOTTOM_BLANK_PERCENT -ge 25 ] ; then
  BOTTOM_INVALID=1
fi

# Both side are invalid, then this image is useless.
if [ -n "$TOP_INVALID" -a -n "$BOTTOM_INVALID" ] ; then
  echo -1
  exit 0
elif [ -n "$TOP_INVALID" ] ; then
   RESULT="`convert "$FILE" -modulate 100,0 -crop x+0+$BOTTOM_OFFSET -format "%[mean] %[standard-deviation]" info:`"
elif [ -n "$BOTTOM_INVALID" ] ; then
   RESULT="`convert "$FILE" -modulate 100,0 -crop x$TOP_BLANK+0+0 -format "%[mean] %[standard-deviation]" info:`"
else
   RESULT="`convert "$FILE" -modulate 100,0 '(' -clone 0 -crop x$TOP_BLANK+0+0 ')' '(' -clone 0 -crop x+0+$BOTTOM_OFFSET ')' -delete 0 -append -format "%[mean] %[standard-deviation]" info:`"
fi

echo $RESULT | awk '{ print int(($1 - 3 * $2) / 655.35) }'

