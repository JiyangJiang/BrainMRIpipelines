#!/bin/bash

Raijin_eddy_prep(){

	BIDS_folder=$1

	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "unring/nii" ]; then
		rm -fr unring/nii
	fi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring/nii

	# separate mif into nii+bvec+bval
    for unr_mif in `ls unring/*_unr.mif`
	do

		# convert mif to nii/bvec/bval
		unr_mif_filename=$(echo $(basename ${unr_mif}) | awk -F '.' '{print $1}')
		mrconvert -export_grad_fsl unring/nii/${unr_mif_filename}.bvec \
								   unring/nii/${unr_mif_filename}.bval \
				  ${unr_mif} \
				  unring/nii/${unr_mif_filename}.nii.gz \
				  &

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

	# wait until conversion finishes
	[ $(jobs | wc -l) -ge "0" ] && wait

	# Raijin only allows 200 GPU jobs queued
	ls unring/nii/*.nii.gz > unring/nii/unring_nii.list
	N_unr_nii=$(wc -l unring/nii/unring_nii.list | awk '{print $1}')

	if [ "${N_unr_nii}" -gt "200" ]; then
		cd unring/nii
		echo "There are ${N_unr_nii} unring nii - spliting into parts (200 each) for Raijin GPU processing."
		split -l 200 unring_nii.list

		for part in `ls x*`
		do
			mkdir part_${part}
			while read unr_nii
			do
				subjID=`echo $(basename ${unr_nii}) | awk -F '_' '{print $1}'`
				mv ${subjID}* part_${part}
			done < ${part}
		done
	fi

}

Raijin_eddy_prep $1