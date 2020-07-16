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
# NOTE : this version transforms MNI152NLin2009cAsym to FSL MNI space
#        which suits older version of fMRIprep where MNI6 space is
#        not available. Also, the fields are less in older fMRIprep.
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
# spatial smoothing was set to FWHM = 5
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
#    + csf
#    + white_matter
#    + global_signal
#    + std_dvars
#    + dvars
#    + framewise_displacement
#    + t_comp_cor_00
#    + t_comp_cor_01
#    + t_comp_cor_02
#    + t_comp_cor_03
#    + t_comp_cor_04
#    + t_comp_cor_05
#    + a_comp_cor_00
#    + a_comp_cor_01
#    + a_comp_cor_02
#    + a_comp_cor_03
#    + a_comp_cor_04
#    + a_comp_cor_05
#    + cosine00
#    + cosine01
#    + cosine02
#    + cosine03
#    + cosine04
#    + non_steady_state_outlier?? - can be any number of columns
#    + trans_x
#    + trans_y
#    + trans_z
#    + rot_x
#    + rot_y
#    + rot_z

fmriprep_folder=$1
FUTURE_folder=$2

mkdir -p ${fmriprep_folder}/SGE_commands/oe

[ -f "${fmriprep_folder}/subIDlist" ] && rm -f ${fmriprep_folder}/subIDlist

for i in `ls ${fmriprep_folder}/*.html`
do
	subID=`echo $(basename $i) | awk -F '.' '{print $1}'`
	if [ -d "${fmriprep_folder}/${subID}/func" ]; then
		echo ${subID} >> ${fmriprep_folder}/subIDlist
	fi
done

N_subj=$(wc -l ${fmriprep_folder}/subIDlist | awk '{print $1}')



cat << EOF > ${fmriprep_folder}/SGE_commands/fMRIPrep_postprocessing.sge
#$ -N fmriprep_postproc
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q short.q
#$ -l h_vmem=4G
#$ -o ${fmriprep_folder}/SGE_commands/oe/fMRIPrep_postprocessing.out
#$ -e ${fmriprep_folder}/SGE_commands/oe/fMRIPrep_postprocessing.err
#$ -t 1-${N_subj}

curr_subID=\$(cat ${fmriprep_folder}/subIDlist | awk "NR==\${SGE_TASK_ID}")

# 1. nuisance regression
awk '{print \$1"\t"\$2"\t"\$(NF-5)"\t"\$(NF-4)"\t"\$(NF-3)"\t"\$(NF-2)"\t"\$(NF-1)"\t"\$NF}' \
	${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-confounds_regressors.tsv \
	> ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-Jmod_basic_confounds_regressors.tsv

tail -n +2 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-Jmod_basic_confounds_regressors.tsv \
		   > ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-Jmod_basic_confounds_no_header_regressors.tsv

fslmaths ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold \
		 -Tmean \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_Tmean_bold

fsl_glm -i ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold \
		-d ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_desc-Jmod_basic_confounds_no_header_regressors.tsv \
		--demean \
		--out_res=${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold

fslmaths ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
		 -add ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_Tmean_bold \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold

# 2. spatial smoothing
3dBlurToFWHM -input ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold.nii.gz \
			 -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold_blur \
			 -mask ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz \
			 -FWHM 5

# 3. temporal filtering (bandpass)
3dBandpass -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold_blur_bandpass \
		   -mask ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz \
		   0.009 0.08 \
		   ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold_blur+tlrc

# 4. convert to NIFTI and cleanup
rm -f ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold.nii.gz
3dAFNItoNIFTI -prefix ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
			  ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold_blur_bandpass+tlrc
gzip ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold.nii
rm -f ${fmriprep_folder}/\${curr_subID}/func/*.BRIK \
	  ${fmriprep_folder}/\${curr_subID}/func/*.HEAD

# 5. remove first 5 volumes to reach steady state
fslroi ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
	   ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
	   5 -1

# 6. add Tmean
fslmaths ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
		 -add ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_Tmean_bold \
		 ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold

# 7. MNI2009c to MNI6
flirt -in ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_boldref \
	  -ref ${FUTURE_folder}/fMRI/fMRIPrep/postproc_scripts/MNI2009to6/mni_icbm152_t2_tal_nlin_asym_09c_brain \
	  -omat ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_desc-fmri2mni2009_flirtMAT.mat \
	  -out ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-re_rigid2mni2009_boldref \
	  -nosearch
convert_xfm -omat ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_desc-fmri2mni6_flirtMAT.mat \
			-concat ${FUTURE_folder}/fMRI/fMRIPrep/postproc_scripts/MNI2009to6/MNI_2009to6.mat \
					${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_desc-fmri2mni2009_flirtMAT.mat
flirt -in ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI152NLin2009cAsym_desc-afterJmodPostproc_bold \
	  -ref ${FUTURE_folder}/fMRI/fMRIPrep/postproc_scripts/MNI2009to6/MNI152_T1_2mm.nii.gz \
	  -applyxfm \
	  -init ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_desc-fmri2mni6_flirtMAT.mat \
	  -out ${fmriprep_folder}/\${curr_subID}/func/\${curr_subID}_task-rest_space-MNI2mm_desc-afterJmodPostproc_bold
EOF

# qsub ${fmriprep_folder}/SGE_commands/fMRIPrep_postprocessing.sge