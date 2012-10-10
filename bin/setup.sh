#!/bin/bash

## bkimgproc - Book image processor
## Copyright (c) 2012 Yoichi Imai, all rights reserved.

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
BKIMGPROC_HOME="${BKIMGPROC_HOME:-${SCRIPT_DIR}/..}"
. $BKIMGPROC_HOME/lib/bkimgproc.sh

mkdir $DATA_DIR
mkdir $DATA_INCOMING_DIR
mkdir $DATA_WORKING_DIR
mkdir $DATA_FAILED_DIR
mkdir $DATA_DONE_DIR
mkdir $DATA_BOOKS_DIR
mkdir $DATA_TEMP_DIR
