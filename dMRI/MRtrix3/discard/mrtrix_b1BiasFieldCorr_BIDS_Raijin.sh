#!/bin/bash

# =========================================================== #
# This script distributes to normal nodes for dwibiascorrect. #
# Data needs to be in BIDS format.                            #
# =========================================================== #


Raijin_unbias(){

	BIDS_folder=$1

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -f "${BIDS_folder}/derivatives/mrtrix/biascorrect" ]; then
		rm -fr ${BIDS_folder}/derivatives/mrtrix/biascorrect
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/biascorrect


	for preproc_mif in `ls preproc/*_unr_preproc.mif`
	do
		subjID=$(echo $(basename ${preproc_mif}) | awk -F '_' '{print $1}')

		preproc_mif_filename=$(echo $(basename ${preproc_mif}) | awk -F '.' '{print $1}')

		raijin_cmd=${BIDS_folder}/derivatives/mrtrix/biascorrect/${subjID}_dwibiascorrect_raijin_cmd.txt

		## Project ID
		echo "#PBS -P ba64" > ${raijin_cmd}

		## Queue type
		echo "#PBS -q normal" >> ${raijin_cmd}

		## Wall time
		echo "#PBS -l walltime=01:00:00" >> ${raijin_cmd}

		## Number of CPU cores
		echo "#PBS -l ncpus=1" >> ${raijin_cmd}
 
		## requested memory per node
		echo "#PBS -l mem=4GB" >> ${raijin_cmd}

		## Disk space
		echo "#PBS -l jobfs=1GB" >> ${raijin_cmd}

		## Job is excuted from current working dir instead of home
		echo "#PBS -l wd" >> ${raijin_cmd}

		## run dwibiascorrect
		echo "dwibiascorrect -ants ${preproc_mif} ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_unbiased.mif -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_bias.mif " >> ${raijin_cmd}


		qsub ${raijin_cmd}
	done

}

Raijin_unbias $1