#!/bin/bash

# DESCRIPTION
# --------------------------------------------------------------------------------------------------
# This script will recon-all all sub-* in BIDS format on Raijing. Compatible with single or multiple
# T1w acquisitions.
#
#
# PRE-ASSUMPTION
# --------------------------------------------------------------------------------------------------
# None
#
#
# USAGE
# --------------------------------------------------------------------------------------------------
# $1 = path to BIDS folder
#
# $2 = project_ID (e.g. 'ey6', 'ba64')
#
# $3 = 'subq' or 'noSubq'. noSubq may be useful for job dependency, i.e. wait for other scipt to
#      finish to execute this one.
#
#
# NOTES AND REFERENCES
# --------------------------------------------------------------------------------------------------
# None
#
#
# --------------------------------------------------------------------------------------------------
#
# Dr. Jiyang Jiang, February 2019
#
# --------------------------------------------------------------------------------------------------


recon-all_BIDS_Raijin(){

BIDS_folder=$1
project_ID=$2
subq_flag=$3

studyFolder="${BIDS_folder}/derivatives/freesurfer/recon-all"

if [ -d "${studyFolder}" ]; then
	rm -fr ${studyFolder}
fi
mkdir -p ${studyFolder}

if [ -d "${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all" ]; then
	rm -fr ${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all
fi
mkdir -p ${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all/oe

cd ${BIDS_folder}


## delete IsRunning
# rm -f ${studyFolder}/*/scripts/IsRunning.lh+rh

for subjID in `ls -d sub-*`
do
	str=""

	for i in `ls ${subjID}/anat/${subjID}_*T1w.nii*`
 	do
 		cp ${i} ${BIDS_folder}/derivatives/freesurfer/recon-all/.

 		str="${str} -i ${BIDS_folder}/derivatives/freesurfer/recon-all/$(basename ${i})"
 	done

	
	raijin_reconall_cmd="${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all/${subjID}_raijin_reconall_cmd.txt"


	##Project ID
	echo "#PBS -P ${project_ID}" > ${raijin_reconall_cmd}

	##Queue type
	echo "#PBS -q normal" >> ${raijin_reconall_cmd}

	##Wall time
	## recon-all -all will take 20-40 hours
	## recon-all -hippocampal-subfields-T1 will take ~50 min on top of recon-all -all
	echo "#PBS -l walltime=20:00:00" >> ${raijin_reconall_cmd}

	##Number of CPU cores
	echo "#PBS -l ncpus=1" >> ${raijin_reconall_cmd}

	##requested memory per node
	echo "#PBS -l mem=4GB" >> ${raijin_reconall_cmd}

	##Disk space
	echo "#PBS -l jobfs=2GB" >> ${raijin_reconall_cmd}

	##Job is excuted from current working dir instead of home
	echo "#PBS -l wd" >> ${raijin_reconall_cmd}

	## Redirect output and error
	echo "#PBS -e ${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all/oe/${subjID}.err" >> ${raijin_reconall_cmd}
	echo "#PBS -o ${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all/oe/${subjID}.out" >> ${raijin_reconall_cmd}

	##Send email when begin, abort, end
	# echo "#PBS -M jiyang.jiang@unsw.edu.au" >> cmd_${i}.txt
	# echo "#PBS -m abe" >> cmd_${i}.txt

	# --> Use my local freesurfer 6.0.0 now
	## use NCI's freesurfer/6.0.0
	# echo "module load freesurfer/6.0.0" >> ${raijin_reconall_cmd}
	# echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >> ${raijin_reconall_cmd}
	# echo "source \$FREESURFER_HOME/FreeSurferEnv.sh" >> ${raijin_reconall_cmd}
	
	## load MATLAB - used R2012b runtime in calculating hippocampal subfields
	## not needed now as installed R2012b runtime in local freesurfer folder
	# echo "module load matlab/R2012b" >> cmd_${i}.txt
	# echo "ln -s /apps/matlab/R2012b \$FREESURFER_HOME/MCRv80" >> cmd_${i}.txt

	## SUBJECTS_DIR
	echo "export SUBJECTS_DIR=${studyFolder}" >> ${raijin_reconall_cmd}

	## FS command
	echo "recon-all -subject ${subjID} ${str} -all" >> ${raijin_reconall_cmd}

	## submit job
	case ${subq_flag} in
		subq)
			qsub -N ${subjID}_freesurfer_reconall \
				 ${raijin_reconall_cmd}
			;;
		noSubq)
			# not qsub
			;;
	esac

done

}

recon-all_BIDS_Raijin $1 $2 $3

