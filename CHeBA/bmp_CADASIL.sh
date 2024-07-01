#!/bin/bash

# DESCRIPTION
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# - Overview
#
# AusCADASIL has 2 current imaging study sites (Sydney and Newcastle),
# with the possibility of adding Melbourne and Brisbane in the
# future.
#
# Sydney site is at RINSW, using the same non-invasive imaging block
# as VCI study, adding resting state fMRI from MAS2, oxygen extraction
# fraction (OEF) from Hanzhang Lu @ Johns Hopkins, and myelin water
# imaging sequences.
#
# - Myelin water imaging (MWI) sequence
#
# The MWI sequence at Newcastle is through C2P from Jongho Lee @
# Korea. The MWI sequence at Sydney is Siemens WIP package.
#
# - Oxygen extraction fraction (OEF)
#
# This OEF protocol generates a global value. The value is displayed
# in a picture.
#
# - Naming
#
# For convenience in programming, Sydney study site is given the name
# "CADSYD", and Newcastle is given "CADNEW".
#
#
# COMPUTATIONAL RESOURCES
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# We use the same computational resources as VCI study data. See
# bmp_VCI.sh for more details.
#

# Katana
export DICOM_zip=/srv/scratch/cheba/Imaging/vci/vci_015/flywheel_20240313_002036.zip
export BIDS_dir=/srv/scratch/cheba/Imaging/vci/BIDS
export subject_ID=vci015
module load matlab/R2023b

omp=16 # max num of threads per process

bids_validator_version=1.13.1
mriqc_version=23.1.0
qsiprep_version=0.19.1
smriprep_version=0.12.2
aslprep_version=0.6.0
fmriprep_version=23.1.4

# dcm2bids
# +++++++++++++++++++++++++++++++++++++++
conda activate dcm2bids
bmp_BIDS_CHeBA.sh --study CADSYD --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID