#!/bin/bash

# DESCRIPTION
# --------------------------------------------------------------------------------------------------
#
#
# USAGE
# --------------------------------------------------------------------------------------------------
# $1 = path to BIDS project folder.
#
# $2 = path to FreeSurfer annot file. use ?h to include both lh and rh. For example :
#
#          /path/to/atlas/?h.myatlas.annot
#
#      special case : if using HCP-MMP1 atlas (lh.HCP-MMP1.annot and rh.HCP-MMP1.annot), 
#                     pass 'HCP-MMP1'. if using Desikan-Killiany atlas, pass ('Desikan').
#
# $3 = 'yesSkipOrg' if skipping generating mif and separating into 200
#      'yesSkipOrg' option is useful in the situation where one wants
#      to skip the initial nii/bvec/bval -> mif conversion, and separating
#      into portions (each with 200). This may be particularly useful in
#      debugging (and re-running) the following steps. Leave empty otherwise.

study_dir=/g/data/ey6/Jiyang/MAS
mif_dir=/g/data/ey6/Jiyang/MAS/nifti/dwi-mif


# BIDS_folder=$1
# FSannot_path=$2
# skip_mif_org_flag=$3

FUTURE_folder=$(dirname $(dirname $(dirname $(dirname $(which $0)))))


# ++++++++++++++++++++++++++++++++++ #
# create command files, but not qsub #
# ++++++++++++++++++++++++++++++++++ #

# DWI preprocessing (MRtrix)
${FUTURE_folder}/DWI/MRtrix3/Raijin/mrtrix_preprocessing_BIDS_Raijin_cohort.sh ${studyFolder} noSubq ${mif_dir}

# T1 recon-all (FreeSurfer)
${FUTURE_folder}/Anat/Raijin/FS_recon-all_BIDS_Raijin_cohort.sh ${BIDS_folder} ba64 noSubq

# DWI tractography (MRtrix)
${FUTURE_folder}/DWI/MRtrix3/Raijin/mrtrix_tractography_singleShell_BIDS_Raijin_cohort.sh ${BIDS_folder} noSubq

# DWI network construction (MRtrix)
${FUTURE_folder}/DWI/MRtrix3/Raijin/mrtrix_connectivity_BIDS_Raijin_cohort.sh ${BIDS_folder} ${FSannot_path} noSubq



# ++++++++++++++++++++++++++ #
# qsub with job dependencies #
# ++++++++++++++++++++++++++ #

cd ${BIDS_folder}/derivatives/mrtrix

for i in `ls raijin_cmds/preprocessing/*_raijin_preprocessing_cmd.txt`
do
	subjID=$(basename ${i} | awk -F '_' '{print $1}')

	mrtrix_preprocessing_cmd=${BIDS_folder}/derivatives/mrtrix/raijin_cmds/preprocessing/${subjID}_raijin_preprocessing_cmd.txt
	mrtrix_tractography_cmd=${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography/${subjID}_raijin_tractography_cmd.txt
	mrtrix_connectivity_cmd=${BIDS_folder}/derivatives/mrtrix/raijin_cmds/connectivity/${subjID}_raijin_connectivity_cmd.txt

	freesurfer_reconall_cmd=${BIDS_folder}/derivatives/freesurfer/raijin_cmds/recon-all/${subjID}_raijin_reconall_cmd.txt

	mrtrix_preprocessing_jobid=$(qsub -N ${subjID}_mrtrix_preprocessing ${mrtrix_preprocessing_cmd})
	freesurfer_reconall_jobid=$(qsub -N ${subjID}_freesurfer_reconall ${freesurfer_reconall_cmd})
	mrtrix_tractography_jobid=$(qsub -N ${subjID}_mrtrix_tractography -W depend=afterany:${mrtrix_preprocessing_jobid} ${mrtrix_tractography_cmd})
	mrtrix_connectivity_jobid=$(qsub -N ${subjID}_mrtrix_connectivity -W depend=afterany:${freesurfer_reconall_jobid}:${mrtrix_tractography_jobid} ${mrtrix_connectivity_cmd})
done
