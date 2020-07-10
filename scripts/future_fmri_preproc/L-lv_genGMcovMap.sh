#!/bin/bash

# DESCRIPTION
# ===============================================================
#
# This script generates GM covariate map for voxel-wise adjusting
# for GM in higher level analyses. 
#
#
# DEPENDENCIES
# ===============================================================
#
# This script requires fsl_anat to be run before. fsl_anat should
# have been run in *L-lv_genWMCSFts.sh*
#
#


genGMcovMap(){
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

	# creat FAST T1 to SPM T1 mat
	flirt -in ${fsl_anat_dir}/T1_biascorr_brain.nii.gz \
		  -ref ${workingDir}/reg/highres.nii.gz \
		  -omat ${workingDir}/reg/fast2spm.mat \
		  -dof 6

	# pve1 - FAST to SPM
	flirt -in ${fsl_anat_dir}/T1_fast_pve_1.nii.gz \
		  -applyxfm \
		  -init ${workingDir}/reg/fast2spm.mat \
		  -ref ${workingDir}/reg/highres.nii.gz \
		  -out ${fsl_anat_dir}/T1_fast_pve_1_fast2spm

	# pve1 - SPM T1 to MNI
	flirt -in ${fsl_anat_dir}/T1_fast_pve_1_fast2spm \
		  -applyisoxfm ${iso_resample_scale} \
		  -init ${workingDir}/reg/highres2standard.mat \
		  -ref ${workingDir}/reg/standard.nii.gz \
		  -out ${cohortFolder}/confounds/GMcovMap/${subjID}_gmCovMap_MNI_${iso_resample_scale}mm
}



cohortFolder=$1
cleanup_mode=$2
iso_resample_scale=$3
Ncpus=$4

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

		genGMcovMap ${fsl_anat_dir} \
					${workingDir} \
					${iso_resample_scale} \
					${cohortFolder} \
					${subjID} \
					&

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	elif [ "${Ncpus}" = "par_cluster" ]; then

		cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_genGMcovMap.sge
#!/bin/bash

#$ -N sub${subjID}_genGMcovMap
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_genGMcovMap.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_genGMcovMap.err

module load fsl/5.0.11

flirt -in ${fsl_anat_dir}/T1_biascorr_brain.nii.gz -ref ${workingDir}/reg/highres.nii.gz -omat ${workingDir}/reg/fast2spm.mat -dof 6

flirt -in ${fsl_anat_dir}/T1_fast_pve_1.nii.gz -applyxfm -init ${workingDir}/reg/fast2spm.mat -ref ${workingDir}/reg/highres.nii.gz -out ${fsl_anat_dir}/T1_fast_pve_1_fast2spm

flirt -in ${fsl_anat_dir}/T1_fast_pve_1_fast2spm -applyisoxfm ${iso_resample_scale} -init ${workingDir}/reg/highres2standard.mat -ref ${workingDir}/reg/standard.nii.gz -out ${cohortFolder}/confounds/GMcovMap/${subjID}_gmCovMap_MNI_${iso_resample_scale}mm
EOF
	fi

done < ${cohortFolder}/studyFolder.list

wait