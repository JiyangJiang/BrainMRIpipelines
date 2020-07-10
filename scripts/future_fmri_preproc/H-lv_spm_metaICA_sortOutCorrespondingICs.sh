#!/bin/bash

# only works for two groups

cohortFolder=$1
des_mtx_basename=$2
N_dim_metaICA=$3

fslcc_output=${cohortFolder}/groupICA/${des_mtx_basename}_d${N_dim_metaICA}/fslcc.output

[ -f "${cohortFolder}/SGE_commands/mergeSubj4correspondingICs.fslsub" ] && \
	rm -f ${cohortFolder}/SGE_commands/mergeSubj4correspondingICs.fslsub


mkdir -p $(dirname ${fslcc_output})/correspondingICs

Nrows_fslcc_output=`wc -l ${fslcc_output}`

j=0

while read line
do
	idx_grp1=$(echo ${line} | awk '{print $1}')
	idx_grp2=$(echo ${line} | awk '{print $2}')

	idx_grp1_startingFrom0=$((${idx_grp1} - 1))
	idx_grp2_startingFrom0=$((${idx_grp2} - 1))

	idx_grp1_startingFrom0_zeropad=`$FSLDIR/bin/zeropad ${idx_grp1_startingFrom0} 4`
	idx_grp2_startingFrom0_zeropad=`$FSLDIR/bin/zeropad ${idx_grp2_startingFrom0} 4`

	idx_consensusIC=`$FSLDIR/bin/zeropad ${j} 4`


	list=""
	list_grp1=`$FSLDIR/bin/imglob $(dirname ${fslcc_output})/grp1/dr_stage2_subject*_ic${idx_grp1_startingFrom0_zeropad}_affine2mni.*`
	list_grp2=`$FSLDIR/bin/imglob $(dirname ${fslcc_output})/grp2/dr_stage2_subject*_ic${idx_grp2_startingFrom0_zeropad}_affine2mni.*`
	list="${list_grp1} ${list_grp2}"

	# echo ${list} | tr ' ' '\n' > $(dirname ${fslcc_output})/correspondingICs/IC${idx_consensusIC}_spmOrder.list

	fslroi $(dirname ${fslcc_output})/melodicIC_thr_grp1 \
		   $(dirname ${fslcc_output})/correspondingICs/IC${idx_consensusIC}_grp1_illustration \
		   ${idx_grp1_startingFrom0} \
		   1

	fslroi $(dirname ${fslcc_output})/melodicIC_thr_grp2 \
		   $(dirname ${fslcc_output})/correspondingICs/IC${idx_consensusIC}_grp2_illustration \
		   ${idx_grp2_startingFrom0} \
		   1

cat << EOF >> ${cohortFolder}/SGE_commands/mergeSubj4correspondingICs.fslsub
$FSLDIR/bin/fslmerge -t $(dirname ${fslcc_output})/correspondingICs/IC${idx_consensusIC}_spmOrder ${list}
EOF


	j=`echo "$j 1 + p" | dc -`

done < ${fslcc_output}

# $FSLDIR/bin/fsl_sub -T 60 \
# 					-q bigmem.q \
# 					-N merge_subj_for_correspondingICs \
# 					-l ${cohortFolder}/SGE_commands/oe \
# 					-t ${cohortFolder}/SGE_commands/mergeSubj4correspondingICs.fslsub
