#!/bin/bash

work_dir=/data_orange/oats_scs_asl # on TowerX (149.171.107.28)
work_dir=/data_orange/oats_scs_asl/test
n_threads=10

MNI_GM_prob=$FSLDIR/data/standard/tissuepriors/avg152T1_gray
MNI_WM_prob=$FSLDIR/data/standard/tissuepriors/avg152T1_white
Harvard_Oxford_subcort_cort_thr50=$FSLDIR/data/atlases/HarvardOxford/HarvardOxford-sub-maxprob-thr50-2mm

# Create DARTEL-to-MNI warp
cd ${work_dir}/DARTEL_to_MNI_warping
flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in all_NBTR_wT1_4D_Tmean -omat DARTEL_to_MNI.mat
fnirt --in=all_NBTR_wT1_4D_Tmean --aff=DARTEL_to_MNI.mat --cout=DARTEL_to_MNI_nonlinear_transf --config=T1_2_MNI152_2mm

# Apply DARTEL-to-MNI warp to WMH_DARTEL
for_each -nthreads $n_threads ${work_dir}/P*/*-* : applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=IN/WMH_DARTEL --warp=/data_orange/oats_scs_asl/DARTEL_to_MNI_warping/DARTEL_to_MNI_nonlinear_transf --out=IN/WMH_MNI
for_each -nthreads $n_threads ${work_dir}/P*/*-* : fslmaths IN/WMH_MNI -thr 0.8 -bin IN/WMH_MNI