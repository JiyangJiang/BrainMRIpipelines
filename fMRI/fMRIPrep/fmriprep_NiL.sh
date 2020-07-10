#!/bin/bash

#$ -N fmriprep
#$ -V
#$ -cwd
#$ -pe smp 2
#$ -q all.q
#$ -l h_vmem=8G
#$ -o /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/fmriprep_N310/derivatives/fmriprep/sge_20200428.out
#$ -e /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/fmriprep_N310/derivatives/fmriprep/sge_20200428.err
#$ -t 1-310

# -------- ============== README ================ ----------------------
#
# - best copy freesurfer subjects_dir to /out/.
#
# - cp -r /share/apps/freesurfer/6.0.0/subjects/fsaverage /path/to/freesurfer/subjects_dir

BIDS_dir=/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/fmriprep_N310
fmriprep_version=v20.0.6
fs_license=/home/jiyang/my_software/FUTURE/fMRI/fMRIPrep/FS_license.txt

subjID=$(basename $(ls -1d ${BIDS_dir}/sub-* | awk "NR==${SGE_TASK_ID}"))
subjID=`echo ${subjID} | awk -F '-' '{print $2}'`


singularity run --cleanenv \
                -B ${BIDS_dir}:/data \
                -B ${BIDS_dir}/derivatives/fmriprep/${fmriprep_version}:/out \
                -B ${BIDS_dir}/derivatives/fmriprep/${fmriprep_version}/work:/work \
                -B /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/fmriprep_N310/derivatives/fmriprep/${fmriprep_version}/freesurfer:/FreeSurfer \
                /data2/jiyang/mySingulateImgs/fmriprep-${fmriprep_version}.simg \
                /data /out \
                participant \
                --participant_label ${subjID} \
                --fs-license-file ${fs_license} \
                --work-dir /work \
                --ignore {fieldmaps,slicetiming} \
                --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym fsaverage \
                --skip_bids_validation \
                --fs-subjects-dir /FreeSurfer \
                --use-aroma