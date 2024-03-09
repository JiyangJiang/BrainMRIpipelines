#!/bin/bash

# This script should only be run when trying to create config json file

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3
study=$4

read -p "[$(date)] : $(basename $0) : dcm2bids environment activated? Or dcm2bids commands accessible? [Y/N] : " ans_yn

case "$ans_yn" in

	"Y")

		# dcm2bids_scaffold to prepare BIDS folder
		echo "[$(date)] : $(basename $0) : Running dcm2bids_scaffold to create basic files and directories for BIDS."

		dcm2bids_scaffold --output_dir=$BIDS_dir --force

		# extract from Flywheel zip archive
		echo "[$(date)] : $(basename $0) : Calling bmp_BIDS_CHeBA_init.sh to sort out Flywheel zip archive."

		case "$study" in

			"VCI")

				bmp_BIDS_CHeBA_reorganiseFlywheelDicomZip_VCI.sh $DICOM_zip $BIDS_dir $subject_ID
				;;

			"CADsyd")

				bmp_BIDS_CHeBA_reorganiseFlywheelDicomZip_CADSYD.sh $DICOM_zip $BIDS_dir $subject_ID
				;;

			*)

				echo "UNKNOWN STUDY : $study"
				;;

		esac

		echo "[$(date)] : $(basename $0) : Running dcm2bids_helper to convert DICOM to NIFTI and json, so that configuration file can be prepared."

		mkdir -p $BIDS_dir/tmp_dcm2bids

		dcm2bids_helper --dicom_dir=$BIDS_dir/sourcedata/$subject_ID --output_dir=$BIDS_dir/tmp_dcm2bids/helper --log_level=DEBUG --force

		echo -e "[$(date)] : $(basename $0) : Investigate json files in $BIDS_dir/tmp_dcm2bids/sourcedata/$curr_subjID to create the configuration file."

		;;

	"N")

		echo "[$(date)] : $(basename $0) : Abort."

		;;

	*)

		echo "[$(date)] : $(basename $0) : Abort."

		;;

esac