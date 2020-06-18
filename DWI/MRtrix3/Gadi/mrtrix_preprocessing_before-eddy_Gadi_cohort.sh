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

study_dir=/g/data/ey6/Jiyang/MAS/mrtrix
mif_dir=/g/data/ey6/Jiyang/MAS/nifti/dwi-mif






for mif in ${mif_dir}/*.mif
do
	subjID=$(basename ${mif} | awk -F '.' '{print $1}')
	echo ${subjID} >> ${study_dir}/list

	# individual folders
	mkdir -p ${study_dir}/mrtrix/${subjID}/cmd/oe
	mkdir -p ${study_dir}/mrtrix/${subjID}/eddy

	out_dir=${study_dir}/mrtrix/${subjID}

	preproc_cmd="${study_dir}/mrtrix/${subjID}/cmd/preprocess.cmd"

cat << EOT > ${preproc_cmd}
#PBS -P ey6
#PBS -q normal
#PBS -l walltime=01:00:00
#PBS -l ncpus=2
#PBS -l mem=8GB
#PBS -l jobfs=2GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -e ${study_dir}/mrtrix/${subjID}/cmd/oe/preproc.err
#PBS -o ${study_dir}/mrtrix/${subjID}/cmd/oe/preproc.out

module load cuda/10.1

cd ${out_dir}

dwidenoise -force -nthreads 12 -noise noise.mif \
			${mif} dwidenoise.mif

mrdegibbs -force -axes 0,1 -nthreads 12 \
			dwidenoise.mif mrdegibbs.mif

# fsl eddy
# --------
cp mrdegibbs.mif eddy/.
cd eddy

mrconvert -force -export_grad_fsl bvec bval \
			mrdegibbs.mif mrdegibbs.nii.gz

dwi2mask -force \
			mrdegibbs.mif mask.mif

mrconvert -force \
			mask.mif mask.nii.gz
EOT
## load python 2.7 to avoid error of TypeError: decode() takes no keyword arguments
#module load python/2.7.11


# submit job
qsub -N ${subjID}_mrtrix_preproc ${preproc_cmd}

done


