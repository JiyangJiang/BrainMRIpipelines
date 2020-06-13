#!/bin/bash



. ${FSLDIR}/etc/fslconf/fsl.sh


cohortFolder=$1

cleanup_mode=$2

N_grps=$3

N_subj_each_indICA_commaDelimit=$4

# N_indICA_commaDelimit=$5
N_indICA=$5




# if [ -f "${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.1" ]; then
# 	rm -f ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.1
# fi

# if [ -f "${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.2" ]; then
# 	rm -f ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.2
# fi



date_suffix=$(date | sed 's/ //g' | sed 's/://g')



for i in $(seq 1 ${N_grps})
do
	
	N_subj_each_indICA=`echo ${N_subj_each_indICA_commaDelimit} | cut -d ',' -f ${i}`
	# N_indICA=`echo ${N_indICA_commaDelimit} | cut -d ',' -f ${i}`


	N_all_subj=`wc -l ${cohortFolder}/groupICA/input.list.grp${i}.spm | awk '{print $1}'`


	for j in $(seq 1 ${N_indICA})
	do
		mkdir -p ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}

		# Randomise subjects for each individual ICA

		rand_num_list=`shuf -i 1-${N_all_subj} -n ${N_subj_each_indICA}`


		for k in $(seq 1 ${N_subj_each_indICA})
		do
			randomlySelected_preproc_fmri=`cat ${cohortFolder}/groupICA/input.list.grp${i}.spm | awk "NR==$(echo ${rand_num_list} | cut -d " " -f $k)"`
			randomlySelected_subjID=$(basename ${randomlySelected_preproc_fmri} | cut -d '_' -f 1 | cut -d 'r' -f 2)

			# echo "cp ${randomlySelected_preproc_fmri} ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/preproc_func/${randomlySelected_subjID}_preproc_fMRI_DARTELspace.nii.gz" \
			# 		>> ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.1
			echo ${randomlySelected_preproc_fmri} \
				>> ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/ICA_${j}_imgs.list.tmp
		done

		# create image list for each individual ICA
		#
		# April 12, 2019 : randomise the order of the list of preprocessed fMRI data, to account for variability
		#                  of subjects order and initial parameters (see Wisner 2012)
		#
		# echo "ls ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/preproc_func/${randomlySelected_subjID}_preproc_fMRI_DARTELspace.nii.gz | shuf -n ${N_subj_each_indICA} > ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/ICA_${j}_imgs.list" \
		# 		>> ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.2
		cat ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/ICA_${j}_imgs.list.tmp | shuf -n ${N_subj_each_indICA} \
			> ${cohortFolder}/groupICA/metaICA_spm/${N_indICA}indICAs_${date_suffix}/grp${i}/ICA_${j}/ICA_${j}_imgs.list
	done

done

# do the job
# if [ "${qsub_flag}" = "yesQsub" ]; then
# 	randSubj_1_jid=`$FSLDIR/bin/fsl_sub -T 120 -q short.q -N randSubj_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.1`
# 	randSubj_2_jid=`$FSLDIR/bin/fsl_sub -T 60  -q short.q -N randSubj_2 -l ${cohortFolder}/SGE_commands/oe -j ${randSubj_1_jid} -t ${cohortFolder}/SGE_commands/spm.randomiseSubjects.fslsub.2`
# fi
