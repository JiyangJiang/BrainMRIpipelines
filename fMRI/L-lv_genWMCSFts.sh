#!/bin/bash

# USAGE
# =================================================================
#
# $1 = path to cohort folder
#
# $2 = cleanup method - 'aroma' or 'fix'
#
# $3 = 'par_cluster' if running on cluster, or the number
#      of CPU cores to use if running on workstation.
#      Note that 'par_cluster' will only generate sge script
#      without qsub.
#
# $4 = path to CNS
#
# $5 = path to SPM12
#
# =================================================================

genWMCSFts(){

	fsl_anat_dir=$1
	workingDir=$2
	postcleanup_folder=$3
	cohortFolder=$4
	subjID=$5
	CNSpath=$6
	SPM12path=$7

	# March 14, 2019
	# ----------------------------------------------------------------------
	# An issue was noted - T1 was skull-stripped with SPM which, sometimes,
	# is not in the same space (orientation) as the T1 and the derivatives
	# in FSL FAST. This causes the csf_sbj_func_space and wm_sbj_func_space,
	# and following derivatives from the following code not in the correct
	# space.
	#
	# SOLUTION : Conduct a two-step flirt. First, register FSL FAST 
	# T1_biascorr_brain.nii.gz to SPM skull-stripped T1, outputting mat. 
	# Second, register FAST WM/CSF segments (after applying the first flirt) 
	# to example_func with the reg/highres2example_func.mat
	#
	# Note that these two matrices cannot be concatenated (convert_xfm -concat)
	# probably because in the first flirt -ref is SPM T1, and the second flirt
	# -ref is example_func
	# ----------------------------------------------------------------------
	#
	# April 9, 2019
	# ----------------------------------------------------------------------
	# This is now not implemented any more, because WM and CSF masks are now
	# derived from SPM
	# ----------------------------------------------------------------------


	# # creat FAST T1 to SPM T1 mat
	# flirt -in ${fsl_anat_dir}/T1_biascorr_brain.nii.gz \
	# 	  -ref ${workingDir}/reg/highres.nii.gz \
	# 	  -omat ${workingDir}/reg/fast2spm.mat \
	# 	  -dof 6



	# ==================================================================================
	# Generate conservative wm and csf masks per the recommendations of Pruim et al 2015
	# ==================================================================================
	#
	# ---------------------------------------------------
	# Threshold (robust range at 95%) subject space pve's
	# ---------------------------------------------------
	#
	# Some info on FAST-generated PVE's:
	# ----------------------------------
	# The "partial volume" represent the fraction of each voxel being tissue X
	# (pve0 - CSF; pve1 - GM; pve2 - WM). J: it is like a probability tissue map.
	# ----------------------------------------------------------------------------
	#
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#
	# April 9, 2019
	#
	# - use my CNSP_getLatVentricles.m code to segment lateral ventricles and extract
	#   mean timeseries from lateral ventricles as the mean timeseries of CSF
	#
	# - WM mask is also now derived from SPM WM segmentation (c2*) using 
	#   CNSP_reverse_registration_wMx.m
	#
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	# April 9, 2019 : use CNSP_getLatVentricles.m to extract lateral ventricles
	# -------------------------------------------------------------------------
	matlab  -nodisplay \
			-nosplash \
			-r \
			"addpath ('${CNSpath}/Scripts');\
			 system ('gunzip ${workingDir}/example_func.nii.gz');\
			 vent = CNSP_getLatVentricles ('${workingDir}/example_func.nii',\
			 							   '${cohortFolder}/${subjID}/${subjID}_anat.nii',\
			 							   '${cohortFolder}/${subjID}/temp',\
			 							   '${SPM12path}');\
			 system ('gzip ${workingDir}/example_func.nii');\
			 system ('mv ${cohortFolder}/${subjID}/temp/rventricular_mask.nii ${cohortFolder}/${subjID}');\
			 exit"
	
	# slight erosion on ventricular mask to get conservative mask
	mv ${cohortFolder}/${subjID}/rventricular_mask.nii \
		${cohortFolder}/${subjID}/${subjID}_ventricular_mask.nii

	fslmaths ${cohortFolder}/${subjID}/${subjID}_ventricular_mask \
			 -kernel boxv3 1 3 1 \
			 -ero \
			 ${cohortFolder}/${subjID}/${subjID}_ventricular_mask_ero

	cp ${cohortFolder}/${subjID}/${subjID}_ventricular_mask_ero.nii.gz \
		${postcleanup_folder}/nuisance_masks/csf_mask.nii.gz


	# April 9, 2019 : generate WM mask using c2 segmentation from SPM, and reverse
	#                 register with CNSP_reverse_registration_wMx.m
	# ----------------------------------------------------------------------------
	c2seg=`ls ${cohortFolder}/${subjID}/temp/c2*.nii*`

	matlab -nodisplay \
		   -nosplash \
		   -r \
		   "addpath ('${CNSpath}/Scripts', '${SPM12path}');\
		   	system ('gunzip ${workingDir}/example_func.nii.gz');\
		   	wm_mask = CNSP_reverse_registration_wMx ('${workingDir}/example_func.nii',\
		   								   			 '${cohortFolder}/${subjID}/${subjID}_anat.nii',\
		   								   			 '${c2seg}',\
		   								   			 'Tri');\
		   	system ('gzip ${workingDir}/example_func.nii');\
			system (['mv ' wm_mask ' ${cohortFolder}/${subjID}']);\
		   	exit"


	# threshold to get conservative WM mask
	mv ${cohortFolder}/${subjID}/rc2${subjID}_anat.nii \
		${cohortFolder}/${subjID}/${subjID}_wm_mask.nii

	fslmaths ${cohortFolder}/${subjID}/${subjID}_wm_mask \
			 -thr 0.95 \
			 -bin \
			 ${cohortFolder}/${subjID}/${subjID}_wm_mask_thr

	cp ${cohortFolder}/${subjID}/${subjID}_wm_mask_thr.nii.gz \
		${postcleanup_folder}/nuisance_masks/wm_mask.nii.gz

	# fslmaths ${fsl_anat_dir}/T1_fast_pve_2.nii.gz \
	# 		 -thrP 95 \
	# 		 ${postcleanup_folder}/nuisance_masks/wm_sbj_thrp95.nii.gz

	# fslmaths ${fsl_anat_dir}/T1_fast_pve_0.nii.gz \
	# 		 -thrP 95 \
	# 		 ${postcleanup_folder}/nuisance_masks/csf_sbj_thrp95.nii.gz


	# Threshold (robust range at 95%) MNI standard tissue-priors
	# ----------------------------------------------------------
	# fslmaths $FSLDIR/data/standard/tissuepriors/avg152T1_csf.hdr \
	# 		 -thrP 95 \
	# 		 ${postcleanup_folder}/nuisance_masks/csf_MNIhdr_thrp95

	# fslmaths $FSLDIR/data/standard/tissuepriors/avg152T1_white.hdr \
	# 		 -thrP 95 \
	# 		 ${postcleanup_folder}/nuisance_masks/wm_MNIhdr_thrp95


	# Register subject space thresholded masks to subject/native functional space
	# ---------------------------------------------------------------------------

	# # csf - FAST to SPM
	# flirt -in ${postcleanup_folder}/nuisance_masks/csf_sbj_thrp95.nii.gz \
	# 	  -applyxfm \
	# 	  -init ${workingDir}/reg/fast2spm.mat \
	# 	  -ref ${workingDir}/reg/highres.nii.gz \
	# 	  -out ${postcleanup_folder}/nuisance_masks/csf_sbj_thrp95_fast2spm
	# # csf - SPM T1 to func
	# flirt -in ${postcleanup_folder}/nuisance_masks/csf_sbj_thrp95_fast2spm \
	# 	  -applyxfm \
	# 	  -init ${workingDir}/reg/highres2example_func.mat \
	# 	  -ref ${workingDir}/reg/example_func.nii.gz \
	# 	  -out ${postcleanup_folder}/nuisance_masks/csf_sbj_func_space

	# # wm - FAST to SPM
	# flirt -in ${postcleanup_folder}/nuisance_masks/wm_sbj_thrp95.nii.gz \
	# 	  -applyxfm \
	# 	  -init ${workingDir}/reg/fast2spm.mat \
	# 	  -ref ${workingDir}/reg/highres.nii.gz \
	# 	  -out ${postcleanup_folder}/nuisance_masks/wm_sbj_thrp95_fast2spm
	# # wm - SPM T1 to func
	# flirt -in ${postcleanup_folder}/nuisance_masks/wm_sbj_thrp95_fast2spm \
	#       -applyxfm \
	#       -init ${workingDir}/reg/highres2example_func.mat \
	#       -ref ${workingDir}/reg/example_func.nii.gz \
	#       -out ${postcleanup_folder}/nuisance_masks/wm_sbj_func_space


	# Register MNI space thresholded masks to subject/native functional space
	# -----------------------------------------------------------------------
	# only applying affine transformation. This is vague compared to inversed
	# warping + registration, but may be enough for this particular purpose.
	# The above commented scripts implement inv warping + reg.

	# flirt -in ${postcleanup_folder}/nuisance_masks/csf_MNIhdr_thrp95.nii.gz \
	#       -applyxfm \
	#       -init ${workingDir}/reg/standard2example_func.mat \
	#       -ref ${workingDir}/reg/example_func.nii.gz \
	#       -out ${postcleanup_folder}/nuisance_masks/csf_MNIhdr_func_space

	# flirt -in ${postcleanup_folder}/nuisance_masks/wm_MNIhdr_thrp95.nii.gz \
	#       -applyxfm \
	#       -init ${workingDir}/reg/standard2example_func.mat \
	#       -ref ${workingDir}/reg/example_func.nii.gz \
	#       -out ${postcleanup_folder}/nuisance_masks/wm_MNIhdr_func_space


	# Multiply each csf and wm mask by its counterpart (subject*MNI) 
	# to generate respective conservative mask
	# --------------------------------------------------------------
	# added -thrP 80

	# fslmaths ${postcleanup_folder}/nuisance_masks/csf_sbj_func_space.nii.gz \
	# 		 -mul ${postcleanup_folder}/nuisance_masks/csf_MNIhdr_func_space.nii.gz \
	# 		 -thrP 80 \
	# 		 ${postcleanup_folder}/nuisance_masks/csf_conservative

	# fslmaths ${postcleanup_folder}/nuisance_masks/wm_sbj_func_space.nii.gz \
	# 		 -mul ${postcleanup_folder}/nuisance_masks/wm_MNIhdr_func_space.nii.gz \
	# 		 -thrP 80 \
	# 		 ${postcleanup_folder}/nuisance_masks/wm_conservative


	# Take mean of csf and wm timeseries and paste into design matrix 
	# (text file, so this is temporal regression within wm and csf)
	# J : one mean value for one volume.
	# ---------------------------------------------------------------
	# - removed --no_bin flag from original script
	# ---------------------------------------------------------------

	# fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
	#           -m ${postcleanup_folder}/nuisance_masks/wm_conservative.nii.gz \
	#           -o ${cohortFolder}/confounds/WMmeants/${subjID}_wm_timeseries.txt

	fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
	          -m ${postcleanup_folder}/nuisance_masks/wm_mask.nii.gz \
	          -o ${cohortFolder}/confounds/WMmeants/${subjID}_wm_timeseries.txt

	# fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
	#           -m ${postcleanup_folder}/nuisance_masks/csf_conservative.nii.gz \
	#           -o ${cohortFolder}/confounds/CSFmeants/${subjID}_csf_timeseries.txt

	fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
	          -m ${postcleanup_folder}/nuisance_masks/csf_mask.nii.gz \
	          -o ${cohortFolder}/confounds/CSFmeants/${subjID}_csf_timeseries.txt
	          
}







