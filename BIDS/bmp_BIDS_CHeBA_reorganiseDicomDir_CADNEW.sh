#!/bin/bash

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

unzip -qq -o -d $BIDS_dir/sourcedata/$subject_ID/$modality_name