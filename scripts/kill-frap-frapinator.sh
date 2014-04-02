#!/bin/bash
## FIXME Now we really know how to program, we should make frapinator a better
## program. This is unnaceptable.

IN_IMG=$1
OUT_IMG=$2

../frapinator/frapinator.m $1

FILE=$(echo $(basename $IN_IMG) | cut -d'.' --complement -f2-)

PLOT=$(dirname $1)"/plots_"$FILE".png"
mv $PLOT $OUT_IMG

