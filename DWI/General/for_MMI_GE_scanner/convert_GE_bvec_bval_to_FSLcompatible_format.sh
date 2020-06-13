#!/bin/bash


## !!! Read this before use !!! ##
##
## FROM JEROME'S EMAIL:
## I just remembered that since their console upgrade to software 
## version DV26 the dicom headers are written differently. 
## Specifically, your scans are acquired in ‘research mode’ 
## which reads the research mode tensor.dat (a GE gradient table) 
## and then pulses it. However, during the reconstruction 
## (from k-space to dicoms) the dicom fields are encoded with the 
## gradient directions from the clinical mode tensor.dat. So, the 
## data is acquired with the correct research mode tensor.dat 
## (multi-shell) but the dicoms are encoded with the clinical mode 
## tensor.dat (not mult-ishell).
#
#
# so the 147_Directions.bvecs and tensor.dat that Tom sended
# was clinical mode (?)
# call bvec_FINAL.txt, NOT 147_Directions.bvecs !!!


# ================== CHANGE THIS PART ======================= #
templateBVEC="/home/jiyang/Dropbox/Jiyang/CNSP/FUTURE/MRtrix3_code/bvec_FINAL.txt"
scannerBVAL="/data_int/jiyang/forHeidi/DWI/dwi_1.bval"
dwiNII="/data_int/jiyang/forHeidi/DWI/dwi_1.nii"
outputFolder="/data_int/jiyang/forHeidi/DWI/test"
outputName="dwi_1_new"
# =========================================================== #


if [ ! -d "${outputFolder}" ]; then
	mkdir ${outputFolder}
fi

# merge template BVEC with scanner-generated BVAL and NII
mrconvert -force \
		  ${dwiNII} \
		  -fslgrad ${templateBVEC} ${scannerBVAL} \
		  ${outputFolder}/${outputName}.mif

# export FSL-compatible bvec/bval
mrinfo -force \
       ${outputFolder}/${outputName}.mif \
       -export_grad_fsl ${outputFolder}/${outputName}.bvec ${outputFolder}/${outputName}.bval