#!/bin/bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# This script does all postprocessing after fMRIPrep, which includes:
# - nuisance regression
# - spatial smoothing
# - temporal filtering
# - removing first 5 volumes
#
# All selected parameters are preset and basic. You may want to 
# modify if you have specific requirements.
# 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Specifically, nuisance regression was against :
#   + csf
#   + white_matter
#   + trans_x
#   + trans_y
#   + trans_z
#   + rot_x
#   + rot_y
#   + rot_z
#
# spatial smoothing was set to FWHM = 6
#
# temporal filtering = 0.009 - 0.08 Hz
#
# first 5 volumes are removed to achieve steady state
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Other info:
#
# The entire confounds regression tsv file includes:
#
# csf
# csf_derivative1
# csf_power2
# csf_derivative1_power2
# white_matter
# white_matter_derivative1
# white_matter_derivative1_power2
# white_matter_power2
# global_signal
# global_signal_derivative1
# global_signal_derivative1_power2
# global_signal_power2
# std_dvars
# dvars
# framewise_displacement
# t_comp_cor_00
# ...
# t_comp_cor_xx
# a_comp_cor_00
# ...
# a_comp_cor_yy
# cosine00
# cosine01
# cosine02
# cosine03
# cosine04
# non_steady_state_outlier00
# trans_x
# trans_x_derivative1
# trans_x_power2
# trans_x_derivative1_power2
# trans_y
# trans_y_derivative1
# trans_y_derivative1_power2
# trans_y_power2
# trans_z
# trans_z_derivative1
# trans_z_derivative1_power2
# trans_z_power2
# rot_x
# rot_x_derivative1
# rot_x_power2
# rot_x_derivative1_power2
# rot_y
# rot_y_derivative1
# rot_y_power2
# rot_y_derivative1_power2
# rot_z
# rot_z_derivative1
# rot_z_power2
# rot_z_derivative1_power2
# motion_outlier00
# ...
# motion_outlierzz



# fmriprep_folder=$1
# FUTURE_folder=$2

fmriprep_folder=/data/jiyang/OW2_fMRI_cross-sectional/derivatives/fmriprep/v1.5.5/fmriprep
FUTURE_folder=/home/jiyang/my_software/FUTURE




mkdir -p ${fmriprep_folder}/SGE_commands/oe

[ -f "${fmriprep_folder}/subIDlist" ] && rm -f ${fmriprep_folder}/subIDlist

# only work with those with sub-*/func/*_desc-confounds_regressors.tsv
for i in `ls -d ${fmriprep_folder}/sub-*/func/*_desc-confounds_regressors.tsv`
do
	subID=$(echo $(echo $i | awk -F '/func' '{print $1}') | awk -F '/' '{print $NF}')

	echo ${subID} >> ${fmriprep_folder}/subIDlist
done

N_subj=$(wc -l ${fmriprep_folder}/subIDlist | awk '{print $1}')


# generate spreadsheet with selected confounders
# This somehow does not work in SGE script
matlab -nodesktop -nosplash -r "addpath('${FUTURE_folder}/fMRI/fMRIPrep/postproc_scripts');\
							   fmriprep_postproc_prepareConfounderList_loopAllSubj ('${fmriprep_folder}',\
																				    {'csf','white_matter','trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'},\
																				    '${FUTURE_folder}');\
								exit"




# the nuisance regression (fsl_glm) step needs large memory

cat << EOF > ${fmriprep_folder}/SGE_commands/fMRIPrep_postprocessing.sge
#$ -N fmriprep_postproc
#$ -V
#$ -cwd
#$ -pe smp 4
#$ -q short.q
#$ -l h_vmem=16G
#$ -o ${fmriprep_folder}/SGE_commands/oe/fMRIPrep_postprocessing.out
#$ -e ${fmriprep_folder}/SGE_commands/oe/fMRIPrep_postprocessing.err
#$ -t 1-${N_subj}

curr_subID=\$(cat ${fmriprep_folder}/subIDlist | awk "NR==\${SGE_TASK_ID}")

# 1. nuisance regression

fslmaths \$(ls ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_*space-MNI152NLin6Asym_desc-preproc_bold.nii.gz) \
		 -Tmean \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-preproc_Tmean_bold

fsl_glm -i \$(ls ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_*space-MNI152NLin6Asym_desc-preproc_bold.nii.gz) \
		-d ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-basic_confounds_noHeader_regressors.tsv \
		--demean \
		--out_res=${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold

fslmaths ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold \
		 -add ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-preproc_Tmean_bold \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold

# 2. spatial smoothing
3dBlurToFWHM -input ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold.nii.gz \
			 -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold_blur \
			 -mask \$(ls ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_*space-MNI152NLin6Asym_desc-brain_mask.nii.gz) \
			 -FWHM 6

# 3. temporal filtering (bandpass)
3dBandpass -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold_blur_bandpass \
		   -mask \$(ls ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_*space-MNI152NLin6Asym_desc-brain_mask.nii.gz) \
		   0.009 0.08 \
		   ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold_blur+tlrc

# 4. convert to NIFTI and cleanup
rm -f ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold.nii.gz
3dAFNItoNIFTI -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold \
			  ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold_blur_bandpass+tlrc

gzip ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold.nii

rm -f ${fmriprep_folder}/\${curr_subID}/func/*.BRIK \
	  ${fmriprep_folder}/\${curr_subID}/func/*.HEAD

# 5. remove first 5 volumes to reach steady state
fslroi ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold \
	   ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold \
	   5 -1

# 6. add Tmean
fslmaths ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold \
		 -add ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-preproc_Tmean_bold \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin6Asym_desc-afterJmodPostproc_bold

EOF

qsub ${fmriprep_folder}/SGE_commands/fMRIPrep_postprocessing.sge