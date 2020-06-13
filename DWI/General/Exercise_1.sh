#!/bin/bash

# set path
/usr/share/mrtrix3/set_path


# ========= #
# mrconvert #
# ========= #

# combine test_1.nii and test_2.nii together into a 4D image
mrconvert test_[].nii combined.mif
# combine a subset - mrconvert test_[10:20].nii combined_10to20.mif

# view
mrview combined.mif
# up/down to change slices, left/right to change volumes

# convert from DICOM to NIfTI
mrconvert T1_DICOM -datatype float32 T1.nii
# once the first argument is a folder mrconvert treat it as DICOM folder

# Stride
# ------
# 1. RAS = neurological, LAS = radiological.
# 2. RAS corresponds to storing data from left-posterior-inferior, proceeding to right, then anterior, then superior,
# 	 until the whole image is stored. In MRtrix3, it is indicated as 1,2,3. LAS is -1,2,3. PIR (sagittal) is 3,-1,-2.
#    An easy way to interpret this is start with 1/-1 - this corresponds to the direction the first row of data is 
#    stored along the corresponding axis, and then interpret 2/-2 and then 3/-3
# 3. 4D Stride interpretation: 2,3,4,1 corresponds to volume-contiguous order, meaning the same given voxel on each of
#    the volumes are stored together, hense 1 along the fourth dimension.


