#!/bin/bash

#$ -N M24_FreeSurfer_reconall
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=8G
#$ -o /data2/heidi/MAS_W124/MW24/MW24_reconall.out
#$ -e /data2/heidi/MAS_W124/MW24/MW24_reconall.err
#$ -t 1-232

subjID=`cat /data2/heidi/MAS_W124/MW24/MW24.list | awk "NR==${SGE_TASK_ID}"`

module load fsl/5.0.11
module load freesurfer/6.0.0

export SUBJECTS_DIR=/data2/heidi/MAS_W124/MW24

cd ${SUBJECTS_DIR}

recon-all -base ${subjID} -tp FS_${subjID}_tp2_t1 -tp FS_${subjID}_tp3_t1 -all

recon-all -long FS_${subjID}_tp2_t1 ${subjID} -all

recon-all -long FS_${subjID}_tp3_t1 ${subjID} -all