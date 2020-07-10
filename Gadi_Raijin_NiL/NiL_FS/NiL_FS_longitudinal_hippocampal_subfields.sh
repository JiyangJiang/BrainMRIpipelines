#!/bin/bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Note that longitudinal hippocampal subfields extraction in FS6.0.0
# requires large memory allocation.
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#$ -N M24_FreeSurfer_reconall
#$ -V
#$ -cwd
#$ -pe smp 2
#$ -q long.q
#$ -l h_vmem=16G
#$ -o /data2/heidi/MAS_W124/MW24/MW24_hippoSubfields.out
#$ -e /data2/heidi/MAS_W124/MW24/MW24_hippoSubfields.err
#$ -t 1-232

subjID=`cat /data2/heidi/MAS_W124/MW24/MW24.list | awk "NR==${SGE_TASK_ID}"`

module load fsl/5.0.11
module load freesurfer/6.0.0
module load matlab/MCR-R2012a

export SUBJECTS_DIR=/data2/heidi/MAS_W124/MW24

cd ${SUBJECTS_DIR}

rm -f ${SUBJECTS_DIR}/${subjID}/scripts/IsRunningLongHPsub.lh+rh

longHippoSubfieldsT1.sh ${subjID} ${SUBJECTS_DIR}