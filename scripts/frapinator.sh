#!/bin/bash

set -e

## FIXME Now we really know how to program, we should make frapinator a better
## program. This is unnaceptable.
##
##  Very very good option is the saving of the options or I would never
##  found the settings for the analysis we done 4 years ago. The options
##  were
##
##  options =
##
##    scalar structure containing the fields:
##
##      flag_threshold =  1
##      flag_correct =  1
##      flag_log_image =  1
##      flag_fit_data =  1
##      flag_timestamps =  1
##      flag_frames =  0
##      nFrames =  1250
##      nPre_bleach =  100
##      tScan =  0.033000
##      bleach_diameter =  40
##      pixel_size =  0.10000
##      avg_start =  10
##      avg_end =  100
##      pre_start =  50
##      pre_end =  100
##      post_start =  101
##      post_end =  105
##      backg_size =  30
##      threshold_value =  16
##      nNorm =  10
##      binning_start =  20
##      bleach_factor =  1.2500
##      resolution =  2.5000
##      nSkip_profile =  3
##      Df =  200

IN_IMG=$1
OUT_IMG=$2
OUT_DATA=$3

../frapinator/frapinator.m $1

FILE=$(echo $(basename $IN_IMG) | cut -d'.' --complement -f2-)

PLOT=$(dirname $1)"/plots_"$FILE".png"
DATA=$(dirname $1)"/extracted_data_"$FILE".txt"
MASK=$(dirname $1)"/masks_"$FILE".tif"

rm $MASK
mv $PLOT $OUT_IMG
mv $DATA $OUT_DATA
