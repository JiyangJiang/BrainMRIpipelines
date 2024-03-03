#!/bin/bash

# Data stored in /data_int/jiyang/tmp/work on GRID
#
# NOTES
#
# 03/03/2024 - Comparing CSF reference from my own ventricular mask vs.
#              the one automatically generated from BASIL

work_dir=/data_int/jiyang/tmp/work

# fsl_anat
for_each -nthreads 40 ${work_dir}/P*/*-* : fsl_anat -i IN/t1 -o IN/t1

# extract M0 for PASL
for_each -nthreads 40 ${work_dir}/PASL/*-* : fslroi IN/asl IN/m0 0 1
for_each -nthreads 40 ${work_dir}/PASL/*-* : fslroi IN/asl IN/asl 1 -1
for_each -nthreads 40 ${work_dir}/PASL/*-* : rm -f IN/asl.nii
for_each -nthreads 40 ${work_dir}/PASL/*-* : gunzip IN/*.gz

# segment lateral ventricles
for_each -nthreads 40 ${work_dir}/P*/*-* : mkdir -p IN/ventricle
for_each -nthreads 40 ${work_dir}/P*/*-* : matlab -nodesktop -nodisplay -r \"addpath\(fullfile\(getenv\(\'BMP_PATH\'\),\'misc\'\)\)\;bmp_misc_getLatVent\(\'IN/m0.nii\',\'IN/t1.nii\',\'IN/ventricle\'\)\;exit\"
for_each -nthreads 40 ${work_dir}/P*/*-* : cp IN/ventricle/rventricular_mask.nii IN/vent.nii
for_each -nthreads 40 ${work_dir}/P*/*-* : fslmaths IN/vent -kernel boxv 2 -ero IN/vent_ero

# PASL - automatically generated CSF mask
work_dir=/data_int/jiyang/tmp/work
for_each -nthreads 40 ${work_dir}/PASL/*-* : mkdir -p IN/basil_autoCSFmask
for_each -nthreads 40 ${work_dir}/PASL/*-* : oxford_asl -i=IN/asl.nii --iaf=tc --ibf=rpt --bolus=0.7 --rpts=50 --slicedt=0.04667 --tis=1.8 --fslanat=IN/t1.anat -c=IN/m0.nii --cmethod=single --tr=2.5 --cgain=1 --tissref=csf --t1csf=4.3 --t2csf=750 --t2bl=150 --te=11 -o=IN/basil_autoCSFmask --bat=0.7 --t1=1.3 --t1b=1.65 --alpha=0.98 --spatial=1 --mc --pvcorr --artoff

# PASL - my own eroded CSF mask
work_dir=/data_int/jiyang/tmp/work
for_each -nthreads 40 ${work_dir}/PASL/*-* : mkdir -p IN/basil_myOwnErodedCSFmask
oxford_asl -i=IN/asl.nii --iaf=tc --ibf=rpt --bolus=0.7 --rpts=50 --slicedt=0.04667 --tis=1.8 --fslanat=IN/t1.anat -c=IN/m0.nii --cmethod=single --tr=2.5 --cgain=1 --tissref=csf --csf=IN/vent_ero.nii.gz --t1csf=4.3 --t2csf=750 --t2bl=150 --te=11 -o=IN/basil_myOwnErodedCSFmask --bat=0.7 --t1=1.3 --t1b=1.65 --alpha=0.98 --spatial=1 --mc --pvcorr --artoff