#!/bin/bash

cohortFolder=$1
N_grps=$2
N_indICA=$3
N_dim_metaICA=$4
des_mtx_basename=$5
iso_resample_scale=$6
qsub_flag=$7



curr_dir=$(dirname $(which $0))


for i in $(seq 1 ${N_grps})
do

	list=""


	for j in $(ls -d ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_*/grp${i}/metaICA/d${N_dim_metaICA})
	do
		# template to affine to MNI
		list="${list},${j}/melodic_IC.nii.gz"
	done


	# brain and brain mask to affine to MNI
	list="${list},${cohortFolder}/spm/grp${i}/grp${i}_brain.nii.gz,${cohortFolder}/spm/grp${i}/grp${i}_brain_mask.nii.gz"
	

	for k in $(ls -d ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp${i})
	do
		rm -f ${k}/dr_stage2_subject*_ic*_affine2mni.nii.gz
		
		for m in `ls ${k}/dr_stage2_subject*_ic*.nii.gz`
		do
			# individual spatial map to affine to MNI
			list="${list},${m}"
		done
	done

	# remove the first comma
	list=$(echo ${list} | sed 's/^,//g')

	# write to a file, otherwise argument list is too long
	echo ${list} > ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/reg.list.grp${i}

	# affine register to MNI
	${curr_dir}/FUNCTION_affineDARTEL2MNI.sh ${cohortFolder}/spm/grp${i}/Template_6.nii \
											 ${iso_resample_scale} \
											 ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/reg.list.grp${i} \
											 ${qsub_flag}

done

