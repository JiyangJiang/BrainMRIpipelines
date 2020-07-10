#!/bin/bash

# DESCRIPTION
# ====================================================================================================
#
# This script conducts individual ICAs.
#
#
# USAGE
# ====================================================================================================
#
# $1 = path to cohort folder
#
# $2 = number of individual ICAs to be conducted
#
# $3 = dimensionality for individual ICA
#
# $4 = isotropic resampling scale. This should agree with the same parameter
#      passed to previous scripts.
#
# $5 = pass TR in seconds.
#
# $6 = number of CPU cores to be used, or 'par_cluster'
#
# $7 = 'yesQsub' or 'noQsub'
#
# ====================================================================================================

cohortFolder=$1
N_indICA=$2
N_dim_indICA=$3
resample_scale=$4
tr=$5
Ncpus=$6
qsub_flag=$7



# resample MNI brain and mask
mkdir -p ${cohortFolder}/groupICA/resampled_MNI

flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -omat ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
	  -dof 6 \
	  -nosearch

flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -applyisoxfm ${resample_scale} \
	  -init ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
	  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm

flirt -in ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz \
	  -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
	  -applyisoxfm ${resample_scale} \
	  -init ${cohortFolder}/groupICA/resampled_MNI/MNI2MNI.mat \
	  -out ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm

# if $tr = empty, extract TR from func
if [ -z ${tr+x} ]; then
	eg_func=`ls $(head -n 1 ${cohortFolder}/studyFolder.list)/*_func.nii*`
	tr=`fslval ${eg_func} pixdim4`
fi

re='^[0-9]+$'

if [[ ${Ncpus} =~ $re ]]; then

	for i in $(seq 1 ${N_indICA})
	do
		for j in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*`
		do
			if [ "${N_dim_indICA}" = "auto" ]; then

				
				melodic -i ${j}/ICA_${i}/ICA_${i}_imgs.list \
						-o ${j}/ICA_${i}/d${N_dim_indICA} \
						--tr=${tr} \
						--nobet \
						--bgthreshold=1 \
						-a concat \
						--bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm \
						-m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm \
						--report \
						--mmthresh=0.5 \
						--Oall \
						&
				
			else

				melodic -i ${j}/ICA_${i}/ICA_${i}_imgs.list \
						-o ${j}/ICA_${i}/d${N_dim_indICA} \
						--tr=${tr} \
						--nobet \
						--bgthreshold=1 \
						-a concat \
						--bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm \
						-m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm \
						--report \
						--mmthresh=0.5 \
						--Oall \
						-d ${N_dim_indICA} \
						&

			fi

			[ $(jobs | wc -l) -gt ${Ncpus} ] && wait
		done
	done

	# wait all background jobs to finish
	wait

elif [ "${Ncpus}" = "par_cluster" ]; then

	if [ -f "${cohortFolder}/SGE_commands/indICA.fslsub" ]; then
		rm -f ${cohortFolder}/SGE_commands/indICA.fslsub
	fi


	for imgList in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*/ICA_*/ICA_*_imgs.list`
	do
		if [ "${N_dim_indICA}" = "auto" ]; then

			$FSLDIR/bin/fslecho "melodic -i ${imgList} -o \$(dirname ${imgList})/d${N_dim_indICA} --tr=${tr} --nobet --bgthreshold=1 -a concat --bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm -m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm --report --mmthresh=0.5 --Oall" \
				>> ${cohortFolder}/SGE_commands/indICA.fslsub

		else

			$FSLDIR/bin/fslecho "melodic -i ${imgList} -o \$(dirname ${imgList})/d${N_dim_indICA} --tr=${tr} --nobet --bgthreshold=1 -a concat --bgimage=${cohortFolder}/groupICA/resampled_MNI/MNI_brain_${resample_scale}mm -m ${cohortFolder}/groupICA/resampled_MNI/MNI_brain_mask_${resample_scale}mm --report --mmthresh=0.5 --Oall -d ${N_dim_indICA}" \
				>> ${cohortFolder}/SGE_commands/indICA.fslsub

		fi
	done

	if [ "${qsub_flag}" = "yesQsub" ]; then
		indICA_jid=$($FSLDIR/bin/fsl_sub -T 1000 -q long.q -N indICA -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/indICA.fslsub)
	fi

fi