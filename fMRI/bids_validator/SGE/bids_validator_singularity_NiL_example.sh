#!/bin/bash

BIDS_project_folder=/data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS

singularity run --cleanenv \
			    --bind ${BIDS_project_folder}:/data:ro \
			    /data2/jiyang/mySingulateImgs/bids_validator_20190423.simg \
			    /data