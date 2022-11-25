#!/bin/bash

# DESCRIPTION
# --------------------------------------------------------------------------------------------------
# This script maps FreeSurfer .annot in fsaverage space to individual T1w (or dwi) space.
#
#
# DATA PREPARATION
# --------------------------------------------------------------------------------------------------
# Data need to be in BIDS format.
#
#
# PRE-ASSUMPTION
# --------------------------------------------------------------------------------------------------
# - FreeSurfer needs to be installed.
#
# - FreeSurfer recon-all needs to be run on all subjects.
#
# - If you want to transfer the atlas to DWI space, DWI->T1w tranformation matrix should be created,
#   and converted to MRtrix format by, for example, running 
#   * mrtrix_tractography_BIDS_Raijin_singleShell.sh *
#
#
# USAGE
# --------------------------------------------------------------------------------------------------
# $1 = path to BIDS project folder
#
# $2 = subject ID (sub-*)
#
# $3 = path to FreeSurfer annot file (either lh or rh, do not use ?h). For example :
#
#          /path/to/atlas/lh.myatlas.annot
#
#      special case : if using HCP-MMP1 atlas (lh.HCP-MMP1.annot and rh.HCP-MMP1.annot), 
#                     pass 'HCP-MMP1'. if using Desikan-Killiany atlas, pass ('Desikan')
#
# $4 = 'yesMap2dwi' or 'noMap2dwi'
#
#
# OUTPUT
# --------------------------------------------------------------------------------------------------
# ${BIDS_folder}/derivatives/atlas/${FSannot}_dwiSpace/${subjID}_${FSannot}_labelCorrected.mif
#
#                                            OR
#
# ${BIDS_folder}/derivatives/atlas/${FSannot}_T1wSpace/${subjID}_${FSannot}_labelCorrected.mif
#
#
#
# NOTES AND REFERENCES
# --------------------------------------------------------------------------------------------------
# This script was modified from the BATMAN MRtrix tutorial appendix.
#
#
# --------------------------------------------------------------------------------------------------
#
# Dr. Jiyang Jiang,  February 2019.
#
# --------------------------------------------------------------------------------------------------


FSatlas2dwiSpace(){

BIDS_folder=$1
subjID=$2
FSannot_path=$3
map2dwi_flag=$4

subjects_dir=${BIDS_folder}/derivatives/freesurfer/recon-all
export SUBJECTS_DIR=${subjects_dir}

# --== 3 ==-- Map the annotation files of HCP MMP 1.0 atlas from fsaverage to your subject
case ${FSannot_path} in

	HCP-MMP1)
		atlas_path=$(dirname $(which $0))
		FSannot="HCP-MMP1"
		;;
	Desikan)
		atlas_path="${subjects_dir}/fsaverage/label"
		FSannot="Desikan"
		;;
	*)
		atlas_path=$(dirname ${FSannot_path})
		FSannot=$(basename ${FSannot_path} | awk -F '.' '{print $2}')
		;;
esac


# ------------- #
# output folder #
# ------------- #
case ${map2dwi_flag} in

	yesMap2dwi)

		if [ ! -d "${BIDS_folder}/derivatives/atlas/${FSannot}_dwiSpace" ]; then
			mkdir -p ${BIDS_folder}/derivatives/atlas/${FSannot}_dwiSpace
		fi

		outputFolder=${BIDS_folder}/derivatives/atlas/${FSannot}_dwiSpace

		;;

	noMap2dwi)

		if [ ! -d "${BIDS_folder}/derivatives/atlas/${FSannot}_T1wSpace" ]; then
			mkdir -p ${BIDS_folder}/derivatives/atlas/${FSannot}_T1wSpace
		fi

		outputFolder=${BIDS_folder}/derivatives/atlas/${FSannot}_T1wSpace

		;;

esac

