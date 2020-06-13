#!/bin/bash

# DESCRIPTION
# --------------------------------------------------------------------------------------------------
# This script conducts tractography on Raijin on BIDS-format DWI data acquired with SINGLE shell.
#
#
# PRE-ASSUMPTION
# --------------------------------------------------------------------------------------------------
# mrtrix_preprocessing_BIDS_Raijin.sh should be run prior to this script to pre-process DWI data.
#
#
# USAGE
# --------------------------------------------------------------------------------------------------
# $1 = path to BIDS project folder
# $2 = 'subq' or 'noSubq'. noSubq may be useful for job dependency, i.e. wait for other scipt to
#      finish to execute this one.
#
#
# NOTES AND REFERENCES
# --------------------------------------------------------------------------------------------------
# The current script is based on :
# http://community.mrtrix.org/t/lmaxes-specified-does-not-match-number-of-tissues/500
# which used "dwi2response dhollander" for WM GM CSF responses and "dwi2fod msmt_csd" for 
# multi-tissue CSD with only WM and CSF (i.e. ditching the GM response at this stage).
# This is suitable for single shell data (with low b-values). Refer to the website for more details.
#
#
# --------------------------------------------------------------------------------------------------
#
# Dr. Jiyang Jiang,  February 2019.
#
# --------------------------------------------------------------------------------------------------


