#!/bin/bash

# dcm2niix configuration file is at ~/.dcm2nii.ini
#
# DATA PREPARATION
# ------------------------------------------------------------------------------
# 1. all DICOM or PAR/REC files should be put in a folder inside the subjectFolder.
#    and this should be the only folder in subjectFolder.
#
# 2. subjectFolder should have the folder name same as participant's ID.
#
#
# OUTPUT
# ------------------------------------------------------------------------------
# projectFolder contains all BIDS format outputs.
#
#
# USAGE
# ------------------------------------------------------------------------------
# rawDataFolder : path to the folder containing one folder for each subject
#                 (subjectFolder). Within each subjectFolder, one (and the only)
#                 folder should be present, containing all DICOM or PAR/REC files.
#
# projectFolder : path to the final BIDS-format folder
#
# config_json : path to the configuration json file (which is manually created
#               with the output from debug mode).
#
# debug_mode : set to Y in the first run, in order to create the configure json.
#
#
# DETAILED WORKFLOW
# ------------------------------------------------------------------------------
# > Step 1 : Set debug_mode=Y. This will run dcm2bids_helper for the first
#            subject.
#
# > Step 2 : Create configuration json using the dcm2bids_helper output from
#            Step 1.
#
# > Step 3 : Set debug_mode=N to run through all subjects.
#
# =============================================================================
#
# HISTORY
#
# - Jan 2019 : Dr. Jiyang Jiang wrote the first version.
# - Nov 2022 : Jiyang Jiang modifies to incorporate into BrainMRIpipelines.


usage() {

echo -e "$(cat << EOM

$(bmp_convention.sh --script_name)$(basename $0)$(bmp_shellColour.sh --reset)

$(bmp_convention.sh --usage_section_title)DESCRIPTION :$(bmp_shellColour.sh --reset)

  This script runs Dcm2Bids to convert DICOM files to BIDS format.


DATA PREPARATION :

  DICOM directory should contain a folder for each subject. 
  Folder name is the subject ID. Folder contains DICOM files
  for that particular subject.

  [DICOM directory]
        |
        |
        -- [subject ID 1]
        |       |
        |       -- DICOM file 1 for [subject ID 1]
        |       |
        |       -- DICOM file 2 for [subject ID 1]
        |       |
        |       -- ......
        |       |
        |       -- DICOM file N for [subject ID 1]
        |
        |
        -- [suject ID 2]
        |       |
        |       -- [any number of intermediate folders]
        |                          |
        |                          -- DICOM file 1 for [subject ID 2]
        |                          |
        |                          -- DICOM file 2 for [subject ID 2]
        |                          |
        |                          -- ......
        |                          |
        |                          -- DICOM file N for [subject ID 2]
        .
        .
        .


$(bmp_convention.sh --usage_section_title)WORKFLOW :$(bmp_shellColour.sh --reset)




$(bmp_convention.sh --usage_section_title)USAGE :$(bmp_shellColour.sh --reset)

  $(basename $0) {-d|--dicom_directory} <DICOM_directory> [{-f|--first_run}]


$(bmp_convention.sh --usage_section_title)COMPULSORY :$(bmp_shellColour.sh --reset)

  -d, --dicom_directory        <DICOM_directory>        Path to DICOM directory, which contains
                                                        folders with subject IDs as folder name,
                                                        and DICOM files stored in the folder.
                                                        Intermediate folders between subject ID
                                                        folder and DICOM files can exist.


$(bmp_convention.sh --usage_section_title)OPTIONAL :$(bmp_shellColour.sh --reset)

  -b, --bids_directory         <BIDS_directory>         Path to save BIDS format data in. Default
                                                        is 'BIDS' on the same level as DICOM
                                                        directory. The directory is created if
                                                        does not exist.

  -f, --first_run                                       Add this flag for the first run, so that
                                                        nessary files, folder structures, and
                                                        sidecars for preparing the configuration
                                                        file, can be generated. By default,
                                                        {-f|--first_run} is not set.

  -c, --dcm2bids_helper                                 Use dcm2bids_helper in the first run to
                                                        help prepare configuration file. By default,
                                                        bmp_prepConfig.m will be ran to list unique
                                                        values in specified fields, which is much
                                                        easier and works well in most datasets.

  -h, --help                                            Display this message.


$(bmp_convention.sh --usage_section_title)DEPENDENCIES :$(bmp_shellColour.sh --reset)

  - Dcm2Bids (bmp_install.sh --dcm2bids)
  

EOM
)"

}

conda activate dcm2bids # activate dcm2bids conda env

