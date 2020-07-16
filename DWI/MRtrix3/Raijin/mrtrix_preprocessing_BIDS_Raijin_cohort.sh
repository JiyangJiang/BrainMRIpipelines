#!/bin/bash

# ===================================================================== #
# This script distributes to GPU nodes for all DWI preprocessing steps. #
# Data needs to be in BIDS format.                                      #
# ===================================================================== #
#
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Some pre-assumptions to use this script :
#
# 1) each sub-xxxx folder must have dwi data
#
# 2) number of subjects less than 800
#
# 3) call this script with abs path or add path to .profile
#
# 4) data must be sorted out in BIDS format (test with BIDS validater)
#
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# USAGE :
#
# $1 = path to BIDS project folder
#
# $2 = 'subq' or 'noSubq'. noSubq may be useful for job dependency, i.e. wait for other scipt to
#      finish to execute this one.
#
# $3 = 'yesSkipOrg' if skipping generating mif and separating into 200
#      'yesSkipOrg' option is useful in the situation where one wants
#      to skip the initial nii/bvec/bval -> mif conversion, and separating
#      into portions (each with 200). This may be particularly useful in
#      debugging (and re-running) the following steps. Leave empty otherwise.
#

dist_cmd(){

	BIDS_folder=$1

	project=$2
	queue=$3
	ngpus=$4
	ncpus=$5
	mem=$6
	subq_flag=$7

	split_option=$8

	if [ "${split_option}" = "yesSplit" ]; then
		basedir=$9
	elif [ "${split_option}" = "noSplit" ]; then
		basedir=""
	fi

	cd ${BIDS_folder}/derivatives/mrtrix




	for mif in `ls orig_mif/${basedir}/*.mif`
	do
		subjID=$(basename ${mif} | awk -F '_' '{print $1}')


		raijin_preprocessing_cmd="raijin_cmds/preprocessing/${subjID}_raijin_preprocessing_cmd.txt"

		## Project ID
		echo "#PBS -P ${project}" > ${raijin_preprocessing_cmd}

		## Queue type
		echo "#PBS -q ${queue}" >> ${raijin_preprocessing_cmd}

		## Wall time
		echo "#PBS -l walltime=01:00:00" >> ${raijin_preprocessing_cmd}

		## Number of GPU and CPU cores
		echo "#PBS -l ngpus=${ngpus}" >> ${raijin_preprocessing_cmd}
		echo "#PBS -l ncpus=${ncpus}" >> ${raijin_preprocessing_cmd}
 
		## requested memory per node
		echo "#PBS -l mem=${mem}" >> ${raijin_preprocessing_cmd}

		## Disk space
		echo "#PBS -l jobfs=2GB" >> ${raijin_preprocessing_cmd}

		## Job is excuted from current working dir instead of home
		echo "#PBS -l wd" >> ${raijin_preprocessing_cmd}

		## redirect error and output
		echo "#PBS -e ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/preprocessing/oe/${subjID}.err" >> ${raijin_preprocessing_cmd}
		echo "#PBS -o ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/preprocessing/oe/${subjID}.out" >> ${raijin_preprocessing_cmd}

		case ${queue} in
			gpu)
				## load cuda for eddy_cuda
				# default eddy_cuda uses cuda 7.5
				echo "module load cuda/7.5" >> ${raijin_preprocessing_cmd}
				;;
			gpupascal)
				# gpupascal (Tesla Pascal P100) only compatible with cuda 8.0
				# call eddy_cuda8.0 correspondingly
				echo "module load cuda/8.0" >> ${raijin_preprocessing_cmd}
				;;
		esac	

		## load python 2.7 to avoid error of TypeError: decode() takes no keyword arguments
		echo "module load python/2.7.11" >> ${raijin_preprocessing_cmd}

		## unload fsl/5.0.4 (if mounted), and use my local fsl installation to prevent interference
		echo "module unload fsl/5.0.4" >> ${raijin_preprocessing_cmd}

		echo "cd ${BIDS_folder}/derivatives/mrtrix" >> ${raijin_preprocessing_cmd}

		# ++++++++++++++++ #
		# Step 1 : denoise #
		# ++++++++++++++++ #
		mif_filename=$(echo $(basename ${mif}) | awk -F '.' '{print $1}')
		echo "dwidenoise -force \
						 ${mif} \
						 denoise/${basedir}/${mif_filename}_den.mif \
						 -noise denoise/${basedir}/${mif_filename}_noi.mif" >> ${raijin_preprocessing_cmd}

		# +++++++++++++++ #
		# Step 2 : unring #
		# +++++++++++++++ #
		den_filename=${mif_filename}_den
		echo "mrdegibbs -force \
						denoise/${basedir}/${den_filename}.mif \
						unring/${basedir}/${den_filename}_unr.mif \
						-axes 0,1" >> ${raijin_preprocessing_cmd}

		# ++++++++++++++++++++++++ #
		# Step 3 : FSL's eddy_cuda #
		# ++++++++++++++++++++++++ #
		# convert mif to nii/bvec/bval
		unr_mif_filename=${den_filename}_unr
		echo "mrconvert -force \
						-export_grad_fsl unring/${basedir}/nii/${basedir}/${unr_mif_filename}.bvec \
										 unring/${basedir}/nii/${basedir}/${unr_mif_filename}.bval \
						unring/${basedir}/${den_filename}_unr.mif \
						unring/${basedir}/nii/${basedir}/${unr_mif_filename}.nii.gz" >> ${raijin_preprocessing_cmd}
		# folder to save eddy output
		echo "mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy" >> ${raijin_preprocessing_cmd}
		DWI_folder=$(dirname $(dirname $(dirname $(which $0))))
		unr_img_abspath=${BIDS_folder}/derivatives/mrtrix/unring/${basedir}/nii/${basedir}/${unr_mif_filename}.nii.gz
		invPE_b0=no_invPE
		acqparamsTXT=easy_acq_updown
		bvec=${BIDS_folder}/derivatives/mrtrix/unring/${basedir}/nii/${basedir}/${unr_mif_filename}.bvec
		bval=${BIDS_folder}/derivatives/mrtrix/unring/${basedir}/nii/${basedir}/${unr_mif_filename}.bval
		subj_eddy_out_folder=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy
		topup_flag=noTopup
		slm_option=linear
		line_index=1
		case ${queue} in
			gpu)
				eddy_cmd=eddy_cuda
				;;
			gpupascal)
				eddy_cmd="eddy_cuda8.0"
				;;
		esac
		echo "${DWI_folder}/FSL/scripts/fsl_newEddyCorrection.sh ${unr_img_abspath} \
																 ${invPE_b0} \
																 ${acqparamsTXT} \
																 ${bvec} \
																 ${bval} \
																 ${subj_eddy_out_folder} \
																 ${topup_flag} \
																 ${slm_option} \
																 ${line_index} \
																 ${eddy_cmd}" >> ${raijin_preprocessing_cmd}
		# mrconvert nii.gz to mif
		rotated_bvec=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.eddy_rotated_bvecs
		eddyCorr_dwi=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.nii.gz
		orig_bval=${bval}
		echo "mrconvert -force \
						-fslgrad ${rotated_bvec} ${orig_bval} \
						${eddyCorr_dwi} \
						${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif" >> ${raijin_preprocessing_cmd}

		# ++++++++++++++++++++++++++++++ #
		# Step 4 : Bias field correction #
		# ++++++++++++++++++++++++++++++ #
		preproc_mif=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif
		preproc_mif_filename=${unr_mif_filename}_preproc
		echo "dwibiascorrect -force \
							 -ants \
							 ${preproc_mif} \
							 ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif \
							 -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_bias.mif " >> ${raijin_preprocessing_cmd}

		# ++++++++++++++++++++++++++ #
		# Step 5 : Generate DWI mask #
		# ++++++++++++++++++++++++++ #
		unbiased_mif=${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif
		unbiased_mif_filename=${preproc_mif_filename}_unbiased
		echo "dwi2mask -force \
					   ${unbiased_mif} \
					   ${BIDS_folder}/derivatives/mrtrix/dwi_mask/${basedir}/${unbiased_mif_filename}_mask.mif" >> ${raijin_preprocessing_cmd}


		# execute
		case ${subq_flag} in
			subq)
				qsub -N ${subjID}_mrtrix_preprocessing \
					 ${raijin_preprocessing_cmd}
				;;
			noSubq)
				# not qsub
				;;
		esac
	done
}




