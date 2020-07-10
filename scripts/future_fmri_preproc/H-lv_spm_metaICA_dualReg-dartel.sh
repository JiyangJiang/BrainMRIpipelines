#!/bin/bash

cohortFolder=$1
N_grps=$2
N_indICA=$3
N_dim_metaICA=$4
des_mtx_basename=$5
Nperm=$6
qsub_flag=$7


curr_dir=$(dirname $(which $0))



rm -fr ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp*/*


for i in $(seq 1 ${N_grps})
do
	LOGDIR=${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp${i}/scripts+logs

	[ -f "${LOGDIR}/drC_dartel" ] && rm -f ${LOGDIR}/drC_dartel

	mkdir -p ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp${i}


	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# April 29, 2019 : after DARTEL, the background will have subtle
	#                  intensity changes between TRs. Therefore, using
	#                  the FSL way (i.e. fslmaths -Tstd) will include
	#                  background in the mask. Hence, I decided to
	#                  use SPM mask directly.
	# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	# Step 1) make mask
	# --------------------------------------------------------------------------------------------
	cp ${cohortFolder}/spm/grp${i}/grp${i}_brain_mask.nii.gz \
		${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp${i}/mask_dartel.nii.gz


	for j in $(ls -d ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_*/grp${i}/metaICA/d${N_dim_metaICA})
	do
		melodicIC=${j}/melodic_IC.nii.gz


		# Step 2) dual regression
		# --------------------------------------------------------------------------------------------
		${curr_dir}/dual_regression_Jmod_demean.spm.dualReg.dartel  ${melodicIC} \
																	1 \
																	${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.mat \
																	${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.con \
																	${Nperm} \
																	${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/grp${i} \
																	$(cat ${cohortFolder}/groupICA/input.list.grp${i}.spm | tr '\n' ' ')
	done

	if [ "${qsub_flag}" = "yesQsub" ]; then
		ID_drC=`$FSLDIR/bin/fsl_sub -T 30 -N drC -l $LOGDIR -t ${LOGDIR}/drC_dartel`
	fi
done


