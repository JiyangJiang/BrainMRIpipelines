#!/bin/bash

work_dir=/srv/scratch/cheba/Imaging/oats_scs_asl # Katana
work_dir=~/Work/oats_scs_asl # examples on VM
n_threads=2

for_each -nthreads $n_threads ${work_dir}/P*/*-* : flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in $(ls IN/WMH/mri/preprocessing/nonBrainRemoved_w*_t1.nii*) -omat IN/WMH/mri/extractedWMH/wT1_to_MNI.mat