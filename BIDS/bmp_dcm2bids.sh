#!/bin/bash

# dcm2niix configuration file is at ~/.dcm2nii.ini
#
# DATA PREPARATION
# ------------------------------------------------------------------------------
# All DICOM or PAR/REC files should be put in the 'sourcedata' folder in the
# BIDS directory. Each subject should have a separate folder in sourcedata,
# with subject ID as the folder name.
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


$(bmp_convention.sh --usage_section_title)WORKFLOW :$(bmp_shellColour.sh --reset)




$(bmp_convention.sh --usage_section_title)USAGE :$(bmp_shellColour.sh --reset)

  $(basename $0) {-d|--dicom_directory} <DICOM_directory> [{-f|--first_run}]


$(bmp_convention.sh --usage_section_title)COMPULSORY :$(bmp_shellColour.sh --reset)

  -d, --dicom_directory        <DICOM_directory>        Path to DICOM directory.

  -i, --subject_ID             <subject ID>             This subject ID will be used to rename
                                                        DICOM directory and copy to sourcedata
                                                        folder in the DICOM directory.


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
                                                        help prepare configuration json file.
                                                        bmp_DICOMenquirer.m can be ran to list unique
                                                        values in specified fields, which is helpful
                                                        to create configuration json.

  -h, --help                                            Display this message.


$(bmp_convention.sh --usage_section_title)DEPENDENCIES :$(bmp_shellColour.sh --reset)

  - Dcm2Bids (bmp_install.sh --dcm2bids)
  

EOM
)"

}

# conda init bash
# conda activate dcm2bids # activate dcm2bids conda env

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

		-i|--subject_ID)

			curr_subjID=$2
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
	echo "[$(date)] : $(basename $0) : BIDS directory is not set. Use $(dirname $DICOM_directory)/BIDS as BIDS directory."
	BIDS_directory=$(dirname $DICOM_directory)/BIDS
else
	echo "[$(date)] : $(basename $0) : BIDS directory is set as $BIDS_directory."
fi

if [ -d $BIDS_directory ]; then
	echo "[$(date)] : $(basename $0) : BIDS directory $BIDS_directory exists."
else
	echo -n "[$(date)] : $(basename $0) : BIDS directory $BIDS_directory does not exist. Creating ... "
	mkdir -p $BIDS_directory
	echo "done!"
fi

if [ -d "$BIDS_directory/sourcedata" ]; then
	subjID_list=$(ls -1d $BIDS_directory/sourcedata/* | awk -F'/' '{print $NF}')

	echo "[$(date)] : $(basename $0) : $(ls -1d $BIDS_directory/sourcedata/* | wc -l) subjects are currently in DICOM directory."
	ls -1d $BIDS_directory/sourcedata/* | head -n5 | awk -F'/' '{print $NF}'
	echo "... ..."
	ls -1d $BIDS_directory/sourcedata/* | tail -n5 | awk -F'/' '{print $NF}'
fi

case $is_first_run in

	yes)

		# =============================================================================
		#                                   First run
		# =============================================================================

		echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Running dcm2bids_scaffold to create basic files and directories for BIDS.$(bmp_shellColour.sh --reset)"

		cd $BIDS_directory
		dcm2bids_scaffold

		echo -n "[$(date)] : $(basename $0) : Copying $DICOM_directory to $BIDS_directory/sourcedata, and renaming it with $curr_subjID ... "
		cp -r $DICOM_directory $BIDS_directory/sourcedata/$curr_subjID
		echo "done!"

		case $use_dcm2bids_helper in

			yes)

				echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Running dcm2bids_helper to convert DICOM of the current subject (ID = $curr_subjID) to NIFTI and json, so that configuration file can be prepared.$(bmp_shellColour.sh --reset)"

				dcm2bids_helper --dicom_dir   $BIDS_directory/sourcedata/$curr_subjID \
								--nest \
								--log_level DEBUG \
								--firce \
								> $BIDS_directory/tmp_dcm2bids/dcm2bids_helper.debug_log

				echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Investigate json files in $(bmp_convention.sh --text_path)$BIDS_directory/tmp_dcm2bids/sourcedata/$curr_subjID$(bmp_convention.sh --text_normal) to create the configuration file.$(bmp_shellColour.sh --reset)"

				;;

			no)

				matlab -nodisplay -nodesktop -r "bmp_DICOMenquirer ('$BIDS_directory');exit"

				;;

		esac

		;;



	# no)

	# 	# =============================================================================
	# 	#                          Normal mode - run all subjects
	# 	# =============================================================================
	# 	while read rawData
	# 	do


	# 		subjectFolder=${rawData}
	# 		participantID=$(basename ${rawData})

	# 		# =============================================================================

	# 		# Step 0 : Preparation
	# 		# --------------------
	# 		# remove subjectFolder/tmp_dcm2bids which is generated by previous run of dcm2bids
	# 		if [ -d "${subjectFolder}/tmp_dcm2bids" ]; then
	# 			rm -fr ${subjectFolder}/tmp_dcm2bids
	# 		fi
	# 		# remove previous sub-participantID folder in projectFolder if present
	# 		if [ -d "${projectFolder}/sub-${participantID}" ]; then
	# 			rm -fr ${projectFolder}/sub-${participantID}
	# 		fi

	# 		# =============================================================================

	# 		# Step 1 : cd to subject folder
	# 		# -----------------------------
	# 		cd ${subjectFolder}


	# 		# Step 2 : find DICOM folder
	# 		# --------------------------
	# 		DICOMfolder=`find ${subjectFolder} -mindepth 1 -maxdepth 1 -type d`
	# 		echo "DICOM folder from scanner is ${DICOMfolder}"


	# 		# Step 5 : run dcm2bids
	# 		# ---------------------
	# 		echo "Debug_mode = N. Not running dcm2bids_helper."
	# 		echo "Continue with the following steps."
	# 		dcm2bids -d ${DICOMfolder} \
	# 				 -p ${participantID} \
	# 				 -c ${config_json}


	# 		# Step 6 : fix the missing "TaskName" issue
	# 		# -----------------------------------------
	# 		cd sub-${participantID}/func
			# for i in `ls *.json`
			# do
			# 	task=$(echo $i | awk -F'task-' '{print $2}' | awk -F'_' '{print $1}')
			# 	ex -s -c "2i|\"TaskName\": \"${task}\"," -c x ${i}
			# done
	# 		cd ${subjectFolder}


	# 		# Step 7 : move sub-* to projectFolder
	# 		# ----------------------------------
	# 		mv sub-${participantID} ${projectFolder}/.


	# 	done < ${rawDataFolder}/.rawDataList



	# 	# Step 8 : create basic BIDS files with dcm2bids_scaffold
	# 	#          This only needs to be done once.
	# 	# -------------------------------------------------------
	# 	dcm2bids_scaffold -o ${projectFolder}

	# 	# Step 9 : in participants.tsv, manually change participants_id to participant_id
	# 	# -------------------------------------------------------------------------------
	# 	cp $(dirname $(which $0))/participants.tsv \
	# 	   ${projectFolder}/.


	# 	# Step 10 : insert creat data/time to README
	# 	#           README will report as error if leaving empty
	# 	# ------------------------------------------------------
	# 	echo "Created at $(date)" > ${projectFolder}/README


	# 	# Step 11 : validation
	# 	# --------------------
	# 	echo "You can now validate ${projectFolder}"
	# 	echo "using the online validator http://bids-standard.github.io/bids-validator/"

	# ;;
esac

