#!/bin/sh
set -e

if [ -z "$2" ] ; then
  echo usage: $0 temp-dest-dir temp-archive-dir [is-r2l]
  exit 1
fi

TEMP_DEST_DIR="$1"
TEMP_ARCHIVE_DIR="$2"
IS_R2L="$3"

for I in $TEMP_DEST_DIR/*.jpg ; do
  sam2p "$I" -pdf:2 "${I%.jpg}.pdf" || exit 1
done
pdftk $TEMP_DEST_DIR/*.pdf cat output $TEMP_ARCHIVE_DIR/temp.pdf

## force meta rewriting
SCRIPT_DIR=`dirname $0`
if [ -f "$SCRIPT_DIR/meta.txt" ] ; then
  pdftk $TEMP_ARCHIVE_DIR/temp.pdf update_info $SCRIPT_DIR/meta.txt output $TEMP_ARCHIVE_DIR/temp1.pdf
  mv $TEMP_ARCHIVE_DIR/temp1.pdf $TEMP_ARCHIVE_DIR/temp.pdf
fi

if [ -n "$IS_R2L" ] ; then
  sed -e 's|/Type/Catalog|/ViewerPreferences<</Direction /R2L>>&|' \
    $TEMP_ARCHIVE_DIR/temp.pdf | pdftk - output $TEMP_ARCHIVE_DIR/archive.pdf
else
  cp $TEMP_ARCHIVE_DIR/temp.pdf $TEMP_ARCHIVE_DIR/archive.pdf
fi

