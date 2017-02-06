#!/bin/bash

set -e

IN_OPTIONS=$1
IN_IMG=$2
OUT_IMG=$3
OUT_DATA=$4

## After loading the frap package, the frap bin directory is added to EXEC_PATH
EXEC_PATH=`octave --eval 'pkg load frap; printf ("%s", EXEC_PATH ());'`
PATH="$PATH:$EXEC_PATH"

frapinator --no-mask $1 $2

FILE=$(basename "$IN_IMG" | cut -d'.' --complement -f2-)

PLOT=$(dirname $IN_IMG)"/plots_${FILE}.png"
DATA=$(dirname $IN_IMG)"/extracted_data_${FILE}.txt"

mv "$PLOT" "$OUT_IMG"
mv "$DATA" "$OUT_DATA"
