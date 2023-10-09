#!/bin/bash

# This script re-organise DICOM zip downloaded from Flywheel, and extract 
# DICOM files to corresponding folders in BIDS/sourcedata.
#
# Written by Dr. Jiyang Jiang (18th September, 2023)
#

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3


# MEMPRAGE RMS
DICOM_MEMPRAGE_RMS="flywheel$(unzip -l $DICOM_zip | grep "/T1_MEMPRAGE" | grep "RMS/" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"
curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/MEMPRAGE_RMS $(echo $DICOM_MEMPRAGE_RMS | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mkdir -p $BIDS_dir/sourcedata/$subject_ID/MEMPRAGE_RMS
bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mv "$BIDS_dir/sourcedata/$subject_ID/MEMPRAGE_RMS/$(echo $DICOM_MEMPRAGE_RMS | awk -F/ '{print $NF}')" $BIDS_dir/sourcedata/$subject_ID/MEMPRAGE_RMS/MEMPRAGE_RMS.dcm

# FLAIR
DICOM_FLAIR="flywheel$(unzip -l $DICOM_zip | grep "/t2_space_dark-fluid_sag_p2_ns-t2prep" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"
curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/FLAIR $(echo $DICOM_FLAIR | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mkdir -p $BIDS_dir/sourcedata/$subject_ID/FLAIR
bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mv "$BIDS_dir/sourcedata/$subject_ID/FLAIR/$(echo $DICOM_FLAIR | awk -F/ '{print $NF}')" $BIDS_dir/sourcedata/$subject_ID/FLAIR/FLAIR.dcm

# T2w
DICOM_T2W="flywheel$(unzip -l $DICOM_zip | grep -v "setter" | grep "/ABCD_T2w_SPC_" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"
curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/T2W $(echo $DICOM_T2W | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mkdir -p $BIDS_dir/sourcedata/$subject_ID/T2W
bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mv "$BIDS_dir/sourcedata/$subject_ID/T2W/$(echo $DICOM_T2W | awk -F/ '{print $NF}')" $BIDS_dir/sourcedata/$subject_ID/T2W/T2W.dcm

# DWI
DICOM_DWIap1="flywheel$(unzip -l $DICOM_zip | grep "/AP_BLOCK_1_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIap2="flywheel$(unzip -l $DICOM_zip | grep "/AP_BLOCK_2_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIpa1="flywheel$(unzip -l $DICOM_zip | grep "/PA_BLOCK_1_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIpa2="flywheel$(unzip -l $DICOM_zip | grep "/PA_BLOCK_2_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIfmapAp="flywheel$(unzip -l $DICOM_zip | grep "/AP_FMAP_for DIFFUSION/" | grep ".dicom.zip" | awk -F"flywheel" '{print $NF}')"
DICOM_DWIfmapPa="flywheel$(unzip -l $DICOM_zip | grep "/PA_FMAP_for DIFFUSION/" | grep ".dicom.zip" | awk -F"flywheel" '{print $NF}')"

for i in "$DICOM_DWIap1" "$DICOM_DWIap2" "$DICOM_DWIpa1" "$DICOM_DWIpa2" "$DICOM_DWIfmapAp" "$DICOM_DWIfmapPa"
do
	curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
	echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID $(echo $i | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
	bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
	rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
done

unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIap1 | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_AP1
unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIap2 | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_AP2
unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIpa1 | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_PA1
unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIpa2 | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_PA2
unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIfmapAp | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_FMAP_AP
unzip -o "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIfmapPa | awk -F/ '{print $NF}')" -d $BIDS_dir/sourcedata/$subject_ID/DWI_FMAP_PA

rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIap1 | awk -F/ '{print $NF}')"
rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIap2 | awk -F/ '{print $NF}')"
rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIpa1 | awk -F/ '{print $NF}')"
rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIpa2 | awk -F/ '{print $NF}')"
rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIfmapAp | awk -F/ '{print $NF}')"
rm -f "$BIDS_dir/sourcedata/$subject_ID/$(echo $DICOM_DWIfmapPa | awk -F/ '{print $NF}')"

# SWI-QSM
DICOM_SWI_QSM="flywheel$(unzip -l $DICOM_zip | grep "/greME9_p31_256_Iso1mm_new_Qsm/" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"
curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/SWI_QSM $(echo $DICOM_SWI_QSM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mkdir -p $BIDS_dir/sourcedata/$subject_ID/SWI_QSM
bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mv "$BIDS_dir/sourcedata/$subject_ID/SWI_QSM/$(echo $DICOM_SWI_QSM | awk -F/ '{print $NF}')" $BIDS_dir/sourcedata/$subject_ID/SWI_QSM/SWI_QSM.dcm

# SWI-SWI
DICOM_SWI_SWI="flywheel$(unzip -l $DICOM_zip | grep "/greME9_p31_256_Iso1mm_new_SWI_Combined/" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"
curr_rand_str=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/SWI_SWI $(echo $DICOM_SWI_SWI | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mkdir -p $BIDS_dir/sourcedata/$subject_ID/SWI_SWI
bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh
mv "$BIDS_dir/sourcedata/$subject_ID/SWI_SWI/$(echo $DICOM_SWI_SWI | awk -F/ '{print $NF}')" $BIDS_dir/sourcedata/$subject_ID/SWI_SWI/SWI_SWI.dcm

# SWI-mIP
DICOM_SWI_MIP="flywheel$(unzip -l $DICOM_zip | grep "/greME9_p31_256_Iso1mm_new_SWI_mIP_Combined/" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"

# SWI-magnitude
DICOM_SWI_MAG="flywheel$(unzip -l $DICOM_zip | grep "/greME9_p31_256_Iso1mm_new_Mag/" | 