postproc_dist(){

	BIDS_folder=$1
	unbiased_mif=$2
	mask=$3
	subjID=$4
	subq_flag=$5


	# nthreads
	nthreads=8



	cd ${BIDS_folder}/derivatives/mrtrix

	raijin_tractography_cmd="raijin_cmds/tractography/${subjID}_raijin_tractography_cmd.txt"

	## Project ID
	echo "#PBS -P ba64" > ${raijin_tractography_cmd}

	## Queue type
	echo "#PBS -q normal" >> ${raijin_tractography_cmd}

	## Wall time
	echo "#PBS -l walltime=06:00:00" >> ${raijin_tractography_cmd}

	## Number of CPU cores
	echo "#PBS -l ncpus=${nthreads}" >> ${raijin_tractography_cmd}

	## requested memory per node
	echo "#PBS -l mem=16GB" >> ${raijin_tractography_cmd}

	## Disk space
	echo "#PBS -l jobfs=4GB" >> ${raijin_tractography_cmd}

	## Job is excuted from current working dir instead of home
	echo "#PBS -l wd" >> ${raijin_tractography_cmd}

	## redirect output and error
	echo "#PBS -e ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography/oe/${subjID}.err" >> ${raijin_tractography_cmd}
	echo "#PBS -o ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography/oe/${subjID}.out" >> ${raijin_tractography_cmd}


	# load python
	echo "module load python/2.7.11" >> ${raijin_tractography_cmd}

	# load fsl/5.0.4 - my local fsl installation reported error
	# when running 5ttgen fsl, which might be due to libopenblas
	# was not properly installed?
	echo "module load fsl/5.0.4" >> ${raijin_tractography_cmd}

	echo "cd ${BIDS_folder}/derivatives/mrtrix" >> ${raijin_tractography_cmd}

	# =================================== #
	# Step 1 : estimate response function #
	# =================================== #
	echo "dwi2response dhollander ${unbiased_mif} \
								  response_func/${subjID}_wm.txt \
								  response_func/${subjID}_gm.txt \
								  response_func/${subjID}_csf.txt \
								  -voxels response_func/${subjID}_voxels.mif \
								  -nthreads ${nthreads} \
								  -force" >> ${raijin_tractography_cmd}


	# ====================================================== #
	# Step 2 : estimate fibre orientation distribution (FOD) #
	# ====================================================== #
	echo "dwi2fod msmt_csd ${unbiased_mif} \
						   -mask ${mask} \
				           response_func/${subjID}_wm.txt fod/${subjID}_wmfod.mif \
				           response_func/${subjID}_csf.txt fod/${subjID}_csffod.mif \
				           -force" >> ${raijin_tractography_cmd}


	# ============================================ #
	# Step 3 : intensity normalisation of FOD maps #
	# ============================================ #
	echo "mtnormalise fod/${subjID}_wmfod.mif fod_norm/${subjID}_wmfod_norm.mif \
			          fod/${subjID}_csffod.mif fod_norm/${subjID}_csffod_norm.mif \
			          -mask ${mask} \
			          -force" >> ${raijin_tractography_cmd}


	# ========================== #
	# Step 4 : create 5tt images #
	# ========================== #
	if [ -f "$(ls ${BIDS_folder}/${subjID}/anat/${subjID}_*run-01*_T1w.nii 2>/dev/null)" ] || \
	   [ -f "$(ls ${BIDS_folder}/${subjID}/anat/${subjID}_*run-01*_T1w.nii.gz 2>/dev/null)" ]; then
		t1=`ls ${BIDS_folder}/${subjID}/anat/${subjID}_*run-01*_T1w.nii*`
	elif [ -f "$(ls ${BIDS_folder}/${subjID}/anat/${subjID}_*T1w.nii 2>/dev/null)" ] || \
		 [ -f "$(ls ${BIDS_folder}/${subjID}/anat/${subjID}_*T1w.nii.gz 2>/dev/null)" ]; then
		t1=`ls ${BIDS_folder}/${subjID}/anat/${subjID}_*T1w.nii*`
	else
		echo "Error : ${subjID} has no T1."
	fi

	echo "mrconvert ${t1} orig_t1w/${subjID}_T1w.mif -force" >> ${raijin_tractography_cmd}

	echo "5ttgen fsl orig_t1w/${subjID}_T1w.mif 5tt_native/${subjID}_5tt_native.mif -force" >> ${raijin_tractography_cmd}


	# ================================================================ #
	# Step 5 : 5tt --> DWI registration, i.e. DWI->T1 and then reverse #
	# ================================================================ #
	# extract b0 as reference
	echo "dwiextract -force ${unbiased_mif} - -bzero | mrmath - mean b0/${subjID}_mean_b0.mif -axis 3" >> ${raijin_tractography_cmd}
	echo "mrconvert -force -coord 3 0 5tt_native/${subjID}_5tt_native.mif 5tt_native/${subjID}_5tt_native_vol1.mif" >> ${raijin_tractography_cmd}

	echo "mrconvert -force b0/${subjID}_mean_b0.mif b0/${subjID}_mean_b0.nii.gz" >> ${raijin_tractography_cmd}
	echo "mrconvert -force 5tt_native/${subjID}_5tt_native_vol1.mif 5tt_native/${subjID}_5tt_native_vol1.nii.gz" >> ${raijin_tractography_cmd}

	echo "flirt -in b0/${subjID}_mean_b0.nii.gz \
			    -ref 5tt_native/${subjID}_5tt_native_vol1.nii.gz \
			    -interp nearestneighbour \
			    -dof 6 \
			    -omat DWI_to_T1w/${subjID}_diff2annat_FSL.mat" >> ${raijin_tractography_cmd}

	echo "transformconvert DWI_to_T1w/${subjID}_diff2annat_FSL.mat \
						   b0/${subjID}_mean_b0.nii.gz \
						   5tt_native/${subjID}_5tt_native_vol1.nii.gz \
						   flirt_import \
						   DWI_to_T1w/${subjID}_diff2annat_mrtrix.txt \
						   -force" >> ${raijin_tractography_cmd}

	echo "mrtransform 5tt_native/${subjID}_5tt_native.mif \
					  -linear DWI_to_T1w/${subjID}_diff2annat_mrtrix.txt \
					  -inverse \
					  5tt_dwi/${subjID}_5tt_dwi.mif \
					  -force" >> ${raijin_tractography_cmd}


	# ================================================== #
	# Step 6 : Create GM/WM boundary as streamline seeds #
	# ================================================== #
	echo "5tt2gmwmi -force 5tt_dwi/${subjID}_5tt_dwi.mif gmwmBoundary_dwi/${subjID}_gmwmSeed_dwi.mif" >> ${raijin_tractography_cmd}


	# ============================================================ #
	# Step 7 : anatomically constrained probabilistic tractography #
	# ============================================================ #
	echo "tckgen -act 5tt_dwi/${subjID}_5tt_dwi.mif \
			     -backtrack \
			     -nthreads ${nthreads} \
			     -seed_gmwmi gmwmBoundary_dwi/${subjID}_gmwmSeed_dwi.mif \
			     -select 10000000 \
			     fod_norm/${subjID}_wmfod_norm.mif \
			     tck/${subjID}_track_10mio.tck \
			     -force" >> ${raijin_tractography_cmd}

	# subset 200k tcks for visualisation
	echo "tckedit -force tck/${subjID}_track_10mio.tck -number 200k tck/${subjID}_track_200k.tck" >> ${raijin_tractography_cmd}

	# SIFT to 1 million tracks
	echo "tcksift -act 5tt_dwi/${subjID}_5tt_dwi.mif \
		          -term_number 1000000 \
		          -nthreads ${nthreads} \
		          tck/${subjID}_track_10mio.tck \
		          fod_norm/${subjID}_wmfod_norm.mif \
		          tck/${subjID}_sift_1mio.tck \
		          -force" >> ${raijin_tractography_cmd}

	# downsample sift results to 200k for visualisation
	echo "tckedit -force tck/${subjID}_sift_1mio.tck -number 200k tck/${subjID}_track_200k_afterSIFT.tck" >> ${raijin_tractography_cmd}

	# submit job, wait ${subjID}_preprocessing to finish before executing
	# qsub -W depend=afterany:JOBNAME.${subjID}_mrtrix_preprocessing \
	# 	 -N ${subjID}_mrtrix_tractography \
	# 	 ${raijin_tractography_cmd}
	case ${subq} in
		subq)
			qsub -N ${subjID}_mrtrix_tractography \
				 ${raijin_tractography_cmd}
			;;
		noSubq)
			# not qsub, useful for job dependency
			;;
	esac
	
}

