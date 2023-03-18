#!/bin/bash

usage () {

cat << EOF

$(basename $0)


DESCRIPTION : 

  This script generates two lists, namely the list of study folders, 
  and the list of input images for group ICA. This script can be run 
  at the beginning, even before lower level processing, to generate
  list of study IDs (i.e., study folders).


USAGE :

 $(basename $0) [{-c|--cohort_folder} </path/to/cohort/folder>] \
                [{-l|--L-lv_type} <lower level proc type>] \
                [{-s|--spm}] \
                [{-n|--num} <num of groups>]


COMPULSORY ARGUMENTS :

  None.


OPTIONAL ARGUMENTS :

  -c, --cohort_folder    </path/to/cohort/folder>    Path to cohort folder that contains 
                                                     all the study folders. Each study folder 
                                                     has the folder name of subject ID, and 
                                                     contains a T1 and a fMRI scan for the
                                                     subject ID. Default is pwd.

  -l, --L-lv_type        <lower level proc type>     Lower level processing type, i.e., 'fix' 
                                                     for FSL FIX, or 'aroma' for FSL AROMA.
                                                     Default is 'fix'.

  -s, --spm                                          Flag to generate SPM input list for 
                                                     sub-group meta-ICA. Default is not to
                                                     generate.

  -n, --num_grps         <num of groups>             Specify the number of groups that group-
                                                     specific DARTEL templates were created,
                                                     and group ICA will be ran in. {-s|--spm} 
                                                     flag will automatically be set if this
                                                     number of groups is specified.

  -h, --help                                         Display this message.


EOF

}

cohortFolder=$(pwd)
L_lv_type=fix


for arg in $@
do
	case $arg in
		-c|--cohort_folder)
			cohortFolder=$2
			shift 2
			;;
		-l|--L-lv_type)
			L_lv_type=$2
			shift 2
			;;
		-s|--spm)
			spm_flag=spm
			shift
			;;
		-n|--num_grps)
			N_grps=$2
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		-*)
			usage
			exit 1
			;;
	esac
done



cat << EOF
       
       *******************************
---=== BrainMRIpipelines fMRI workflow ===---
            (version $(bmp_fmri_version.sh))
       *******************************

$(basename $0) : It is better to prepare grp1.list and grp2.list, with corresponding subject IDs, and save in groupICA folder.

$(basename $0) : Started!

EOF

# some preparations
# -----------------

echo -n "$(basename $0) : Removing previously created files, and creating necessary folders ... "

if [ -f "${cohortFolder}/studyFolder.list" ]; then
	rm -f ${cohortFolder}/studyFolder.list
fi

if [ ! -d "${cohortFolder}/groupICA" ]; then
	mkdir ${cohortFolder}/groupICA
fi

if [ ! -d "${cohortFolder}/groupICA/des_mtx" ]; then
	mkdir ${cohortFolder}/groupICA/des_mtx
fi

if [ ! -d "${cohortFolder}/fsf" ]; then
	mkdir ${cohortFolder}/fsf
fi

if [ -f "${cohortFolder}/groupICA/input.list" ]; then
	rm -f ${cohortFolder}/groupICA/input.list
fi

if [ ! -d "${cohortFolder}/excessive_motion" ]; then
	mkdir ${cohortFolder}/excessive_motion
fi

# if [ ! -d "${cohortFolder}/motion_params" ]; then
# 	mkdir ${cohortFolder}/motion_params
# fi

mkdir -p ${cohortFolder}/confounds/GMcovMap
mkdir -p ${cohortFolder}/confounds/WMmeants
mkdir -p ${cohortFolder}/confounds/CSFmeants
mkdir -p ${cohortFolder}/confounds/motion_params

mkdir -p ${cohortFolder}/SGE_commands/oe

mkdir -p ${cohortFolder}/groupICA/resampled_MNI

mkdir -p ${cohortFolder}/qc/func_native_slices
mkdir -p ${cohortFolder}/qc/anat_native_slices
mkdir -p ${cohortFolder}/qc/func_mni_Tstd
mkdir -p ${cohortFolder}/qc/removed_subjects

mkdir -p ${cohortFolder}/spm/coreg_epi_anat
mkdir -p ${cohortFolder}/spm/grp1
mkdir -p ${cohortFolder}/spm/grp2

