#!/bin/bash

cohortFolder=$1
cleanup_mode=$2
iso_resample_scale=$3
Ncpus=$4

mkdir -p ${cohortFolder}/groupICA/resampled_MNI



echo 1 0 0 0 > ${cohortFolder}/groupICA/resampled_MNI/eye.mat
echo 0 1 0 0 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat
echo 0 0 1 0 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat
echo 0 0 0 1 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat


while read studyFolder
do
	subjID=$(basename ${studyFolder})

	case ${cleanup_mode} in
		aroma)
			workingDir=${studyFolder}/${subjID}_func.feat
			postcleanup_folder=${workingDir}/post-ICA_AROMA
			;;
		fix)
			workingDir=${studyFolder}/${subjID}_func.ica
			postcleanup_folder=${workingDir}/post-FIX
			;;
	esac

	final_preproc_data_indSpace=${postcleanup_folder}/nuisanceReg_Tfiltered_cleanedup_func.nii.gz

	noNuisanceReg_func=${postcleanup_folder}/Tfiltered_cleanedup_func.nii.gz

	final_preproc_data_MNI=${postcleanup_folder}/final_cleanedup_func_std_space

	re='^[0-9]+$'

	if [[ ${Ncpus} =~ $re ]]; then

		if [ ! -f "${final_preproc_data_indSpace}" ] && \
			[ -f "${noNuisanceReg_func}" ]; then
				echo "no nuisance regression was conducted, copy cleaned up func to final func ..."
				fslmaths ${noNuisanceReg_func} ${final_preproc_data_indSpace}
		fi

		# flirt -in ${final_preproc_data_indSpace} \
		#       -applyisoxfm ${iso_resample_scale} \
		#       -init ${workingDir}/reg/example_func2standard.mat \
		#       -ref ${workingDir}/reg/standard.nii.gz \
	 	#    	-out ${postcleanup_folder}/final_cleanedup_func_std_space \
	 	#      	&

	 	applywarp --ref=${workingDir}/reg/standard \
	 			  --in=${final_preproc_data_indSpace} \
	 			  --warp=${workingDir}/reg/highres2standard_warp.nii.gz \
	 			  --premat=${workingDir}/reg/example_func2highres.mat \
	 			  --out=${postcleanup_folder}/final_cleanedup_func_std_space \
	 			  &



	    [ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	elif [ "${Ncpus}" = "par_cluster" ]; then

			cat << EOF > ${cohortFolder}/SGE_commands/${subjID}_L-lv_normaliseFunc2MNI.sge
#!/bin/bash

#$ -N sub${subjID}_normaliseFunc2MNI
#$ -V
#$ -cwd
#$ -pe smp 1
#$ -q standard.q
#$ -l h_vmem=4G
#$ -o ${cohortFolder}/SGE_commands/oe/${subjID}_normaliseFunc2MNI.out
#$ -e ${cohortFolder}/SGE_commands/oe/${subjID}_normaliseFunc2MNI.err

module load fsl/5.0.11

if [ ! -f "${final_preproc_data_indSpace}" ] && [ -f "${noNuisanceReg_func}" ]; then
		echo "no nuisance regression was conducted, copy cleaned up func to final func ..."
		fslmaths ${noNuisanceReg_func} ${final_preproc_data_indSpace}
fi

# warp fMRI to MNI
applywarp --ref=${workingDir}/reg/standard \
	 			  --in=${final_preproc_data_indSpace} \
	 			  --warp=${workingDir}/reg/highres2standard_warp.nii.gz \
	 			  --premat=${workingDir}/reg/example_func2highres.mat \
	 			  --out=${postcleanup_folder}/final_cleanedup_func_std_space

# resample
flirt -in ${final_preproc_data_MNI} \
			  -ref ${final_preproc_data_MNI} \
			  -applyisoxfm ${iso_resample_scale} \
			  -init ${cohortFolder}/groupICA/resampled_MNI/eye.mat \
			  -out ${final_preproc_data_MNI}
EOF
	fi

      	  
done < ${cohortFolder}/studyFolder.list


# resample
re='^[0-9]+$'

if [[ ${Ncpus} =~ $re ]]; then
	
	wait

	# echo 1 0 0 0 > ${cohortFolder}/groupICA/resampled_MNI/eye.mat
	# echo 0 1 0 0 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat
	# echo 0 0 1 0 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat
	# echo 0 0 0 1 >> ${cohortFolder}/groupICA/resampled_MNI/eye.mat

	# isotropic resampling
	while read studyFolder
	do
		subjID=$(basename ${studyFolder})

		case ${cleanup_mode} in
			aroma)
				workingDir=${studyFolder}/${subjID}_func.feat
				postcleanup_folder=${workingDir}/post-ICA_AROMA
				;;
			fix)
				workingDir=${studyFolder}/${subjID}_func.ica
				postcleanup_folder=${workingDir}/post-FIX
				;;
		esac

		final_preproc_data_MNI=${postcleanup_folder}/final_cleanedup_func_std_space


		flirt -in ${final_preproc_data_MNI} \
			  -ref ${final_preproc_data_MNI} \
			  -applyisoxfm ${iso_resample_scale} \
			  -init ${cohortFolder}/groupICA/resampled_MNI/eye.mat \
			  -out ${final_preproc_data_MNI} \
			  &

		[ $(jobs | wc -l) -gt ${Ncpus} ] && wait

	done < ${cohortFolder}/studyFolder.list

	wait
fi