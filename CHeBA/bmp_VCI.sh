#!/bin/bash

# DESCRIPTION :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   This script goes through the pipelines to process imaging data
#   for VCI study.
#
# COMPUTATIONAL RESOURCES :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   The processing can be carried out on Katana, through OnDemand
#   service. A node with 16 CPU cores and 128 GB of memory for 12
#   hours is enough for the processing. Note that each step is run
#   separately, meaning that for each processing step a VM of 16
#   CPU cores and 128 GB of memory is needed.
#
# OUTPUTS :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   - [aslprep] - BASIL CBF results can be found in
#                 /path/to/aslprep/work_dir/subject_ID/aslprep_wf/
#                 single_subject_vci001_wf/asl_preproc_dir_PA_wf/
#                 compute_cbf_wf/extract_deltam/native_space.
#                 For example, vci001's results can be found in
#                 /srv/scratch/cheba/Imaging/my_tmp/aslprep_work/
#                 vci001/aslprep_wf/single_subject_vci001_wf/
#                 asl_preproc_dir_PA_wf/compute_cbf_wf/
#                 extract_deltam/native_space.
# 
#
# LOG :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   - [qsiprep] - mrtrix_multishell_msmt_pyafq_tractometry constantly having 
#                 "No space left on device" error.
#
#   - [qsiprep] - Preprocessed dMRI data are upsampled to 1.2 mm isotropic 
#                 because fixel-based analyses require a minimum of 1.3 mm 
#                 isotropic. However, this means other reconstrctions 
#                 (e.g., noddi) will also be based on 1.2 mm isotropic results.
#
#   - [fmriprep] - To let fmriprep finds fmaps, rsfMRI and fmap 
#                  JSON files need specify "B0FieldSource" and 
#                  "B0FieldIdentifier".
#
#   - [aslprep] -  It seems ASL-BIDS does not accept blip-up/down
#                  like dMRI and fMRI. Instead, it requires an
#                  additional m0scan with reverse PE from the
#                  main m0scan. A BIDS example can be found at:
#                  https://github.com/bids-standard/bids-examples/tree/master/asl004/sub-Sub1/fmap.
#                  Reference: https://www.nature.com/articles/s41597-022-01615-9.
#                  Therefore, add --use-syn-sdc and --force-syn
#                  to enable fieldmap-less distortion correction.

# XPS13 VM lin4neuro
export DICOM_zip=/home/brain/Desktop/VCI/vci_003/flywheel_20231113_001000.zip
export BIDS_dir=/home/brain/Desktop/VCI/BIDS
export subject_ID=vci003

# Macbook pro
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_001/flywheel_20230921_005034.zip
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_006/flywheel_20231206_110542.zip
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_007/flywheel_20240126_020812.zip
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_014/flywheel_20240223_031604.zip
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_010/flywheel_20240223_235303.zip
export DICOM_zip=/Users/z3402744/Work/vci/raw/vci_012/flywheel_20240224_001454.zip
export BIDS_dir=/Users/z3402744/Work/vci/BIDS
export subject_ID=vci012

# TowerX
export DICOM_zip=/db/vci/RAW/vci_030/flywheel_20240628_121504.zip
export BIDS_dir=/db/vci/BIDS
export subject_ID=vci030

# Katana
export DICOM_zip=/srv/scratch/cheba/Imaging/vci/vci_015/flywheel_20240313_002036.zip
export BIDS_dir=/srv/scratch/cheba/Imaging/vci/BIDS
export subject_ID=vci015
module load matlab/R2023b

# DICOM_zip=$1
# BIDS_dir=$2
# subject_ID=$3

n_procs=16 # max num of simultaneous processes (16/8 = 2 processes)
omp=8 # max num of threads per process
mem=22

bids_validator_version=1.13.1
mriqc_version=24.1.0
qsiprep_version=0.19.1
smriprep_version=0.16.1
aslprep_version=0.6.0
fmriprep_version=24.1.0

# ++++++++++++++++++++++++++++++++++++++++++++
# Create dcm2bids configuration file.
# ++++++++++++++++++++++++++++++++++++++++++++
# 0.1 - reorganise DICOM folders, and run helper function.
# bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID --is_1st_run
# 0.2 - generate configuration file.
# MATLAB ==>> vci_config = bmp_BIDS_CHeBA_genVCIconfigFile('rsfMRI'); % edit matchings
# 0.3 - tidy up.
# edit BrainMRIPipelines/BIDS/config_files/VCI_config.json to remove [] lines.

# +++++++++++++++++++++++++++++++++++++++
# dcm2bids for subsequent scans.
# +++++++++++++++++++++++++++++++++++++++
conda activate dcm2bids
bmp_BIDS_CHeBA.sh --study VCI --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID

# +++++++++++++++++++++++++++++++++++++++
#              validate BIDS
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

# +++++++++++++++++++++++++++++++++++++++
#         MRIQC (subject level)
# +++++++++++++++++++++++++++++++++++++++
# docker run -it --rm -v ${BIDS_dir}:/data:ro -v ${BIDS_dir}/derivatives/mriqc/sub-$subject_ID:/out nipreps/mriqc /data /out participant --modalities {T1w,T2w,bold,dwi} --verbose-reports --species human --deoblique --despike --mem_gb 4  --nprocs 1 --no-sub
#
# OR
#
work_dir=$(dirname ${BIDS_dir})/mriqc_workdir/$subject_ID
mkdir -p ${work_dir}