if [ -f "${cohortFolder}/studyFolder.list.grp1" ]; then
	rm -f ${cohortFolder}/studyFolder.list.grp1
fi

if [ -f "${cohortFolder}/studyFolder.list.grp2" ]; then
	rm -f ${cohortFolder}/studyFolder.list.grp2
fi

if [ -f "${cohortFolder}/groupICA/input.list.grp1" ]; then
	rm -f ${cohortFolder}/groupICA/input.list.grp1
fi

if [ -f "${cohortFolder}/groupICA/input.list.grp2" ]; then
	rm -f ${cohortFolder}/groupICA/input.list.grp2
fi

echo "DONE!"


# list all study folders
# ----------------------
echo -n "$(basename $0) : Creating a list of all study folders ... "

find ${cohortFolder} \
	 -mindepth 1 \
	 -maxdepth 1 \
	 -type d \
	 -and -not -name groupICA \
	 -and -not -name fsf \
	 -and -not -name failed_FEAT \
	 -and -not -name SGE_commands \
	 -and -not -name seed_based \
	 -and -not -name excessive_motion \
	 -and -not -name confounds \
	 -and -not -name qc \
	 -and -not -name spm \
	 | sort \
	 > ${cohortFolder}/studyFolder.list

echo "DONE!"





# generate input list for groupICA
# --------------------------------
echo -n "$(basename $0) : Generating input lists for group ICA ... "

while read studyFolder_fullpath
do

	studyID=$(basename "${studyFolder_fullpath}")

	case ${L_lv_type} in
		fix)
			echo "${studyFolder_fullpath}/${studyID}_func.ica/post-FIX/final_cleanedup_func_std_space.nii.gz" \
			     >> ${cohortFolder}/groupICA/input.list
			;;
		aroma)
			echo "${studyFolder_fullpath}/${studyID}_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space.nii.gz" \
				 >> ${cohortFolder}/groupICA/input.list
			;;
	esac

	if [ -f "${cohortFolder}/groupICA/grp1.list" ]; then
		matchingID=`grep -w "${studyID}" ${cohortFolder}/groupICA/grp1.list`

		if [ "${matchingID}" != "" ]; then
			echo "${cohortFolder}/${matchingID}" >> ${cohortFolder}/studyFolder.list.grp1

			case ${L_lv_type} in
				fix)
					echo "${studyFolder_fullpath}/${matchingID}_func.ica/post-FIX/final_cleanedup_func_std_space.nii.gz" \
					     >> ${cohortFolder}/groupICA/input.list.grp1
					;;
				aroma)
					echo "${studyFolder_fullpath}/${matchingID}_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space.nii.gz" \
						 >> ${cohortFolder}/groupICA/input.list.grp1
					;;
			esac
		fi
	fi

	if [ -f "${cohortFolder}/groupICA/grp2.list" ]; then
		matchingID=`grep -w "${studyID}" ${cohortFolder}/groupICA/grp2.list`

		if [ "${matchingID}" != "" ]; then
			echo "${cohortFolder}/${matchingID}" >> ${cohortFolder}/studyFolder.list.grp2

			case ${L_lv_type} in
				fix)
					echo "${studyFolder_fullpath}/${matchingID}_func.ica/post-FIX/final_cleanedup_func_std_space.nii.gz" \
					     >> ${cohortFolder}/groupICA/input.list.grp2
					;;
				aroma)
					echo "${studyFolder_fullpath}/${matchingID}_func.feat/post-ICA_AROMA/final_cleanedup_func_std_space.nii.gz" \
						 >> ${cohortFolder}/groupICA/input.list.grp2
					;;
			esac
		fi
	fi

done < ${cohortFolder}/studyFolder.list

echo "DONE!"



# 2019 April 19 : generate SPM input list for sub-group meta-ICA
echo -n "$(basename $0) : Generating SPM input list for sub-group meta-ICA ... "

if [ "_${spm_flag}" = "_spm" ]; then
	for i in $(seq 1 ${N_grps})
	do
		ls ${cohortFolder}/spm/grp${i}/*_preproc_func_dartelSpace.nii.gz | sort > ${cohortFolder}/groupICA/input.list.grp${i}.spm
	done
fi

echo "DONE!"

echo "$(basename $0) : Finished!"