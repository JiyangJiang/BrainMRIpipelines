#!/bin/bash


# HISTORY
#
# - Jan 2019 : Dr. Jiyang Jiang wrote the first version.
# - Nov 2022 : Jiyang Jiang modifies to incorporate into BrainMRIpipelines.
# - Oct 2023 : Re-write the whole script.

BIDS_dir=$1
subject_ID=$2
study=$3 # e.g., 'VCI'

cd $BIDS_dir

dcm2bids -d sourcedata/$subject_ID -p $subject_ID -c $BMP_PATH/BIDS/config_files/${study}_config.json --clobber --force_dcm2bids
