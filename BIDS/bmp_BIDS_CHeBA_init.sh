#!/bin/bash

DICOM_zip=$1
BIDS_dir=$2

DICOM_DWIap1="flywheel$(unzip -l $DICOM_zip | grep "/AP_BLOCK_1_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIap2="flywheel$(unzip -l $DICOM_zip | grep "/AP_BLOCK_2_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIpa1="flywheel$(unzip -l $DICOM_zip | grep "/PA_BLOCK_1_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIpa2="flywheel$(unzip -l $DICOM_zip | grep "/PA_BLOCK_2_DIFFUSION_30DIR/" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"
DICOM_DWIfmapAp="flywheel$(unzip -l $DICOM_zip | grep "/AP_FMAP_for DIFFUSION/" | grep ".dicom.zip" | awk -F"flywheel" '{print $NF}')"
DICOM_DWIfmapPa="flywheel$(unzip -l $DICOM_zip | grep "/PA_FMAP_for DIFFUSION/" | grep ".dicom.zip" | awk -F"flywheel" '{print $NF}')"
echo $DICOM_DWIfmapAp
set -x
unzip -j $DICOM_zip $DICOM_DWIfmapAp -d $BIDS_dir/sourcedata
set +x