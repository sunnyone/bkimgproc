#!/bin/bash

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

for I in "$@"; do
  BASE="`basename "$I"`"

  ROTATE_OPTION="`echo "$BASE" | sed -e 's/^[0-9]*\(.\).*/\1/'`"

  case "$ROTATE_OPTION" in
  r)
    EVEN_ANGLE=270
    ODD_ANGLE=90
    ;;
  l)
    EVEN_ANGLE=90
    ODD_ANGLE=270
    ;;
  *)
    continue
  esac

  PAGENUM="${BASE#*-}"
  PAGENUM="${PAGENUM%.*}"

  if [ `expr $PAGENUM % 2` -eq 0 ] ; then
     bkimgproc_log "Rotate option $ROTATE_OPTION ($EVEN_ANGLE) $I"
     mogrify -rotate $EVEN_ANGLE "$I"
  else
     bkimgproc_log "Rotate option $ROTATE_OPTION ($ODD_ANGLE) $I"
     mogrify -rotate $ODD_ANGLE "$I"
  fi
done

