#!/bin/bash


cohortFolder=$1
N_indICA=$2
N_dim_indICA=$3
tr=$4
N_grps=$5
qsub_flag=$6


if [ -f "${cohortFolder}/SGE_commands/spm.indICA.fslsub" ]; then
	rm -f ${cohortFolder}/SGE_commands/spm.indICA.fslsub
fi

for grpID in $(seq 1 ${N_grps})
do

	for imgList in `ls -d ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_*/grp${grpID}/ICA_*/ICA_*_imgs.list`
	do
		if [ "${N_dim_indICA}" = "auto" ]; then

			$FSLDIR/bin/fslecho "melodic -i ${imgList} \
										 -o \$(dirname ${imgList})/d${N_dim_indICA} \
										 --tr=${tr} \
										 --nobet \
										 --bgthreshold=1 \
										 -a concat \
										 --bgimage=${cohortFolder}/spm/grp${grpID}/grp${grpID}_brain \
										 -m ${cohortFolder}/spm/grp${grpID}/grp${grpID}_brain_mask \
										 --report \
										 --mmthresh=0.5 \
										 --Oall" \
				>> ${cohortFolder}/SGE_commands/spm.indICA.fslsub

		else

			$FSLDIR/bin/fslecho "melodic -i ${imgList} \
										 -o \$(dirname ${imgList})/d${N_dim_indICA} \
										 --tr=${tr} \
										 --nobet \
										 --bgthreshold=1 \
										 -a concat \
										 --bgimage=${cohortFolder}/spm/grp${grpID}/grp${grpID}_brain \
										 -m ${cohortFolder}/spm/grp${grpID}/grp${grpID}_brain_mask \
										 --report \
										 --mmthresh=0.5 \
										 --Oall \
										 -d ${N_dim_indICA}" \
				>> ${cohortFolder}/SGE_commands/spm.indICA.fslsub

		fi
	done
done

if [ "${qsub_flag}" = "yesQsub" ]; then
	indICA_jid=$($FSLDIR/bin/fsl_sub -T 1000 \
									 -q bigmem.q \
									 -N indICA \
									 -l ${cohortFolder}/SGE_commands/oe \
									 -t ${cohortFolder}/SGE_commands/spm.indICA.fslsub)
fi
