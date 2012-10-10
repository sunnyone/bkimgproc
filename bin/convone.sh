#!/bin/bash

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.
set -e 

if [ -z "$1" ] ; then
  echo "usage: $0 proj-dir"
  exit 1
fi

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

PROJ_DIR="$1"

TEMP_DIR=$DATA_TEMP_DIR/bkimgproc.$$
mkdir $TEMP_DIR

# Extract jpegs
mkdir $TEMP_DIR/original

find "$PROJ_DIR" -maxdepth 1 -type f | egrep -i "^.*/[0-9][-_0-9]*[a-z]*.(pdf|jpg)$" | while read FILE ; do
  BASE="`basename $FILE`"
  EXT="${BASE#*.}"
  BASE="${BASE%.*}"
  
  ## special treatment for '-' and '_': remove characters
  BASE="`echo "$BASE" | sed -e 's/[-_]//g'`"

  case "$EXT" in
  jpg|JPG)
    bkimgproc_log "Copy image from '$FILE'"
    cp "$FILE" "$TEMP_DIR/original/$BASE-001.jpg"
    ;;
  *) 
    bkimgproc_log "Extracting images from '$FILE'"

    # pdfimages generates {base}-{num}.xxx
    pdfimages -j $FILE "$TEMP_DIR/original/$BASE"
  esac
done

bkimgproc_log "Calculating white levels"
mkdir $TEMP_DIR/white
$BKIMGPROC_HOME/bin/whiteleveldir.sh $TEMP_DIR/white $TEMP_DIR/original

bkimgproc_log "Rotating images for 'r' or 'l' images"
$BKIMGPROC_HOME/bin/rotate.sh $TEMP_DIR/original/$BASE/*

mkdir $TEMP_DIR/work
mkdir $TEMP_DIR/archive
if [ ! -d "$PROJ_DIR/result" ] ; then
  mkdir $PROJ_DIR/result
fi

for PLUGIN_DIR in $PLUGINS_DIR/*; do
  # Converting 
  PLUGIN=`basename $PLUGIN_DIR`
  bkimgproc_log "Start converting for $PLUGIN"
  
  DEST_DIR=$TEMP_DIR/work/$PLUGIN
  mkdir $DEST_DIR

  # ORIG_JPEG may be pbm
  for ORIG_JPEG in `find $TEMP_DIR/original -type f | sort`; do
    ORIG_JPEG_BASE=`basename $ORIG_JPEG`
    # Remove extension
    ORIG_JPEG_BASE=${ORIG_JPEG_BASE%.*}

    PREFIX=${ORIG_JPEG_BASE%-*}
    PAGE=${ORIG_JPEG_BASE#*-}
    ODDEVEN=`expr $PAGE % 2` || true

    WHITE=`cat $TEMP_DIR/white/white-$PREFIX-$ODDEVEN-center`
    # [rl] is for the rotate option
    OPTION=`echo $ORIG_JPEG_BASE | sed -e 's/^[0-9]*[rl]\?//' -e 's/-.*$//'`
 
    if [ -z "$OPTION" ] ; then
       sh -x $PLUGIN_DIR/options/_.sh $ORIG_JPEG $DEST_DIR/$ORIG_JPEG_BASE.jpg $WHITE
    else
       sh -x $PLUGIN_DIR/options/$OPTION.sh $ORIG_JPEG $DEST_DIR/$ORIG_JPEG_BASE.jpg $WHITE
    fi
  done

  bkimgproc_log "Renaming images."
  CUR=1
  for OLD_PATH in `ls -1 $DEST_DIR/*.jpg | sort` ; do
    NEW_NAME=`printf "P%05d.jpg" $CUR`
    CUR=`expr $CUR + 1`
 
    bkimgproc_log " Moving $OLD_PATH to $NEW_NAME" 
    mv $OLD_PATH $DEST_DIR/$NEW_NAME
  done

  # Be careful: $RESULT_BASE may contain spaces.
  bkimgproc_log "Finding name-pdf."
  RESULT_BASE="`find "$PROJ_DIR" -name "*.pdf" -o -name "*.PDF" | sed -e 's/.*\///' -e 's/\.pdf$//i' | grep -v "^[0-9]"`"
  if [ -z "$RESULT_BASE" ] ; then
    RESULT_BASE="`basename "$PROJ_DIR"`"
    bkimgproc_log "Not detected name pdf: use project basename"
  fi
  bkimgproc_log "Result name is '$RESULT_BASE'"

  IS_R2L=""
  if [ -f "$PROJ_DIR/r2l.txt" ] ; then
    IS_R2L=1
  fi
  bkimgproc_log "Right-to-left option: $IS_R2L"

  bkimgproc_log "Archiving for $PLUGIN"
  mkdir $TEMP_DIR/archive/$PLUGIN
  $PLUGIN_DIR/archive.sh $DEST_DIR $TEMP_DIR/archive/$PLUGIN "$IS_R2L"
  
  # Check archive.* (archive.cbz, archive.pdf, etc)
  ARCHIVE_FILE=`find $TEMP_DIR/archive/$PLUGIN -name "archive.*"`
  if [ -z "$ARCHIVE_FILE" ] ; then
    bkimgproc_log "Failed to archive for $PLUGIN"
    exit 1 
  fi

  ARCHIVE_FILE_BASE="$(basename "$ARCHIVE_FILE")"
  ARCHIVE_FILE_EXT="${ARCHIVE_FILE_BASE#*.}"
  RESULT_FILE="$PROJ_DIR/result/${RESULT_BASE}_${PLUGIN}.${ARCHIVE_FILE_EXT}"
  mv "$ARCHIVE_FILE" "$RESULT_FILE"

  bkimgproc_log "Generated '$RESULT_FILE'"
done

rm -rf "$TEMP_DIR"

