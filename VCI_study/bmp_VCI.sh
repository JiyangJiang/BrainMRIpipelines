#!/bin/bash

# DESCRIPTION :
#
#   This script goes through the pipelines to process imaging data
#   for VCI study.

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

# Step 0. Create dcm2bids configuration file.
# ++++++++++++++++++++++++++++++++++++++++++++
# 0.1 - reorganise DICOM folders, and run helper function.
# bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID --is_1st_run
# 0.2 - generate configuration file.
# MATLAB ==>> vci_config = bmp_BIDS_CHeBA_genVCIconfigFile('rsfMRI'); % edit matchings
# 0.3 - tidy up.
# edit BrainMRIPipelines/BIDS/config_files/VCI_config.json to remove [] lines.

# Step 1. dcm2bids for subsequent scans.
# +++++++++++++++++++++++++++++++++++++++
bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID

# Step 2. validate BIDS
# +++++++++++++++++++++++++++++++++++++++
bmp_BIDSvalidator.sh --bids_directory $BIDS_dir --docker
# Or directly run in docker
# docker run -ti --rm -v ${BIDS_dir}:/data:ro bids/validator /data

# Step 3. MRIQC (subject level)
docker run -it --rm -v ${BIDS_dir}:/data:ro -v ${BIDS_dir}/derivatives/mriqc/sub-$subject_ID:/out nipreps/mriqc /data /out participant --modalities {T1w,T2w,bold,dwi} --verbose-reports --species human --deoblique --despike --mem_gb 4  --nprocs 1 --no-sub