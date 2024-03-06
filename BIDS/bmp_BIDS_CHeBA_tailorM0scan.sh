#!/bin/bash

BIDS_dir=$1
subject_ID=$2

fslroi ${BIDS_dir}/sub-${subject_ID}/fmap/sub-${subject_ID}_dir-AP_m0scan \
	   ${BIDS_dir}/sub-${subject_ID}/fmap/sub-${subject_ID}_dir-AP_m0scan \
	   0 \
	   1