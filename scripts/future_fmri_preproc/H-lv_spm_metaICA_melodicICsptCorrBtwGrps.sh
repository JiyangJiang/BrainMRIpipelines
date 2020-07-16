#!/bin/bash

# Note that this script only deals with two groups

cohortFolder=$1

N_grps=$2

N_indICA=$3
N_dim_metaICA=$4

des_mtx_basename=$5



for i in $(seq 1 ${N_grps})
do
	for j in $(ls -d ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_*/grp${i}/metaICA/d${N_dim_metaICA})
	do
		fslmaths ${j}/melodic_IC_affine2mni \
				 -thr 3.2 \
				 ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/melodicIC_thr_grp${i}
	done
done

fslcc --noabs \
	  -p 4 \
	  -t 0.6 \
	  ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/melodicIC_thr_grp1 \
	  ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/melodicIC_thr_grp2 \
	  > ${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/fslcc.output