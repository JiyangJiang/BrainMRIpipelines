#!/bin/bash

subj_SCA(){

	cohortFolder=$1
	ID=$2
	cleanup_type=$3
	MNI_seed=$4

	if [ -d "${cohortFolder}/${ID}/seed-based" ]; then
		rm -fr ${cohortFolder}/${ID}/seed-based
	fi

	mkdir ${cohortFolder}/${ID}/seed-based

	case ${cleanup_type} in
		
		fix)
			final_fMRI=${cohortFolder}/${ID}/${ID}_func.ica/post-FIX/final_cleanedup_func_std_space.nii.gz
			;;

		aroma)
			final_fMRI=${cohortFolder}/${ID}/${ID}_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space.nii.gz
			;;
	esac

	cp ${final_fMRI} ${cohortFolder}/${ID}/seed-based/.
	# cp ${MNI_seed} ${cohortFolder}/${ID}/seed-based/.

	# use the first volume as example_func for copying geometry info to resultant correlation coefficient map
	fslroi ${cohortFolder}/${ID}/seed-based/final_cleanedup_func_std_space.nii.gz \
		   ${cohortFolder}/${ID}/seed-based/mni_example_func \
		   0 1

	curr_dir=$(dirname $(which $0))

	# MNI-space individual seed-base correlation
	seed_nii=${MNI_seed}
	func_data=${cohortFolder}/${ID}/seed-based/final_cleanedup_func_std_space.nii.gz
	example_func=${cohortFolder}/${ID}/seed-based/mni_example_func.nii.gz
	fsl_dir=${FSLDIR}
	output_dir=${cohortFolder}/${ID}/seed-based

	matlab -nodisplay -nosplash -r "addpath ('${curr_dir}');\
									H_lv_seedbased_corrCoeffMap ('${seed_nii}', \
																 '${func_data}', \
																 '${example_func}', \
																 '${fsl_dir}', \
																 '${output_dir}');\
									exit"


	echo ${ID} seed based correlation map completed.

}

subj_SCA $1 $2 $3 $4