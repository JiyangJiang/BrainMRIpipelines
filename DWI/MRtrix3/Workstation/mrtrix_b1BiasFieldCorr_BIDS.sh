#!/bin/bash

# DESCRIPTION :
# -------------------------------------------------------------------------------------------------------------------
#
# This script calls dwibiascorrect to corect for b1 field inhomogeneity.
#
# USAGE :
# -------------------------------------------------------------------------------------------------------------------
#
# $1 = path to BIDS project folder
#
# $2 = 'sin' or 'Mcore'
#
# -------------------------------------------------------------------------------------------------------------------
#
# Dr. Jiyang Jiang           January 29, 2019
#
# -------------------------------------------------------------------------------------------------------------------

biascorrect(){

	BIDS_folder=$1
	par_mode=$2

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "${BIDS_folder}/derivatives/mrtrix/biascorrect" ]; then
		rm -fr ${BIDS_folder}/derivatives/mrtrix/biascorrect
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/biascorrect


	for preproc_mif in `ls preproc/*_unr_preproc.mif`
	do
		preproc_mif_filename=$(echo $(basename ${preproc_mif}) | awk -F '.' '{print $1}')

		case ${par_mode} in

			sin)

				dwibiascorrect -ants \
							   ${preproc_mif} \
							   ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_unbiased.mif \
							   -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_bias.mif
				;;

			Mcore)

				dwibiascorrect -ants \
							   ${preproc_mif} \
							   ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_unbiased.mif \
							   -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${preproc_mif_filename}_bias.mif \
							   &
				;;

		esac

		# check - not exceeding number of cores
		unameOut="$(uname -s)"
		case "${unameOut}" in
		    Linux*)
				machine=Linux
				# at most number of CPU cores
				[ $(jobs | wc -l) -ge $(python -c "print ($(nproc)/2)") ] && wait
				;;

		    Darwin*)
				machine=Mac
				# at most number of CPU cores
				[ $(jobs | wc -l) -ge $(python -c "print ($(sysctl -n hw.physicalcpu)/2)") ] && wait
				;;

		    CYGWIN*)    machine=Cygwin;;
		    MINGW*)     machine=MinGw;;
		    *)          machine="UNKNOWN:${unameOut}"
		esac
	done
}

biascorrect $1 $2