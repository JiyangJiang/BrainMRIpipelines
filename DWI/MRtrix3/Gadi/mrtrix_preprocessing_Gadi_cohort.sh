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

study_dir=$1
mif_dir=$2


for mif in `ls ${mif_dir}/*.mif`
do
	subjID=$(basename ${mif} | awk -F '.' '{print $1}')

	# individual folders
	mkdir -p ${study_dir}/mrtrix/${subjID}/cmd/oe
	mkdir -p ${study_dir}/mrtrix/${subjID}/fslpreproc

	out_dir=${study_dir}/mrtrix/${subjID}

	preproc_cmd="${study_dir}/mrtrix/${subjID}/cmd/preprocess.cmd"

cat << EOT > ${preproc_cmd}
#PBS -P ey6
#PBS -q gpuvolta
#PBS -l walltime=01:00:00
#PBS -l ngpus=1
#PBS -l ncpus=12
#PBS -l mem=48GB
#PBS -l jobfs=2GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -e ${study_dir}/mrtrix/${subjID}/cmd/oe/preproc.err
#PBS -o ${study_dir}/mrtrix/${subjID}/cmd/oe/preproc.out

module load cuda/10.1

dwidenoise -force -nthreads 12 -noise ${out_dir}/noise.mif \
			${mif} ${out_dir}/dwidenoise.mif

mrdegibbs -force -axes 0,1 -nthreads 12 \
			${out_dir}/dwidenoise.mif ${out_dir}/mrdegibbs.mif

# fsl eddy
# --------
cp ${out_dir}/mrdegibbs.mif ${out_dir}/fslpreproc/.
cd ${out_dir}/fslpreproc
mrconvert -force -export_grad_fsl bvec bval \
			mrdegibbs.mif mrdegibbs.nii.gz

export PATH=$(dirname $(which $0)):$PATH

fsl_eddy.sh ${out_dir}/fslpreproc/mrdegibbs.nii.gz \
			no_invPE \
			easy_acq_updown \
			${out_dir}/fslpreproc/bvec \
			${out_dir}/fslpreproc/bval \
			${out_dir}/fslpreproc \
			noTopup \
			linear \
			2 \
			eddy_cuda10.1

EOT
## load python 2.7 to avoid error of TypeError: decode() takes no keyword arguments
#module load python/2.7.11

	# mrconvert nii.gz to mif
	rotated_bvec=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.eddy_rotated_bvecs
	eddyCorr_dwi=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${subjID}_eddy/eddy/eddy_corrected.nii.gz
	orig_bval=${bval}
	echo "mrconvert -force \
					-fslgrad ${rotated_bvec} ${orig_bval} \
					${eddyCorr_dwi} \
					${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif" >> ${preproc_cmd}

	# ++++++++++++++++++++++++++++++ #
	# Step 4 : Bias field correction #
	# ++++++++++++++++++++++++++++++ #
	preproc_mif=${BIDS_folder}/derivatives/mrtrix/preproc/${basedir}/${unr_mif_filename}_preproc.mif
	preproc_mif_filename=${unr_mif_filename}_preproc
	echo "dwibiascorrect -force \
						 -ants \
						 ${preproc_mif} \
						 ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif \
						 -bias ${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_bias.mif " >> ${preproc_cmd}

	# ++++++++++++++++++++++++++ #
	# Step 5 : Generate DWI mask #
	# ++++++++++++++++++++++++++ #
	unbiased_mif=${BIDS_folder}/derivatives/mrtrix/biascorrect/${basedir}/${preproc_mif_filename}_unbiased.mif
	unbiased_mif_filename=${preproc_mif_filename}_unbiased
	echo "dwi2mask -force \
				   ${unbiased_mif} \
				   ${BIDS_folder}/derivatives/mrtrix/dwi_mask/${basedir}/${unbiased_mif_filename}_mask.mif" >> ${preproc_cmd}


	# execute
	case ${subq_flag} in
		subq)
			qsub -N ${subjID}_mrtrix_preprocessing \
				 ${preproc_cmd}
			;;
		noSubq)
			# not qsub
			;;
	esac
done


