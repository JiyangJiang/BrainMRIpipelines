#!/bin/bash

# DESCRIPTION :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   This script goes through the pipelines to process imaging data
#   for VCI study.
#
# QSIPREP LOG :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   - mrtrix_multishell_msmt_pyafq_tractometry constantly having 
#     "No space left on device" error.
#
#   - Preprocessed dMRI data are upsampled to 1.2 mm isotropic 
#     because fixel-based analyses require a minimum of 1.3 mm 
#     isotropic. However, this means other reconstrctions 
#     (e.g., noddi) will also be based on 1.2 mm isotropic results.
#
#

# XPS13 VM lin4neuro
export DICOM_zip=/home/brain/Desktop/VCI/vci_003/flywheel_20231113_001000.zip
export BIDS_dir=/home/brain/Desktop/VCI/BIDS
export subject_ID=vci003

# Macbook pro
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_001/flywheel_20230921_005034.zip
export BIDS_dir=/Users/z3402744/Work/vci/BIDS
export subject_ID=vci001

# TowerX
export DICOM_zip=/d/vci/flywheel/vci001/flywheel_20231127_015517.zip
export BIDS_dir=/d/vci/BIDS_test
export subject_ID=vci001

# DICOM_zip=$1
# BIDS_dir=$2
# subject_ID=$3

omp=10 # max num of threads per process

bids_validator_version=1.13.1
mriqc_version=23.1.0
qsiprep_version=0.19.1
smriprep_version=0.12.2


# Create dcm2bids configuration file.
# ++++++++++++++++++++++++++++++++++++++++++++
# 0.1 - reorganise DICOM folders, and run helper function.
# bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID --is_1st_run
# 0.2 - generate configuration file.
# MATLAB ==>> vci_config = bmp_BIDS_CHeBA_genVCIconfigFile('rsfMRI'); % edit matchings
# 0.3 - tidy up.
# edit BrainMRIPipelines/BIDS/config_files/VCI_config.json to remove [] lines.

# dcm2bids for subsequent scans.
# +++++++++++++++++++++++++++++++++++++++
conda activate dcm2bids
bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID

# validate BIDS
# +++++++++++++++++++++++++++++++++++++++
# bmp_BIDSvalidator.sh --bids_directory $BIDS_dir --docker
#
# Or directly run in docker
#
# docker run -ti --rm -v ${BIDS_dir}:/data:ro bids/validator /data
#
# OR
singularity run --cleanenv \
                --bind ${BIDS_dir}:/data:ro \
                $BMP_3RD_PATH/bids-validator-${bids_validator_version}.sif \
                /data

# MRIQC (subject level)
# +++++++++++++++++++++++++++++++++++++++
# docker run -it --rm -v ${BIDS_dir}:/data:ro -v ${BIDS_dir}/derivatives/mriqc/sub-$subject_ID:/out nipreps/mriqc /data /out participant --modalities {T1w,T2w,bold,dwi} --verbose-reports --species human --deoblique --despike --mem_gb 4  --nprocs 1 --no-sub
#
# OR
#
mkdir -p ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work

singularity run --cleanenv \
                -B ${BIDS_dir}:/data \
                -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}:/out \
                -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work:/work \
                $BMP_3RD_PATH/mriqc-${mriqc_version}.sif \
                /data /out \
                participant \
                --work-dir /work \
                --participant_label ${subject_ID} \
                -m {T1w,T2w,bold} \
                --verbose-reports \
                --species human \
                --deoblique \
                --despike \
                --no-sub \
                -v

# Pre-processing sMRI (smriprep)
# +++++++++++++++++++++++++++++++++++++++
#
mkdir -p ${BIDS_dir}/derivatives/smriprep_${smriprep_version}/work

singularity run --cleanenv \
				-B $BIDS_dir \
				-B $FREESURFER_HOME/license.txt:/opt/freesurfer/license.txt \
                $BMP_3RD_PATH/smriprep-${smriprep_version}.simg \
                ${BIDS_dir} ${BIDS_dir}/derivatives/smriprep_${smriprep_version} \
                participant \
                --participant_label vci003 \
                --omp-nthreads $omp \
                --fs-license-file /opt/freesurfer/license.txt \
                --work-dir ${BIDS_dir}/derivatives/smriprep_${smriprep_version}/work \
                --notrack \
                -v

# Pre-processing DWI  (qsiprep)
# +++++++++++++++++++++++++++++++++++++++++++++++++
#
# References : https://qsiprep.readthedocs.io/en/latest/preprocessing.html#merge-denoise

work_dir=${BIDS_dir}/derivatives/qsiprep_${qsiprep_version}/work/$subject_ID

mkdir -p $work_dir

singularity run --containall --writable-tmpfs \
                -B ${BIDS_dir} \
                -B ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version} \
                -B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
                -B $BMP_PATH/VCI_study/bmp_VCI_qsiprep_eddy_param.json:/opt/eddy_param.json \
                -B $work_dir \
                $BMP_3RD_PATH/qsiprep-${qsiprep_version}.sif \
                ${BIDS_dir} \
                ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version} \
                participant \
                --skip_bids_validation \
                --participant_label ${subject_ID} \
                --fs-license-file /opt/freesurfer/license.txt \
                --unringing-method mrdegibbs \
                --denoise-after-combining \
                --output-resolution 1.2 \
                --anat_modality T1w \
                --hmc_model eddy \
                --eddy_config /opt/eddy_param.json \
                --pepolar_method TOPUP \
                --work_dir $work_dir \
                --omp_nthreads $omp \
                -v


# Reconstruction DWI measures (qsiprep)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#

qsiprep_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsiprep
# output_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsirecon/$spec
freesurfer_dir=$BIDS_dir/derivatives/smriprep_${smriprep_version}/freesurfer

for spec in mrtrix_multishell_msmt_ACT-hsvs \
            amico_noddi \
            dsi_studio_gqi

    output_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsirecon_$spec
    work_dir=$output_dir/work/$subject_ID

    mkdir -p $work_dir

    export SINGULARITY_TEMPLATEFLOW_HOME=/opt/templateflow

    singularity run --containall --writable-tmpfs \
                    -B $BMP_TMP_PATH/templateflow:/opt/templateflow \
                    -B $qsiprep_dir \
                    -B $output_dir \
                    -B $freesurfer_dir \
                    -B $work_dir \
                    -B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
                    $BMP_3RD_PATH/qsiprep-${qsiprep_version}.sif \
                    $qsiprep_dir $output_dir \
                    participant \
                    --skip_bids_validation \
                    --recon_only \
                    --participant_label ${subject_ID} \
                    --recon_input $qsiprep_dir \
                    --recon_spec $spec \
                    --freesurfer_input $freesurfer_dir \
                    --fs-license-file /opt/freesurfer/license.txt \
                    --work_dir $work_dir \
                    --omp_nthreads $omp \
                    -v
end

		