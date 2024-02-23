#!/bin/bash


# HISTORY
#
# - Jan 2019 : Dr. Jiyang Jiang wrote the first version.
# - Nov 2022 : Jiyang Jiang modifies to incorporate into BrainMRIpipelines.
# - Oct 2023 : Re-write the whole script.

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3
study=$4 # e.g., 'VCI'

echo "[$(date)] : $(basename $0) : Calling bmp_BIDS_CHeBA_init.sh to sort out Flywheel zip archive."
bmp_BIDS_CHeBA_reorganiseFlywheelDicomZip.sh $DICOM_zip $BIDS_dir $subject_ID

cd $BIDS_dir
echo "[$(date)] : $(basename $0) : Calling dcm2bids to convert $subject_ID to BIDS."
dcm2bids -d sourcedata/$subject_ID -p $subject_ID -c $BMP_PATH/BIDS/config_files/${study}_config.json --clobber --force_dcm2bids

# echo "[$(date)] : $(basename $0) : "
# echo "[$(date)] : $(basename $0) : [NOTE] If there's any warning message regarding IntendedFor id not found, "
# echo "[$(date)] : $(basename $0) : [NOTE] this is because fmaps acquired before the IntendedFor seq."
# echo "[$(date)] : $(basename $0) : [NOTE] May need to manually add \"IntendedFor\" to corresponding JSON."
# echo "[$(date)] : $(basename $0) : "

echo "[$(date)] : $(basename $0) : Creating aslcontext file for subject $subject_ID."
bmp_BIDS_CHeBA_genASLcontext.sh $BIDS_dir $subject_ID