if [ ! -f "${subjects_dir}/fsaverage/label/lh.${FSannot}.annot" ]; then
	cp ${atlas_path}/?h.${FSannot}.annot ${subjects_dir}/fsaverage/label/.
fi

mri_surf2surf --srcsubject fsaverage \
			  --trgsubject ${subjID} \
			  --hemi lh \
			  --sval-annot ${subjects_dir}/fsaverage/label/lh.${FSannot}.annot \
			  --tval ${subjects_dir}/${subjID}/label/lh.${FSannot}.annot

mri_surf2surf --srcsubject fsaverage \
			  --trgsubject ${subjID} \
			  --hemi rh \
			  --sval-annot ${subjects_dir}/fsaverage/label/rh.${FSannot}.annot \
			  --tval ${subjects_dir}/${subjID}/label/rh.${FSannot}.annot

# We will now map those annotations to the volumetric image, additionally labeling subcortical structures.
# The resulting image with have the atlas-based segmentation, but with more or less random integers assigned.
# MRtrix requires that the integers start with 1 and increase by 1.
# For that, we need to provide two color-lookup tables - one with original integers and one with the ordered
# integers. These are available in $MRtrix3/share/MRtrix3/labelconvert in the latest release, and also in the 
# current BATMAN_tutorial folder.
# Finally, we need to coregister the parcellation image to diffusion space.

# --== 4 ==-- Map the HCP MMP 1.0 annotations onto the volumetric image and add FreeSurfer-specific
#             subcortical segmentation. Convert the resulting file to .mif format (unit32 - best for MRtrix)
mri_aparc2aseg --old-ribbon \
			   --s ${subjID} \
			   --annot ${FSannot} \
			   --o ${outputFolder}/${subjID}_${FSannot}.mgz

mrconvert -datatype uint32 \
		  ${outputFolder}/${subjID}_${FSannot}.mgz \
		  ${outputFolder}/${subjID}_${FSannot}.mif \
		  -force

# --== 5 ==-- Replace the random integers of the hcpmmp1.mif file with integers that start from 1 and
#             increase by 1
if [ "${FSannot_path}" = "HCP-MMP1" ]; then
	labelconvert ${outputFolder}/${subjID}_${FSannot}.mif \
				 /short/ba64/jyj561/Software/mrtrix3/share/mrtrix3/labelconvert/hcpmmp1_original.txt \
				 /short/ba64/jyj561/Software/mrtrix3/share/mrtrix3/labelconvert/hcpmmp1_ordered.txt \
				 ${outputFolder}/${subjID}_${FSannot}_t1space.mif \
				 -force
elif [ "${FSannot_path}" = "Desikan" ]; then
	# Ref : https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/labelconvert_tutorial.html
	labelconvert ${subjects_dir}/${subjID}/mri/aparc+aseg.mgz \
				 ${FREESURFER_HOME}/FreeSurferColorLUT.txt \
				 /short/ba64/jyj561/Software/mrtrix3/share/mrtrix3/labelconvert/fs_default.txt \
				 ${outputFolder}/${subjID}_${FSannot}_t1space.mif \
				 -force
else
	mv ${outputFolder}/${subjID}_${FSannot}.mif ${outputFolder}/${subjID}_${FSannot}_t1space.mif
fi

# --== 6 ==-- Register the ordered atlas-based volumetric parcellation to diffusion space
case ${map2dwi_flag} in

	yesMap2dwi)

		mrtransform ${outputFolder}/${subjID}_${FSannot}_t1space.mif \
					-linear ${BIDS_folder}/derivatives/mrtrix/DWI_to_T1w/${subjID}_diff2annat_mrtrix.txt \
					-inverse \
					-datatype uint32 \
					${outputFolder}/${subjID}_${FSannot}_dwiSpace.mif \
					-force

		;;

	noMap2dwi)

		# not mapping to dwi space

		;;

esac

}

FSatlas2dwiSpace $1 $2 $3 $4