#!/bin/bash

# Note - work for two groups only

cohortFolder=$1

[ -f "${cohortFolder}/groupICA/subjID.in_order_of.input_list" ] && \
	rm -f ${cohortFolder}/groupICA/subjID.in_order_of.input_list

[ -f "${cohortFolder}/groupICA/grp_contrast.spmOrder" ] && \
	rm -f ${cohortFolder}/groupICA/grp_contrast.spmOrder

while read subjectsFolder
do
	subjID=$(basename ${subjectsFolder})

	echo ${subjID} >> ${cohortFolder}/groupICA/subjID.in_order_of.input_list

done < ${cohortFolder}/studyFolder.list

# merge subject's ID with design matrix
paste ${cohortFolder}/groupICA/subjID.in_order_of.input_list \
	  ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list \
	  > ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list.withSubjID

# vertically concatenate input.list.grp1.spm and input.list.grp2.spm
cat ${cohortFolder}/groupICA/input.list.grp1.spm > ${cohortFolder}/groupICA/input.list.grp12.spm
cat ${cohortFolder}/groupICA/input.list.grp2.spm >> ${cohortFolder}/groupICA/input.list.grp12.spm

while read fmri
do
	subjID=$(basename ${fmri} | awk -F '_' '{print $1}')

	# grep twice to avoid any covariate being the same as subjID
	cat ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list.withSubjID \
	    | grep -w "${subjID}" \
	    | grep "^${subjID}" \
	    | cut -f2- \
	    >> ${cohortFolder}/groupICA/grp_contrast.spmOrder

done < ${cohortFolder}/groupICA/input.list.grp12.spm




# regenerate GM covariate map
[ -f "${cohortFolder}/confounds/GMcovMap/spm.smwc1.list.spmOrder" ] && \
	rm -f ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list.spmOrder


while read img
do
	subjID=$(basename ${img} | awk -F '_' '{print $1}')

	ind_gm=`ls ${cohortFolder}/spm/grp*/smwc1${subjID}_anat.nii`

	echo "${ind_gm}" >> ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list.spmOrder

done < ${cohortFolder}/groupICA/input.list.grp12.spm

fslmerge -t ${cohortFolder}/confounds/GMcovMap/spm_smwc1_gmCovMap_spmOrder \
		 $(cat ${cohortFolder}/confounds/GMcovMap/spm.smwc1.list.spmOrder | tr '\n' ' ')