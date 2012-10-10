#!/bin/sh
set -e

if [ -z "$2" ] ; then
  echo usage: $0 temp-dest-dir temp-archive-dir
  exit 1
fi

TEMP_DEST_DIR="$1"
TEMP_ARCHIVE_DIR="$2"

(cd "$TEMP_DEST_DIR" ; /usr/bin/zip $TEMP_ARCHIVE_DIR/archive.zip *.jpg )
mv $TEMP_ARCHIVE_DIR/archive.zip $TEMP_ARCHIVE_DIR/archive.cbz