is_first_run=no
use_dcm2bids_helper=no
use_bmp_prepconfig=yes

for arg in $@
do

	case $arg in

		-d|--dicom_directory)

			DICOM_directory=$2
			shift 2
			;;

		-b|--bids_directory)

			BIDS_directory=$2
			shift 2
			;;

		-f|--first_run)

			is_first_run=yes
			shift
			;;

		-c|--dcm2bids_helper)

			use_dcm2bids_helper=yes
			use_bmp_prepconfig=no
			shift
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


if [ -z ${BIDS_directory:+x} ]; then
	BIDS_directory=$(dirname $DICOM_directory)/BIDS
fi
mkdir -p $BIDS_directory

subjID_list=$(basename $(ls -1d $DICOM_directory))



case $is_first_run in

yes)

	# =============================================================================
	#                                   First run
	# =============================================================================

	echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Running dcm2bids_scaffold to create basic files and directories for BIDS.$(bmp_shellColour.sh --reset)"

	dcm2bids_scaffold --output_dir $BIDS_directory

	if [ "$use_dcm2bids_helper" == "yes" ]; then
		echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Running dcm2bids_helper to convert DICOM of the first subject (ID = $(echo $subjID_list | awk '{print $1}')) to NIFTI and json, so that configuration file can be prepared.$(bmp_shellColour.sh --reset)"

		dcm2bids_helper --dicom_dir   $DICOM_directory/$(echo $subjID_list | awk '{print $1}') \
						--output_dir  $BMP_TMP_PATH/bmp/dcm2bids/helper \
						--force \
						> /dev/null

		echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Investigate json files in $(bmp_convention.sh --text_path)$BMP_TMP_PATH/bmp/dcm2bids/helper$(bmp_convention.sh --text_normal) to create the configuration file.$(bmp_shellColour.sh --reset)"

	else

		## RUN BMP_PREPCONFIG.M

	fi
	;;



no)

	# =============================================================================
	#                          Normal mode - run all subjects
	# =============================================================================
	while read rawData
	do


		subjectFolder=${rawData}
		participantID=$(basename ${rawData})

		# =============================================================================

		# Step 0 : Preparation
		# --------------------
		# remove subjectFolder/tmp_dcm2bids which is generated by previous run of dcm2bids
		if [ -d "${subjectFolder}/tmp_dcm2bids" ]; then
			rm -fr ${subjectFolder}/tmp_dcm2bids
		fi
		# remove previous sub-participantID folder in projectFolder if present
		if [ -d "${projectFolder}/sub-${participantID}" ]; then
			rm -fr ${projectFolder}/sub-${participantID}
		fi

		# =============================================================================

		# Step 1 : cd to subject folder
		# -----------------------------
		cd ${subjectFolder}


		# Step 2 : find DICOM folder
		# --------------------------
		DICOMfolder=`find ${subjectFolder} -mindepth 1 -maxdepth 1 -type d`
		echo "DICOM folder from scanner is ${DICOMfolder}"


		# Step 5 : run dcm2bids
		# ---------------------
		echo "Debug_mode = N. Not running dcm2bids_helper."
		echo "Continue with the following steps."
		dcm2bids -d ${DICOMfolder} \
				 -p ${participantID} \
				 -c ${config_json}


		# Step 6 : fix the missing "TaskName" issue
		# -----------------------------------------
		cd sub-${participantID}/func
		for i in `ls *.json`
		do
			task=$(echo $i | awk -F'task-' '{print $2}' | awk -F'_' '{print $1}')
			ex -s -c "2i|\"TaskName\": \"${task}\"," -c x ${i}
		done
		cd ${subjectFolder}


		# Step 7 : move sub-* to projectFolder
		# ----------------------------------
		mv sub-${participantID} ${projectFolder}/.


	done < ${rawDataFolder}/.rawDataList



	# Step 8 : create basic BIDS files with dcm2bids_scaffold
	#          This only needs to be done once.
	# -------------------------------------------------------
	dcm2bids_scaffold -o ${projectFolder}

	# Step 9 : in participants.tsv, manually change participants_id to participant_id
	# -------------------------------------------------------------------------------
	cp $(dirname $(which $0))/participants.tsv \
	   ${projectFolder}/.


	# Step 10 : insert creat data/time to README
	#           README will report as error if leaving empty
	# ------------------------------------------------------
	echo "Created at $(date)" > ${projectFolder}/README


	# Step 11 : validation
	# --------------------
	echo "You can now validate ${projectFolder}"
	echo "using the online validator http://bids-standard.github.io/bids-validator/"

;;
esac

