#!/bin/bash

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.

if [ -z "$2" ] ; then
  echo usage: $0 tmp-white-dir images-dir
  exit 1
fi

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

TMP_WHITE_DIR="$1"
IMAGES_DIR="$2"

if [ ! -d "$TMP_WHITE_DIR" ] ; then
  echo "TMP_WHITE_DIR: '$TMP_WHITE_DIR' is not created."
  exit 1
fi

# Find images -999 (a naming rule for pdfimages) files.
find $IMAGES_DIR -maxdepth 1 -type f | \
  sed -ne 's/^\(.*\/\([^-]*\)-\([0-9][0-9][0-9]\)\.[^\.]*\)$/\1 \2 \3/p' | \
  while read P PREFIX PAGE; do
    ODDEVEN=`expr $PAGE % 2`
    $BKIMGPROC_HOME/bin/whitelevel.sh $P >>$TMP_WHITE_DIR/white-$PREFIX-$ODDEVEN
done

# Calculate median
for I in $TMP_WHITE_DIR/white-*; do
  grep -v -- "-1" $I | grep -v "nan" >$I-valid
  VALID_COUNT=`cat $I-valid | wc -l`
  CENTER=`expr $VALID_COUNT / 2 + 1`
  VAL=`sort -n $I-valid | head -$CENTER | tail -1`

  # no value 
  if [ -z "$VAL" ] ; then
    SELECTED=$DEFAULT_WHITELEVEL
  # too little sample
  elif [ "$VALID_COUNT" -lt $WHITELEVEL_SAMPLES ]; then
    SELECTED=$DEFAULT_WHITELEVEL
  # too black
  elif [ "$VAL" -lt $DANGER_WHITELEVEL ]; then
    SELECTED=$DANGER_WHITELEVEL
  else
    SELECTED=$VAL
  fi

  echo $SELECTED>$I-center
  echo "$I: valid-count,calculated,selected: $VALID_COUNT,$VAL,$SELECTED"
done
 
