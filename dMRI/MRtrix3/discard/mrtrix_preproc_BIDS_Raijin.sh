#!/bin/bash

# =================================================== #
# This script distributes to GPU nodes for eddy_cuda. #
# Data needs to be in BIDS format.                    #
# =================================================== #

# NOTE THAT RAIJIN ONLY ALLOWS 200 GPU JOBS QUEUED FOR ONE PROJECT


Raijin_eddy(){

	BIDS_folder=$1

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "${BIDS_folder}/derivatives/mrtrix/preproc" ]; then
		rm -fr ${BIDS_folder}/derivatives/mrtrix/preproc
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc


	for unr_img in `ls unring/nii/*_unr.nii.gz`
	do
		subjID=$(echo $(basename ${unr_img}) | awk -F '_' '{print $1}')

		if [ -d "${BIDS_folder}/derivatives/mrtrix/preproc/${subjID}_eddy" ]; then
			rm -fr ${BIDS_folder}/derivatives/mrtrix/preproc/${subjID}_eddy
		fi
		mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc/${subjID}_eddy

		subj_eddy_out_folder=${BIDS_folder}/derivatives/mrtrix/preproc/${subjID}_eddy

		## Project ID
		echo "#PBS -P ba64" > ${subj_eddy_out_folder}/raijin_cmd.txt

		## Queue type
		echo "#PBS -q gpu" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## Wall time
		echo "#PBS -l walltime=00:30:00" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## Number of GPU and CPU cores
		echo "#PBS -l ngpus=2" >> ${subj_eddy_out_folder}/raijin_cmd.txt
		echo "#PBS -l ncpus=6" >> ${subj_eddy_out_folder}/raijin_cmd.txt
 
		## requested memory per node
		echo "#PBS -l mem=16GB" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## Disk space
		echo "#PBS -l jobfs=1GB" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## Job is excuted from current working dir instead of home
		echo "#PBS -l wd" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## load cuda
		echo "module load cuda/7.5" >> ${subj_eddy_out_folder}/raijin_cmd.txt

		## run fsl_newEddyCorrection.sh
		DWI_folder=$(dirname $(dirname $(which $0)))
		unr_img_abspath=${BIDS_folder}/derivatives/mrtrix/${unr_img}
		invPE_b0=no_invPE
		acqparamsTXT=easy_acq_updown
		bvec=${BIDS_folder}/derivatives/mrtrix/$(echo ${unr_img} | awk -F '.' '{print $1}').bvec
		bval=${BIDS_folder}/derivatives/mrtrix/$(echo ${unr_img} | awk -F '.' '{print $1}').bval
		topup_flag=noTopup
		slm_option=linear
		line_index=1
		eddy_cmd=eddy_cuda

		echo "${DWI_folder}/FSL/fsl_newEddyCorrection.sh ${unr_img_abspath} ${invPE_b0} ${acqparamsTXT} ${bvec} ${bval} ${subj_eddy_out_folder} ${topup_flag} ${slm_option} ${line_index} ${eddy_cmd}" >> ${subj_eddy_out_folder}/raijin_cmd.txt


		qsub ${subj_eddy_out_folder}/raijin_cmd.txt
	done

}

Raijin_eddy $1