Raijin_main(){

	BIDS_folder=$1
	subq_flag=$2
	skip_mif_organising=$3

	if [ ! -z ${skip_mif_organising+x} ] && [ "${skip_mif_organising}" = "yesSkipOrg" ]; then
		
		echo "skip mif organising."

		if [ -d "${BIDS_folder}/derivatives/mrtrix/orig_mif/part_xaa" ]; then
			split=1
		else
			split=0
		fi

		cd ${BIDS_folder}/derivatives/mrtrix

	else
		# =========================================== #
		# Remove previously generated folders/results #
		# =========================================== #
		# if [ -d "${BIDS_folder}/derivatives/mrtrix" ]; then
		# 	rm -fr ${BIDS_folder}/derivatives/mrtrix
		# fi
		mkdir -p ${BIDS_folder}/derivatives/mrtrix/orig_mif

		# ========================= #
		# generate and organise mif #
		# ========================= #
		cd ${BIDS_folder}
		for subject in `ls -d sub-*`
		do
			if [ -d "${subject}/dwi" ]; then
				cd ${subject}/dwi

				for dwi in `ls ${subject}*_dwi.nii*`
				do
					dwi_run_name=$(echo ${dwi} | awk -F '.' '{print $1}')

					mrconvert ${dwi} \
							  -fslgrad ${dwi_run_name}.bvec ${dwi_run_name}.bval \
							  -json_import ${dwi_run_name}.json \
							  ${BIDS_folder}/derivatives/mrtrix/orig_mif/${basedir}/${dwi_run_name}.mif \
							  -force
				done

				cd ${BIDS_folder}

			else
				echo "WARNING : No dwi folder for ${subject}."
			fi
		done

		# ================================================================= #
		# split into parts (each with 200 subjects) if total subjects > 200 #
		# because Raijin GPU nodes only allow for 200 GPU jobs              #
		# ================================================================= #
		cd ${BIDS_folder}/derivatives/mrtrix
		ls orig_mif/*.mif > orig_mif/orig_mif.list

		N_orig_mif=$(wc -l orig_mif/orig_mif.list | awk '{print $1}')

		if [ "${N_orig_mif}" -gt "200" ]; then

			cd orig_mif
			echo "There are ${N_orig_mif} subjects - spliting into parts (200 each) for Raijin GPU computing."
			split -l 200 orig_mif.list

			for part in `ls x*`
			do
				mkdir -p part_${part}
				while read mif
				do
					subjID=`echo $(basename ${mif}) | awk -F '_' '{print $1}'`
					mv ${subjID}*.mif part_${part}
				done < ${part}
			done

			cd ${BIDS_folder}/derivatives/mrtrix

			split=1

		else
			split=0
		fi
	fi


	# ====================== #
	# Preprocess all DWI mif #
	# ====================== #
	case ${split} in

		0)
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/denoise
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring/nii
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/biascorrect
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/dwi_mask
			mkdir -p ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/preprocessing/oe

			project=ba64
			queue=gpu
			ngpus=2
			ncpus=6
			mem=16GB

			dist_cmd ${BIDS_folder} ${project} ${queue} ${ngpus} ${ncpus} ${mem} ${subq_flag} noSplit
			;;

		1)
			N_iter=1
			for partdir in `ls -d orig_mif/part_x*`
			do
				basedir="$(basename ${partdir})"

				mkdir -p ${BIDS_folder}/derivatives/mrtrix/denoise/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/unring/${basedir}/nii/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/dwi_mask/${basedir}
				mkdir -p ${BIDS_folder}/derivatives/mrtrix/raijin_cmds/preprocessing/oe

				# echo ${N_iter}

				if [ "${N_iter}" -eq "1" ]; then
					project=ba64
					queue=gpu
					ngpus=2
					ncpus=6
					mem=16GB
				elif [ "${N_iter}" -eq "2" ]; then
					project=ey6
					queue=gpu
					ngpus=2
					ncpus=6
					mem=16GB
				elif [ "${N_iter}" -eq "3" ]; then
					project=ba64
					queue=gpupascal
					ngpus=1
					ncpus=6
					mem=16GB
				elif [ "${N_iter}" -eq "4" ]; then
					project=ey6
					queue=gpupascal
					ngpus=1
					ncpus=6
					mem=16GB
				fi	

				dist_cmd ${BIDS_folder} ${project} ${queue} ${ngpus} ${ncpus} ${mem} ${subq_flag} yesSplit ${basedir}

				N_iter=$((${N_iter} + 1))

				[ "${N_iter}" -eq "5" ] && break
			done
			;;
	esac

	


}

Raijin_main $1 $2 $3