cohortFolder=$1
cleanup_mode=$2
Ncpus=$3
CNSpath=$4
SPM12path=$5


while read studyFolder
do

	subjID=$(basename ${studyFolder})
	fsl_anat_dir=${studyFolder}/${subjID}_anat.anat

	case ${cleanup_mode} in
		aroma)
			workingDir=${studyFolder}/${subjID}_func.feat
			postcleanup_folder=${workingDir}/post-ICA_AROMA
			mkdir -p ${postcleanup_folder}/nuisance_masks
			;;
		fix)
			workingDir=${studyFolder}/${subjID}_func.ica
			postcleanup_folder=${workingDir}/post-FIX
			mkdir -p ${postcleanup_folder}/nuisance_masks
			;;
	esac

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then

		genWMCSFts ${fsl_anat_dir} \
				   ${workingDir} \
				   ${postcleanup_folder} \
				   ${cohortFolder} \
				   ${subjID} \
				   ${CNSpath} \
				   ${SPM12path} \
				   &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	elif [ "${Ncpus}" = "par_cluster" ]; then

			cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_genWMCSFts.sge
#!/bin/bash

#$ -N sub${subjID}_genWMCSFts
#$ -V
#$ -cwd
#$ -pe smp 2
#$ -q standard.q
#$ -l h_vmem=16G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_genWMCSFts.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_genWMCSFts.err

