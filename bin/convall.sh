#!/bin/sh

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

LOGFILE=$DATA_DIR/bkimgproc.log

FINAL_STATUS=0
bkimgproc_log "Start bkimgproc."
for I in `ls -1d $DATA_INCOMING_DIR/*`; do
  if [ ! -d "$I" ] ; then
    bkimgproc_log "Not a directory. Skipped: $I"
    continue
  fi

  BASE=`basename $I`
  bkimgproc_log " Start converting $BASE..."

  mv $I $DATA_WORKING_DIR/$BASE

  $BKIMGPROC_HOME/bin/convone.sh $DATA_WORKING_DIR/$BASE >$DATA_WORKING_DIR/$BASE/convert.log 2>&1

  STATUS=$?
  if [ $STATUS -ne 0 ] ; then
    FINAL_STATUS=$STATUS
    bkimgproc_log " Failed to convert $BASE. See convert.log."
    mv $DATA_WORKING_DIR/$BASE $DATA_FAILED_DIR/$BASE
  else
    bkimgproc_log " Succeeded to convert $BASE. Moving results..."
   
    for J in $DATA_WORKING_DIR/$BASE/result/*; do
      PLUGIN=`echo $J | sed -e 's/^.*_//' -e 's/\.[a-zA-Z0-9]*$//'`
      
      if [ ! -d "$DATA_BOOKS_DIR/$PLUGIN" ] ; then
        mkdir "$DATA_BOOKS_DIR/$PLUGIN"
      fi
      
      mv "$J" "$DATA_BOOKS_DIR/$PLUGIN/"
    done
 
    rmdir $DATA_WORKING_DIR/$BASE/result

    # FIXME: duplicate check.
    NEW_BASE=`date "+%Y%m%d%H%M%S"`-$BASE
    bkimgproc_log " Backup project directory to $DATA_DONE_DIR/$NEW_BASE." 
    mv $DATA_WORKING_DIR/$BASE $DATA_DONE_DIR/$NEW_BASE
  fi
done
bkimgproc_log "Finished bkimgproc."

exit $FINAL_STATUS
