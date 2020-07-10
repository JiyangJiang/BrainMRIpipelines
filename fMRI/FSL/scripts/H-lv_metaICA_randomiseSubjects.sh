#!/bin/bash

# DESCRIPTION
# ====================================================================================
# 
# This script randomise subjects for meta ICA. Output folder is 
# {cohortFolder}/groupICA/metaICA/*indICAs_*
#
# For each individual ICA, preprocessed images are saved in
# {cohortFolder}/groupICA/metaICA/*indICAs_*/ICA_*/preproc_func
#
# A list of preprocessed iamges for each individual ICA will be saved in 
# {cohortFolder}/groupICA/metaICA/*indICAs_*/ICA_*/ICA_*_imgs.list
#
#
# USAGE
# ====================================================================================
#
# $1 = path to cohort folder
#
# $2 = conducting group ICA using 'grp1' or 'grp2' subsample or 'all' subjects
#
# $3 = number of subjects in each individual ICA.
#
# $4 = number of individual ICAs to be conducted.
#
# $5 = cleanup method at lower level. i.e. 'aroma' or 'fix'
#
# $6 = isotropic resampling scale
#
# $7 = 'yesQsub' or 'noQsub'
# 
# 
# OUTPUT
# ====================================================================================
#
# {cohortFolder}/groupICA/metaICA/*indICAs_*
#

. ${FSLDIR}/etc/fslconf/fsl.sh


cohortFolder=$1
grpICA_subsample=$2
N_subj_each_indICA=$3
N_indICA=$4
cleanup_mode=$5
iso_resample_scale=$6
qsub_flag=$7

date_suffix=$(date | sed 's/ //g' | sed 's/://g')

case ${grpICA_subsample} in

	grp1)
		echo "Randomising subjects for meta ICA in grp1 subsample ..."
		grpICA_subsample_studyFolder_list="${cohortFolder}/studyFolder.list.grp1"
		;;
	grp2)
		echo "Randomising subjects for meta ICA in grp2 subsample ..."
		grpICA_subsample_studyFolder_list="${cohortFolder}/studyFolder.list.grp2"
		;;
	all)
		echo "Randomising subjects for meta ICA in the whole sample ..."
		grpICA_subsample_studyFolder_list="${cohortFolder}/studyFolder.list"
		;;
esac

N_all_subj=`wc -l ${grpICA_subsample_studyFolder_list} | awk '{print $1}'`


if [ -f "${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.1" ]; then
	rm -f ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.1
fi

if [ -f "${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.2" ]; then
	rm -f ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.2
fi

for i in $(seq 1 ${N_indICA})
do
	mkdir -p ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_${date_suffix}/ICA_${i}/preproc_func

	# Randomise subjects for each individual ICA

	rand_num_list=`shuf -i 1-${N_all_subj} -n ${N_subj_each_indICA}`

	for j in $(seq 1 ${N_subj_each_indICA})
	do
		randomlySelected_studyFolder=`cat ${grpICA_subsample_studyFolder_list} | awk "NR==$(echo ${rand_num_list} | cut -d " " -f $j)"`
		randomlySelected_subjID=$(basename ${randomlySelected_studyFolder})

		case ${cleanup_mode} in

			aroma)
				postcleanup_folder="${randomlySelected_studyFolder}/${randomlySelected_subjID}_func.feat/post-ICA_AROMA"
				;;

			fix)
				postcleanup_folder="${randomlySelected_studyFolder}/${randomlySelected_subjID}_func.ica/post-FIX"
				;;
		esac

		echo "cp ${postcleanup_folder}/final_cleanedup_func_std_space.nii.gz ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_${date_suffix}/ICA_${i}/preproc_func/${randomlySelected_subjID}_final_cleanedup_func_std_space.nii.gz" \
				>> ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.1
		
	done

	# create image list for each individual ICA
	#
	# April 12, 2019 : randomise the order of the list of preprocessed fMRI data, to account for variability
	#                  of subjects order and initial parameters (see Wisner 2012)
	#
	echo "ls ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_${date_suffix}/ICA_${i}/preproc_func/*.nii* | shuf -n ${N_subj_each_indICA} > ${cohortFolder}/groupICA/metaICA/${N_indICA}indICAs_${date_suffix}/ICA_${i}/ICA_${i}_imgs.list" \
			>> ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.2
done

# do the job
if [ "${qsub_flag}" = "yesQsub" ]; then
	randSubj_1_jid=`$FSLDIR/bin/fsl_sub -T 120 -q short.q -N randSubj_1 -l ${cohortFolder}/SGE_commands/oe -t ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.1`
	randSubj_2_jid=`$FSLDIR/bin/fsl_sub -T 60  -q short.q -N randSubj_2 -l ${cohortFolder}/SGE_commands/oe -j ${randSubj_1_jid} -t ${cohortFolder}/SGE_commands/randomiseSubjects.fslsub.2`
fi