module load fsl/5.0.11 matlab/R2018a

matlab  -nodisplay \
		-nosplash \
		-r \
		"addpath ('${CNSpath}/Scripts');\
		 system ('gunzip -f ${workingDir}/example_func.nii.gz');\
		 vent = CNSP_getLatVentricles ('${workingDir}/example_func.nii',\
		 							   '${cohortFolder}/${subjID}/${subjID}_anat.nii',\
		 							   '${cohortFolder}/${subjID}/temp',\
		 							   '${SPM12path}');\
		 system ('gzip -f ${workingDir}/example_func.nii');\
		 system ('mv ${cohortFolder}/${subjID}/temp/rventricular_mask.nii ${cohortFolder}/${subjID}');\
		 exit"

# slight erosion on ventricular mask to get conservative mask
mv ${cohortFolder}/${subjID}/rventricular_mask.nii \
	${cohortFolder}/${subjID}/${subjID}_ventricular_mask.nii

fslmaths ${cohortFolder}/${subjID}/${subjID}_ventricular_mask \
		 -kernel boxv3 1 3 1 \
		 -ero \
		 ${cohortFolder}/${subjID}/${subjID}_ventricular_mask_ero

cp ${cohortFolder}/${subjID}/${subjID}_ventricular_mask_ero.nii.gz \
	${postcleanup_folder}/nuisance_masks/csf_mask.nii.gz



