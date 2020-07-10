#!/bin/bash


# DESCRIPTION
# ===========================================================================================
#
# This script runs dual regression to the melodic IC map from meta ICA.
#
#
# USAGE
# ===========================================================================================
#
# $1 = path to cohort folder
#
# $2 = number of individual ICAs
#
# $3 = dimensionality of meta ICA
#
# $4 = basename of the design matrix (without .mat) to test
#
# $5 = number of permutations
#
# $6 = use original melodic_IC map derived from meta-ICA ('orig'), orig with appending WM
#      and CSF ('orig_WMCSFappended'), melodic_IC map after
#      removing noise volumes which are defined as spatial correlation lower than 0.6
#      with all melodic_IC maps from individual ICA ('noiseRemoved'), or melodic_IC map
#      after removing noise volumes with spatial correlation less than 0.6 AND appending
#      WM and CSF masks ('noiseRemoved_WMCSFappended')
#
# ===========================================================================================

cohortFolder=$1

N_indICA=$2
N_dim_metaICA=$3

des_mtx_basename=$4
Nperm=$5

melodicIC2use=$6

if [ -f "${cohortFolder}/SGE_commands/metaICA_dualReg.fslsub" ]; then
	rm -f ${cohortFolder}/SGE_commands/metaICA_dualReg.fslsub
fi

module load fsl/5.0.11

curr_dir=$(dirname $(which $0))

for i in `ls -d ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_*/metaICA/d${N_dim_metaICA}`
do
	random_suffix=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10)

	case ${melodicIC2use} in

		orig)
			melodicIC=${i}/melodic_IC
			;;

		orig_WMCSFappended)
			fslroi ${i}/melodic_IC_noiseRemoved_WMCSFappended \
				   ${i}/wmcsf_IC \
				   $(($(fslnvols ${i}/melodic_IC_noiseRemoved_WMCSFappended) - 2)) \
				   -1

			fslmerge -t ${i}/melodic_IC_WMCSFappended \
					 ${i}/melodic_IC \
					 ${i}/wmcsf_IC

			melodicIC=${i}/melodic_IC_WMCSFappended
			;;

		noiseRemoved)
			melodicIC=${i}/melodic_IC_noiseRemoved
			;;
			
		noiseRemoved_WMCSFappended)
			melodicIC=${i}/melodic_IC_noiseRemoved_WMCSFappended
			;;
		
	esac


	# 2019 May 29 : use whole brain mask for randomise, instead of mask derived from SD maps.
	# 2019 June 3 : mask SD mask with brain mask
	${curr_dir}/dual_regression_Jmod_demean_withinBrain ${melodicIC} \
														1 \
														${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.mat \
														${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.con \
														${Nperm} \
														${cohortFolder}/groupICA/${des_mtx_basename}_dualReg_rand_results_metaICA_${random_suffix} \
														$(cat ${cohortFolder}/groupICA/input.list | tr '\n' ' ')


	# ${curr_dir}/dual_regression_Jmod_demean ${melodicIC} \
	# 										1 \
	# 										${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.mat \
	# 										${cohortFolder}/groupICA/des_mtx/${des_mtx_basename}.con \
	# 										${Nperm} \
	# 										${cohortFolder}/groupICA/${des_mtx_basename}_dualReg_rand_results_metaICA_${random_suffix} \
	# 										$(cat ${cohortFolder}/groupICA/input.list | tr '\n' ' ')
done