singularity run --cleanenv \
                $BMP_3RD_PATH/mriqc-${mriqc_version}.simg \
                --work-dir $work_dir \
                --participant_label ${subject_ID} \
                --modalities {T1w,T2w,bold,dwi} \
                --nprocs $n_procs \
                --omp-nthreads $omp \
                --mem_gb $mem \
                --verbose-reports \
                --species human \
                --fft-spikes-detector \
                --no-sub \
                ${BIDS_dir} \
                ${BIDS_dir}/derivatives/mriqc_${mriqc_version} \
                participant

# +++++++++++++++++++++++++++++++++++++++
#     Pre-processing sMRI (smriprep)
# +++++++++++++++++++++++++++++++++++++++
#
work_dir=$(dirname ${BIDS_dir})/smriprep_workdir/$subject_ID
mkdir -p ${work_dir}

singularity run --cleanenv \
				-B $BIDS_dir \
				-B $FREESURFER_HOME/license.txt:/opt/freesurfer/license.txt \
                $BMP_3RD_PATH/smriprep-${smriprep_version}.simg \
                ${BIDS_dir} ${BIDS_dir}/derivatives/smriprep_${smriprep_version} \
                participant \
                --participant_label ${subject_ID} \
                --nprocs $n_procs \
                --omp-nthreads $omp \
                --mem_gb $mem \
                --fs-license-file /opt/freesurfer/license.txt \
                --work-dir ${work_dir} \
                --notrack \
                -v


# +++++++++++++++++++++++++++++++++++++++++++++++++
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


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

    singularity run --containall --writable-tmpfs \
                    -B $BMP_TMP_PATH/templateflow:/home/qsiprep/.cache/templateflow \
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


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Processing ASL (ASLPrep)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
output_dir=$BIDS_dir/derivatives/aslprep_${aslprep_version}
work_dir=$(dirname ${BIDS_dir})/aslprep_workdir/$subject_ID
# work_dir=$BMP_TMP_PATH/aslprep_work/$subject_ID		# aslprep does not allow work dir to be a subdir of bids dir.
#                                                     # This path is currently used on Katana.
#                                                     # In future, this will be changed to $(dirname $BIDS_dir)/aslprep_workdir

mkdir -p $work_dir $output_dir

# +++++++++++++++++++++++++++++++++++++
# original script ran by Mai on Katana
# +++++++++++++++++++++++++++++++++++++
# singularity run --cleanenv \
# 				-B $HOME:/home/aslprep \
# 				--home /home/aslprep \
# 				-B $BIDS_dir \
# 				-B $output_dir \
# 				-B $work_dir \
# 				-B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
# 				$BMP_3RD_PATH/aslprep-${aslprep_version}.simg \
# 				$BIDS_dir $output_dir \
# 				participant \
# 				--skip_bids_validation \
# 				--participant_label $subject_ID \
# 				--omp-nthreads $omp \
# 				--output-spaces MNI152NLin6Asym:res-2 T1w asl \
# 				--force-bbr \
# 				--m0_scale 10 \
# 				--scorescrub \
# 				--basil \
# 				--use-syn-sdc \
# 				--force-syn \
# 				--fs-license-file /opt/freesurfer/license.txt \
# 				--work-dir $work_dir \
# 				-v

singularity run --cleanenv \
                -B $HOME:/home/aslprep \
                --home /home/aslprep \
                -B $BIDS_dir \
                -B $output_dir \
                -B $work_dir \
                -B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
                $BMP_3RD_PATH/aslprep-${aslprep_version}.simg \
                $BIDS_dir $output_dir \
                participant \
                --skip_bids_validation \
                --participant_label $subject_ID \
                --omp-nthreads $omp \
                --output-spaces MNI152NLin6Asym:res-2 T1w asl \
                --force-bbr \
                --m0_scale 10 \
                --scorescrub \
                --basil \
                --use-syn-sdc \
                --force-syn \
                --fs-license-file /opt/freesurfer/license.txt \
                --work-dir $work_dir \
                -v


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Preprocessing rsfMRI (fMRIPrep)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
work_dir=$(dirname ${BIDS_dir})/fmriprep_workdir/$subject_ID
output_dir=${BIDS_dir}/derivatives/fmriprep_${fmriprep_version}/$subject_ID
smriprep_dir=$BIDS_dir/derivatives/smriprep_${smriprep_version}

mkdir -p $work_dir $output_dir

singularity run --cleanenv \
                -B ${BIDS_dir},${work_dir},${output_dir},${smriprep_dir} \
                -B $FREESURFER_HOME/license.txt:/opt/freesurfer/license.txt \
                -B $BMP_TMP_PATH/templateflow:/home/fmriprep/.cache/templateflow \
                -B $BMP_TMP_PATH/matplotlib:/home/fmriprep/.cache/matplotlib \
                BMP_3RD_PATH/fmriprep-${fmriprep_version}.simg \
                $bids_dir \
                $output_dir \
                participant \
                --skip_bids_validation \
                --participant_label vci025 \
                --derivatives smriprep=${smriprep_dir} \
                --nprocs 20 \
                --mem_mb 25000 \
                --level full \
                --output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym:res-2 fsaverage:den-10k anat func \
                --project-goodvoxels \
                --work-dir $work_dir \
                --verbose


# Postprocessing rsfMRI (XCP-D)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++