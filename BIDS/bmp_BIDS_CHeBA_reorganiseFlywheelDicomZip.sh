#!/bin/bash

# This script re-organise DICOM zip downloaded from Flywheel, and extract 
# DICOM files to corresponding folders in BIDS/sourcedata.
#
# Written by Dr. Jiyang Jiang (18th September, 2023)
#
# Updated 27th October, 2023

deal_with_3D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword=$4
	modality_name=$5

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"

	if [ "$DICOM" = "flywheel" ]; then

		echo "[$(date)] : $(basename $0) : [WARNING] : DICOM with keyword \"$zip_path_kword\" not found in $DICOM_zip. -- Check if keyword has been changed."

	else

		# curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
		curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

		echo -en "[$(date)] : $(basename $0) : Reorganising $modality_name (3D volume) DICOM folder ... "

		echo "unzip -qq -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

		mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

		bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

		mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dcm"

		echo "DONE!"

	fi
}

deal_with_4D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword=$4
	modality_name=$5

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"

	if [ "$DICOM" = "flywheel" ]; then

		echo "[$(date)] : $(basename $0) : [WARNING] : DICOM with keyword \"$zip_path_kword\" not found in $DICOM_zip. -- Check if keyword has been changed."

	else

		# curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
		curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

		echo -en "[$(date)] : $(basename $0) : Reorganising $modality_name (4D volume) DICOM folder ... "

		echo "unzip -qq -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

		mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

		bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

		mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"

		unzip -qq -o -d $BIDS_dir/sourcedata/$subject_ID/$modality_name "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip" && rm -f "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"

		echo "DONE!"

	fi
}


DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

# structural MRI
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
case "$subject_ID" in
	vci001)
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/T1_MEMPRAGE Iso0.9mm_64ch RMS/"							MEMPRAGE_RMS
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/T1_MEMPRAGE Iso0.9mm_64ch/"								MEMPRAGE_echoes
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T2w_SPC_ vNav Iso0.9mm BW650/"						T2w
		;;
	*)
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T1w_MPR_vNav_BW740 RMS/"							MEMPRAGE_RMS
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T1w_MPR_vNav_BW740/"								MEMPRAGE_echoes
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T2w_SPC_ vNav Iso0.8mm BW744/"						T2w
		;;
esac

deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t2_space_DF_BW651/"										FLAIR


# diffusion MRI
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
#
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_BLOCK_1_DIFFUSION_30DIR/"							DWI_AP_1
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_BLOCK_2_DIFFUSION_30DIR/"							DWI_AP_2
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_BLOCK_1_DIFFUSION_30DIR/"							DWI_PA_1
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_BLOCK_2_DIFFUSION_30DIR/"							DWI_PA_2

case "$subject_ID" in
	vci001|vci002|vci003)
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_FMAP_for DIFFUSION/"									DWI_FMAP_AP
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_FMAP_for DIFFUSION/"									DWI_FMAP_PA
		;;
	*)
		# fieldmaps for dMRI are removed from the 4th scan
		;;
esac


# SWI/QSM
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
#
case "$subject_ID" in
	vci001)
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm/"									SWI_pha					# vci001 only
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_1/"								SWI_mag
		;;
	vci003)
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_RR_Qsm/"							SWI_QSM					# vci003
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_RR_SWI_Combined/"					SWI_SWI
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_RR_SWI_mIP_Combined/"				SWI_mIP
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_RR_Mag/"							SWI_mag
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_RR_Pha/"							SWI_pha_filtered
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm/"									SWI_pha
		;;
	*)
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Qsm/"								SWI_QSM	
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_SWI_Combined/"					SWI_SWI
		deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_SWI_mIP_Combined/"				SWI_mIP
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Mag/"								SWI_mag
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Pha/"								SWI_pha
		;;	
esac


# ASL
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
#
case "$subject_ID" in
	vci001)
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc_RR/"	ASL_ASL
		;;
	*)
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc/"		ASL_ASL
		;;
esac

deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/relCBF/"												ASL_relCBF
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/BAT/"													ASL_BAT
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/Perfusion_Weighted/"									ASL_PWI
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_FMAP pcasl/"											ASL_FMAP_AP
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_FMAP pcasl/"											ASL_FMAP_PA

# CVR
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
#
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/CVR_ep2d_bold 3.8mm TR1500 adaptive/"					CVR
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_FMAP cvr/"											CVR_FMAP_AP
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_FMAP cvr/"											CVR_FMAP_PA

# DCE
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
#
case "$subject_ID" in
	vci003)
		echo "[$(date)] : $(basename $0) : $subject_ID did not have DCE data acquired."
		;;
	*)
		case "$subject_ID" in
			vci001|vci002)
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_0.8x0.8x2_BW240_INV1/"					MP2RAGE_INV1
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_0.8x0.8x2_BW240_INV2/"					MP2RAGE_INV2
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_0.8x0.8x2_BW240_UNI_Images/"				MP2RAGE_UNI
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_0.8x0.8x2_BW240_T1_Images/"				MP2RAGE_T1
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/B1Map_for_T1_mapping/"									B1
				;;
			*)
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_1x1x1_BW240_INV1/"						MP2RAGE_INV1
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_1x1x1_BW240_INV2/"						MP2RAGE_INV2
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_1x1x1_BW240_UNI_Images/"					MP2RAGE_UNI
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t1_mp2rage_sag_1x1x1_BW240_T1_Images/"					MP2RAGE_T1
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/B1Map_for_T1_mapping AX/"								B1_AX
				deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/B1Map_for_T1_mapping SAG/"								B1_SAG
				;;
		esac

		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/t1_vibe_sag_DCE_2mm XL FOV 40s temporal res/"			DCE
		
		;;
	
esac

# resting state fMRI
# ++++++++++++++++++++++++++++++++++++++++++++++++++
#
case "$subject_ID" in
	vci003)
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/fMRI _RESTING STATE_MB6_PA normalise OFF/"				rsfMRI
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_FMAP_for resting state fMRI normalise OFF/"			rsfMRI_FMAP_AP
		deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_FMAP_for resting state fMRI normalise OFF/"			rsfMRI_FMAP_PA
		;;
	*)
		;;
esac