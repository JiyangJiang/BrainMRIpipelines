#!/bin/bash

# - This script shows hwo a raw T1w image can be prepared in such a way that a structural connectivity
#   matrix can be built for the HCP MMP 1.0 atlas.
#
# - This script was modified from the BATMAN MRtrix tutorial appendix
#
# - This script requires FreeSurfer to be installed
#
# - $SUBJECTS_DIR, usually called fs_subjects, should be the folder all anatomical analyses take place
#   , and contains fsaverage folder (where all info on the FreeSurfer standard brain is saved).
#
# - The fsaverage foler should contain subfolders like label, mri, surf, etc. The label subdirectory
#   must contain two annotation files of the HCP MMP 1.0 atlas (one left hemisphere, one right hemisphere).
#   This will be done in the script. The atlas can be obtained from 
#   https://figshare.com/articles/HCP-MMP1_0_projected_on_fsaverage/3498446.

subject_name=sub-100247
subjects_dir=/Users/jiyang/Desktop/MRtrix3_tutorial_BATMAN/HCPMMP1_to_T1
export SUBJECTS_DIR=${subjects_dir}

# https://afni.nimh.nih.gov/afni/community/board/read.php?1,154067,154155#msg-154155
# the source language needs to be in each custom script in order to establish library location accurately
source ~/.bash_profile



# # --== 1 ==-- Convert raw T1.mif to nifti-format, if T1 is prepared in MRtrix way
# mrconvert T1_raw.mif T1_raw.nii.gz

# # --== 2 ==-- Since the HCPMMP1-atlas is a FreeSurfer-based atlas, you have to preprocess the T1 image in FreeSurfer.
# # This will take several hours.
# recon-all -s ${subject_name} -i T1_raw.nii.gz -all

# --== 3 ==-- Map the annotation files of HCP MMP 1.0 atlas from fsaverage to your subject
cp $(dirname $(which $0))/lh.HCP-MMP1.annot \
   $(dirname $(which $0))/rh.HCP-MMP1.annot \
   ${subjects_dir}/fsaverage/label/.

mri_surf2surf --srcsubject fsaverage \
			  --trgsubject ${subject_name} \
			  --hemi lh \
			  --sval-annot ${subjects_dir}/fsaverage/label/lh.HCP-MMP1.annot \
			  --tval ${subjects_dir}/${subject_name}/label/lh.hcpmmp1.annot

mri_surf2surf --srcsubject fsaverage \
			  --trgsubject ${subject_name} \
			  --hemi rh \
			  --sval-annot ${subjects_dir}/fsaverage/label/rh.HCP-MMP1.annot \
			  --tval ${subjects_dir}/${subject_name}/label/rh.hcpmmp1.annot

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
			   --s ${subject_name} \
			   --annot hcpmmp1 \
			   --o hcpmmp1.mgz

mrconvert -datatype uint32 \
		  hcpmmp1.mgz \
		  hcpmmp1.mif

# --== 5 ==-- Replace the random integers of the hcpmmp1.mif file with integers that start from 1 and
#             increase by 1
labelconvert hcpmmp1.mif \
			 $(dirname $(which $0))/hcpmmp1_original.txt \
			 $(dirname $(which $0))/hcpmmp1_ordered.txt \
			 hcpmmp1_parcels_nocoreg.mif

# --== 6 ==-- Register the ordered atlas-based volumetric parcellation to diffusion space
mrtransform hcpmmp1_parcels_nocoreg.mif \
			-linear diff2struct_mrtrix.txt \
			-inverse \
			-datatype uint32 \
			hcpmmp1_parcels_coreg.mif