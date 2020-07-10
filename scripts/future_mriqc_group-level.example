#!/bin/bash

# ++++++++++++++++++++++++++++++++++++
#
# 1) this will generate a group report
#
# 2) this runs very fast
#
# ++++++++++++++++++++++++++++++++++++

BIDS_project_folder=/data2/jiyang/backup_data/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS

singularity run --cleanenv \
				-B ${BIDS_project_folder}:/data \
				-B ${BIDS_project_folder}/derivatives/mriqc:/out \
				-B ${BIDS_project_folder}/derivatives/mriqc/work:/work \
				/data2/jiyang/mriqc-v0.15.0.simg \
				/data /out group \
				--work-dir /work