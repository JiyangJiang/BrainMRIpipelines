#!/bin/bash

# This script re-organise DICOM zip downloaded from Flywheel, and extract 
# DICOM files to corresponding folders in BIDS/sourcedata.
#
# Written by Dr. Jiyang Jiang (18th September, 2023)
#

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

deal_with_3D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword1=$4
	zip_path_kword2=$5
	modality_name=$6

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword1" | grep "$zip_path_kword2" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"

	echo $DICOM

	# # curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
	# curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

	# echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

	# bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dcm"
}

deal_with_4D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword1=$4
	zip_path_kword2=$5
	modality_name=$6

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword1" | grep "$zip_path_kword2" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"

	echo $DICOM

	# # curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
	# curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

	# echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

	# bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"

	# unzip -o -d $BIDS_dir/sourcedata/$subject_ID/$modality_name "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip" && rm -f "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"
}

# MEMPRAGE RMS
# ++++++++++++++++++++++++++++++
zip_path_kword1="/ABCD_T1w_MPR"
zip_path_kword2="RMS/"
modality_name=MEMPRAGE_RMS

deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# MEMPRAGE individual echoes
# ++++++++++++++++++++++++++++++
zip_path_kword1="/ABCD_T1w_MPR"
zip_path_kword2="_BW740/"
modality_name=MEMPRAGE_RMS

deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# FLAIR
# ++++++++++++++++++++++++++++++
zip_path_kword1="/t2_space"
zip_path_kword2="_DF"
modality_name=FLAIR
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# T2w
# ++++++++++++++++++++++++++++++
zip_path_kword1="/ABCD_T2w_SPC_"
zip_path_kword2="BW744/"
modality_name=T2w
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# DWI
# ++++++++++++++++++++++++++++++
zip_path_kword1="/AP_BLOCK_1"
zip_path_kword2="_DIFFUSION_30DIR/"
modality_name=DWI_AP_1
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

zip_path_kword1="/AP_BLOCK_2"
zip_path_kword2="_DIFFUSION_30DIR/"
modality_name=DWI_AP_2
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

zip_path_kword1="/PA_BLOCK_1"
zip_path_kword2="_DIFFUSION_30DIR/"
modality_name=DWI_PA_1
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

zip_path_kword1="/PA_BLOCK_2"
zip_path_kword2="_DIFFUSION_30DIR/"
modality_name=DWI_PA_2
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

zip_path_kword1="/AP_FMAP"
zip_path_kword2="DIFFUSION/"
modality_name=DWI_B0_AP
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

zip_path_kword1="/PA_FMAP"
zip_path_kword2="DIFFUSION/"
modality_name=DWI_B0_PA
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name


# SWI-QSM
# ++++++++++++++++++++++++++++++
zip_path_kword1="/greME9_p31"
zip_path_kword2="_Qsm/"
modality_name=SWI_QSM
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# SWI-SWI
# ++++++++++++++++++++++++++++++
zip_path_kword1="/greME9_p31"
zip_path_kword2="SWI_Combined/"
modality_name=SWI_SWI
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# SWI-mIP
# ++++++++++++++++++++++++++++++
zip_path_kword1="/greME9_p31"
zip_path_kword2="SWI_mIP_Combined/"
modality_name=SWI_mIP
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# SWI-magnitude
# ++++++++++++++++++++++++++++++
zip_path_kword1="/greME9_p31"
zip_path_kword2="_Mag/"
modality_name=SWI_mag
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# SWI-phase
# ++++++++++++++++++++++++++++++
zip_path_kword1="/greME9_p31"
zip_path_kword2="_Pha/"
modality_name=SWI_pha
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# ASL-relCBF
# ++++++++++++++++++++++++++++++
zip_path_kword1="/relCBF/"
zip_path_kword2="/relCBF/"
modality_name=ASL_relCBF
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# ASL-BAT
# ++++++++++++++++++++++++++++++
zip_path_kword1="/BAT/"
zip_path_kword2="/BAT/"
modality_name=ASL_BAT
deal_with_3D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# ASL-PWI
# ++++++++++++++++++++++++++++++
zip_path_kword1="/Perfusion_Weighted/"
zip_path_kword2="/Perfusion_Weighted/"
modality_name=ASL_PWI
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

# ASL-ASL
# ++++++++++++++++++++++++++++++
zip_path_kword1="/mTI16"
zip_path_kword2="pcasl"
modality_name=ASL_ASL
deal_with_4D $1 $2 $3 \
				$zip_path_kword1 $zip_path_kword2 $modality_name

				