c2seg=\`ls ${cohortFolder}/${subjID}/temp/c2*.nii*\`

matlab -nodisplay \
	   -nosplash \
	   -r \
	   "addpath ('${CNSpath}/Scripts', '${SPM12path}');\
	   	system ('gunzip -f ${workingDir}/example_func.nii.gz');\
	   	wm_mask = CNSP_reverse_registration_wMx ('${workingDir}/example_func.nii',\
	   								   			 '${cohortFolder}/${subjID}/${subjID}_anat.nii',\
	   								   			 '\${c2seg}',\
	   								   			 'Tri');\
	   	system ('gzip -f ${workingDir}/example_func.nii');\
		system (['mv ' wm_mask ' ${cohortFolder}/${subjID}']);\
	   	exit"


# threshold to get conservative WM mask
mv ${cohortFolder}/${subjID}/rc2${subjID}_anat.nii \
	${cohortFolder}/${subjID}/${subjID}_wm_mask.nii

fslmaths ${cohortFolder}/${subjID}/${subjID}_wm_mask \
		 -thr 0.95 \
		 -bin \
		 ${cohortFolder}/${subjID}/${subjID}_wm_mask_thr

cp ${cohortFolder}/${subjID}/${subjID}_wm_mask_thr.nii.gz \
	${postcleanup_folder}/nuisance_masks/wm_mask.nii.gz



fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
          -m ${postcleanup_folder}/nuisance_masks/wm_mask.nii.gz \
          -o ${cohortFolder}/confounds/WMmeants/${subjID}_wm_timeseries.txt

fslmeants -i ${postcleanup_folder}/Tfiltered_cleanedup_func \
          -m ${postcleanup_folder}/nuisance_masks/csf_mask.nii.gz \
          -o ${cohortFolder}/confounds/CSFmeants/${subjID}_csf_timeseries.txt
EOF
	fi
	

done < ${cohortFolder}/studyFolder.list

wait