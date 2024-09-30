#!/bin/bash

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

# DICOM_zip=/db/cadasil/RAW/AC0005/AC0005_BL_DICOM.zip
# BIDS_dir=/db/cadasil/BIDS
# subject_ID=AC0005

# modality_name=DWI_AP_1
# keyword=/AP_MULTIBAND_BLOCK_1_DIFFUSION_AP_30DIR

ext_from_zip(){
	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	modality_name=$4
	keyword=$5
	

	path_in_zip=$(unzip -l $DICOM_zip | awk '{print $4}' | grep "$keyword" | head -1)

	mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name
	unzip -qq -o -j $DICOM_zip "$path_in_zip*" -d $BIDS_dir/sourcedata/$subject_ID/$modality_name
}

# diffusion-weighted MRI
# =============================================================
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_AP_1' '/AP_MULTIBAND_BLOCK_1_DIFFUSION_AP_30DIR'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_AP_2' '/AP_MULTIBAND_BLOCK_2_DIFFUSION_AP_30DIR'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_PA_1' '/PA_MULTIBAND_BLOCK_1_DIFFUSION_30DIR'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_PA_2' '/PA_MULTIBAND_BLOCK_2_DIFFUSION_30DIR'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_ADC' '/PA_MULTIBAND_BLOCK_2_DIFFUSION_30DIR_ADC'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'DWI_TRACEW' 'PA_MULTIBAND_BLOCK_2_DIFFUSION_30DIR_TRACEW'

# field map
# =============================================================
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'FMAP_AP' '/AP_PR_EP2D_SE_FMAP'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'FMAP_PA' '/PA_PR_EP2D_SE_FMAP'

# OEF
# =============================================================
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'OEF_TRUST' '/EP2D_TRUST_ASYMSHTE_0'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'OEF_Yv' '/EP2D_TRUST_ASYMSHTE_T2_YV'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'OEF_TRUST_MOCO' '/MOCOSERIES_0'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'OEF_Yv_MOCO' '/MOCOSERIES_T2_YV'

# MWI
# =============================================================
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'MWI' '/MGRASE_V2_C2P_KOREA'

# SWI
# ===================================================================================
# note that the keywords depends on series number which may change from scan to scan.
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'SWI_mag' '/MONOPOLAR_3D_T2_STAR_MEGRE_P3_NO_PF_PHASE_33SOS_0029/'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'SWI_pha' '/MONOPOLAR_3D_T2_STAR_MEGRE_P3_NO_PF_PHASE_33SOS_0031/'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'SWI_mag_ND' '/MONOPOLAR_3D_T2_STAR_MEGRE_P3_NO_PF_PHASE_33SOS_ND_0028/'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'SWI_pha_ND' '/MONOPOLAR_3D_T2_STAR_MEGRE_P3_NO_PF_PHASE_33SOS_ND_0030/'

# rsfMRI
# =============================================================
# The first CADNEW scan (AC0005) had 2 rsfMRI scans, with the
# same spatial resolution and PE; one with 118 volumes, and the
# other with 720 vols. Therefore, the following scripts were
# written.
#
# note the keywords depend on series number which may change
# from scan to scan.
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'rsfMRI_118vols' '/PA_RESTING_STATE_PR_EP2D_BOLD_MB6_0032/'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'rsfMRI_720vols' '/PA_RESTING_STATE_PR_EP2D_BOLD_MB6_0033/'

# MEMPRAGE / T1w
# =============================================================
#
# note the keywords depend on series number which may change
# from scan to scan.
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'MEMPRAGE_echoes' 'T1W_MPR_VNAV_4E_0007'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'MEMPRAGE_echoes_inhomogeneity_corr' 'T1W_MPR_VNAV_4E_0008'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'MEMPRAGE_RMS' 'T1W_MPR_VNAV_4E_RMS_0009'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'MEMPRAGE_RMS_inhomogeneity_corr' 'T1W_MPR_VNAV_4E_RMS_0010'

# FLAIR
# =============================================================
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'FLAIR' '/T2_SPACE_DARK-FLUID_SAG_P2_ISO'

# T2w
# =============================================================
#
# note the keywords depend on series number which may change
# from scan to scan.
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'T2w' 'T2W_SPC_VNAV_0013'
ext_from_zip $DICOM_zip $BIDS_dir $subject_ID 'T2w_inhomogeneity_corr' 'T2W_SPC_VNAV_0014'