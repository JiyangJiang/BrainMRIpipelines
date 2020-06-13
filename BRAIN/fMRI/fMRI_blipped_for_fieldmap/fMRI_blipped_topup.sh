#!/bin/bash

. ${FSLDIR}/etc/fslconf/fsl.sh

fMRI_blipped_topup(){
	subjects_folder=$1
	ID=$2

	topup_wd=${subjects_folder}/${ID}/fMRI/fMRI_blipped_for_fieldmap
	curr_folder=$(dirname $0)

	echo "fMRI_blipped_topup.sh: Performing topup for ${ID} ..."
	topup --imain=${topup_wd}/${ID}_blipped_pairs \
		  --datain=${curr_folder}/acqparams_blippedFMRI.txt \
		  --config=${curr_folder}/b02b0.cnf \
		  --fout=${topup_wd}/${ID}_topup_fieldmap \
		  --iout=${topup_wd}/${ID}_topup_unwarped \
		  --out=${topup_wd}/${ID}_topup_output


	echo "fMRI_blipped_topup.sh: Performaing applytopup for ${ID} ..."
	applytopup --imain=${topup_wd}/${ID}_fMRI_raw.nii \
			   --datain=${curr_folder}/acqparams_blippedFMRI.txt \
			   --inindex=1 \
			   --topup=${topup_wd}/${ID}_topup_output \
			   --out=${topup_wd}/${ID}_applytopup_output \
			   --method=jac
		  
	echo "fMRI_blipped_topup.sh: Finished."

}

fMRI_blipped_topup $1 $2