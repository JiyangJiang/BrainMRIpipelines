#!/bin/bash

# ==================================================================================================
# This script creates 1) ${studyFolder}/${studyFolder}_grp_assignment.txt
#                        ------------------------------------------------
#                        indicating whether grp_1 or grp_2.
#
#                     2) ${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list
#                        ---------------------------------------------------------------------
#                        group assignment for each subject in the cohort, in the order of
#                        ${cohortFolder}/groupICA/input.list
#
#                     3) ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
#                        ------------------------------------------------------------
#                        [1 0] and [0 1] contrastswhich is in the same order as 
#                        cohortFolder/groupICA/input.list and can be used to create design matrix.
#
# This script requires 1) ${cohortFolder}/groupICA/grp1.list & ${cohortFolder}/groupICA/grp2.list
#                         -----------------------------------------------------------------------
#                         The list of subject IDs assgined to corresponding group. The list can
#                         be in any order, without header. IDs listed in these two files
#                         can be more than subject folders within cohort folder, but all subject
#                         folders in the cohort folder should have corresponding entries.
#
#                      2) Optionally, the csv file of covariates
#                         -----------------------------------------------------------------------
#                         The first column should be subject ID (i.e. same as study folder name).
#                         This csv file can be in any order. This csv file can have more IDs than
#                         in subject folders in the cohort folder, but the subject folders in the
#                         cohort folder (i.e. the subjects listed in studyFolder.list) should all
#                         have corresponding entries in this csv covariate file.
#
# ==================================================================================================
# USAGE : 
#        $1 : path to cohort folder.
#        $2 : cleanup mode ('aroma' or 'fix')
#        $3 : Optional - path to covariants csv file. First column needs to be ID (i.e. same as
#                        study folder name). Can be in any order.
#        $4 : Optional - if covariants csv is given to $3, $4 will be the number of covariants.
# ==================================================================================================

assign_grp(){

	cohortFolder=$1
	cleanup_mode=$2
	covariants_csv=$3

	if [ "${covariants_csv}" = "" ]; then
		cov_flag=noCov
	else
		cov_flag=yesCov
		Ncov=$4
	fi


	# Writing *${studyFolder}/${studyFolder}_grp_assignment.txt*
	# ----------------------------------------------------------
	while read grp1_subj
	do
		# in case subject folder is moved to excessive_motion
		if [ -d "${cohortFolder}/${grp1_subj}" ]; then

			echo "grp_1" > ${cohortFolder}/${grp1_subj}/${grp1_subj}_grp_assignment.txt

		elif [ -d "${cohortFolder}/excessive_motion/${grp1_subj}" ]; then

			echo "grp_1" > ${cohortFolder}/excessive_motion/${grp1_subj}/${grp1_subj}_grp_assignment.txt
		fi

	done < ${cohortFolder}/groupICA/grp1.list


	while read grp2_subj
	do
		# in case subjects folder is moved to excessive_motion
		if [ -d "${cohortFolder}/${grp2_subj}" ]; then
			echo "grp_2" > ${cohortFolder}/${grp2_subj}/${grp2_subj}_grp_assignment.txt
		elif [ -d "${cohortFolder}/excessive_motion/${grp2_subj}" ]; then
			echo "grp_2" > ${cohortFolder}/excessive_motion/${grp2_subj}/${grp2_subj}_grp_assignment.txt
		fi

	done < ${cohortFolder}/groupICA/grp2.list



	# Write *${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list*
	#       * ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list*
	# -----------------------------------------------------------------------------
	if [ -f "${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list" ]; then
		rm -f ${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list
	fi

	if [ -f "${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list" ]; then
		rm -f ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
	fi

	while read subj_inputList
	do
		case ${cleanup_mode} in

			aroma)

				subjID=$(basename $(echo ${subj_inputList} | awk -F '_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space.nii.gz' '{print $1}'))
			;;

			fix)
				subjID=$(basename $(echo ${subj_inputList} | awk -F '_func.ica/post-FIX/final_cleanedup_func_std_space.nii.gz' '{print $1}'))
			;;

		esac

		# in case subject folder is moved to excessive_motion
		if [ ! -d "${cohortFolder}/${subjID}" ] && [ -d "${cohortFolder}/excessive_motion/${subjID}" ]; then

			echo "${subjID} has been removed due to excessive motion."

		elif [ -d "${cohortFolder}/${subjID}" ]; then

			grp_ass=$(cat ${cohortFolder}/${subjID}/${subjID}_grp_assignment.txt | tr -d '\n')

			echo "--== ID = ${subjID} ==--"

			if [ "${grp_ass}" = "grp_1" ]; then

				echo "1" >> ${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list

				# writing design matrix for group contrast
				if [ "${cov_flag}" = "noCov" ]; then

					echo -e "1\t0" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list

				elif [ "${cov_flag}" = "yesCov" ]; then

					echo -en "1\t0" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
					
					curr_cov=""
					for i in $(seq 2 $((Ncov+1)))
					do
						curr_cov=`grep "^${subjID}," ${covariants_csv} | cut -d ',' -f $i`
						echo "cov = ${curr_cov}"
						echo -en "\t${curr_cov}" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
					done

					echo >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
				fi

			elif [ "${grp_ass}" = "grp_2" ]; then

				echo "2" >> ${cohortFolder}/groupICA/cohort_grp_assignment.in_order_of.input_list

				if [ "${cov_flag}" = "noCov" ]; then

					echo -e "0\t1" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list

				elif [ "${cov_flag}" = "yesCov" ]; then

					echo -en "0\t1" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
					
					curr_cov=""

					for i in $(seq 2 $((Ncov+1)))
					do
						curr_cov=`grep "^${subjID}," ${covariants_csv} | cut -d ',' -f $i`
						echo "cov = ${curr_cov}"
						echo -en "\t${curr_cov}" >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list
					done

					echo >> ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list

				fi
			fi
		fi
	done < ${cohortFolder}/groupICA/input.list

	echo "Design matrix = ${cohortFolder}/groupICA/grp_contrast.in_order_of.input_list"

}

assign_grp $1 $2 $3 $4