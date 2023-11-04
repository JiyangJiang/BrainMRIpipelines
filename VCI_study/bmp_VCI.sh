#!/bin/bash

# DESCRIPTION :
#
#   This script goes through the pipelines to process imaging data
#   for VCI study.

DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3

bids_validator_version=1.13.1
mriqc_version=23.1.0
qsiprep_version=0.19.1

# Step 0. Create dcm2bids configuration file.
# ++++++++++++++++++++++++++++++++++++++++++++
# 0.1 - reorganise DICOM folders, and run helper function.
# bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID --is_1st_run
# 0.2 - generate configuration file.
# MATLAB ==>> vci_config = bmp_BIDS_CHeBA_genVCIconfigFile('rsfMRI'); % edit matchings
# 0.3 - tidy up.
# edit BrainMRIPipelines/BIDS/config_files/VCI_config.json to remove [] lines.

# Step 1. dcm2bids for subsequent scans.
# +++++++++++++++++++++++++++++++++++++++
bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID

# Step 2. validate BIDS
# +++++++++++++++++++++++++++++++++++++++
bmp_BIDSvalidator.sh --bids_directory $BIDS_dir --docker
#
# Or directly run in docker
#
# docker run -ti --rm -v ${BIDS_dir}:/data:ro bids/validator /data
#
# OR
singularity run --cleanenv --bind ${BIDS_dir}:/data:ro $BMP_3RD_PATH/bids-validator-${bids_validator_version}.sif /data

# Step 3. MRIQC (subject level)
# docker run -it --rm -v ${BIDS_dir}:/data:ro -v ${BIDS_dir}/derivatives/mriqc/sub-$subject_ID:/out nipreps/mriqc /data /out participant --modalities {T1w,T2w,bold,dwi} --verbose-reports --species human --deoblique --despike --mem_gb 4  --nprocs 1 --no-sub
#
# OR
#
mkdir -p ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work

singularity run --cleanenv -B ${BIDS_dir}:/data -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}:/out -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work:/work $BMP_3RD_PATH/mriqc-${mriqc_version}.sif /data /out participant --work-dir /work --participant_label ${subject_ID} -m {T1w,T2w,bold} --verbose-reports --species human --deoblique --despike --no-sub -v

# Step 4. Pre-processing DWI (qsiprep)
#
# References : https://qsiprep.readthedocs.io/en/latest/preprocessing.html#merge-denoise
mkdir -p ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version}/work

singularity run --containall --writable-tmpfs \
                -B ${BIDS_dir},${BIDS_dir}/derivatives/qsiprep_${qsiprep_version},${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
                $BMP_3RD_PATH/qsiprep-${qsiprep_version}.sif \
                ${BIDS_dir} \
                ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version} \
                participant \
                --participant_label ${subject_ID} \
                --fs-license-file /opt/freesurfer/license.txt \
                --unringing-method mrdegibbs \
                --denoise-after-combining \
                --output-resolution 1.2 \
                --anat_modality T1w \
                --hmc_model eddy \
                --eddy_config $BMP_PATH/VCI_study/bmp_VCI_qsiprep_eddy_param.json \
                --pepolar_method TOPUP \
                --work_dir ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version}/work \
                -v


# Step 5. Pre-processing sMRI (smriprep)