postproc_main(){

	BIDS_folder=$1
	subq_flag=$2

	# if [ -d "${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/response_func" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/response_func
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/fod" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/fod
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/fod_norm" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/fod_norm
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/orig_t1w" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/orig_t1w
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/5tt_native" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/5tt_native
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/b0" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/b0
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/DWI_to_T1w" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/DWI_to_T1w
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/5tt_dwi" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/5tt_dwi
	# fi
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/gmwmBoundary_dwi" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/gmwmBoundary_dwi
	# fi	
	# if [ -d "${BIDS_folder}/derivatives/mrtrix/tck" ]; then
	# 	rm -fr ${BIDS_folder}/derivatives/mrtrix/tck
	# fi

	mkdir -p ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/tractography/oe
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/response_func
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/fod
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/fod_norm
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/orig_t1w
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/5tt_native
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/b0
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/DWI_to_T1w
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/5tt_dwi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/gmwmBoundary_dwi
	mkdir -p ${BIDS_folder}/derivatives/mrtrix/tck


	cd ${BIDS_folder}/derivatives/mrtrix

	if [ -d "${BIDS_folder}/derivatives/mrtrix/orig_mif/part_xaa" ]; then

		# if more than 200 (i.e. splitting into 200 each)
		for i in `ls -d orig_mif/part_x*`
		do
			for j in `ls ${i}/*.mif`
			do

				unbiased_mif_filename=$(basename ${j} | awk -F '.' '{print $1}')_den_unr_preproc_unbiased
				subjID=`basename ${j} | awk -F '_' '{print $1}'`
				
				postproc_dist ${BIDS_folder} \
							  ${j} \
							  dwi_mask/$(basename $i)/${unbiased_mif_filename}_mask.mif \
							  ${subjID} \
							  ${subq_flag}
			done
		done
	else

		# if less than 200 (i.e. no splitting)
		for k in `ls orig_mif/*.mif`
		do
			unbiased_mif_filename=$(basename ${k} | awk -F '.' '{print $1}')_den_unr_preproc_unbiased
			subjID=`basename ${k} | awk -F '_' '{print $1}'`

			postproc_dist ${BIDS_folder} \
						  ${k} \
						  dwi_mask/${unbiased_mif_filename}_mask.mif \
						  ${subjID} \
						  ${subq_flag}
		done
	fi


}

postproc_main $1 $2