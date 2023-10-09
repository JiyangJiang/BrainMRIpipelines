#!/bin/bash

# This script should only be run when trying to create config json file

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

# dcm2bids_scaffold to prepare BIDS folder
echo "[$(date)] : $(basename $0) : Running dcm2bids_scaffold to create basic files and directories for BIDS."

dcm2bids_scaffold --output_dir $BIDS_dir

# extract from Flywheel zip archive
echo "[$(date)] : $(basename $0) : Calling bmp_BIDS_CHeBA_init.sh to sort out Flywheel zip archive."

bmp_BIDS_CHeBA_reorganiseFlywheelDicomZip.sh $DICOM_zip $BIDS_dir $subject_ID

echo "[$(date)] : $(basename $0) : Running dcm2bids_helper to convert DICOM to NIFTI and json, so that configuration file can be prepared."

dcm2bids_helper --dicom_dir $DICOM_dir \
				--output_dir $BIDS_directory/tmp_dcm2bids/helper \
				--log_level DEBUG \
				--force \
				> $BIDS_directory/tmp_dcm2bids/dcm2bids_helper.debug_log

echo -e "[$(date)] : $(basename $0) : Investigate json files in $BIDS_directory/tmp_dcm2bids/sourcedata/$curr_subjID to create the configuration file."