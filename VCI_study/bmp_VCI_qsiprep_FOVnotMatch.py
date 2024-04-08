# This script aims to resolve the issue with unmatched
# FOV between dMRI blocks. This issue happened to
# vci010 and vci012 (as of 08/04/2024)
#
# The solution is based on:
# https://github.com/PennLINC/qsiprep/issues/106

import nibabel as nb
import os
# import numpy

AP1 = nb.load("sub-vci010_dir-AP_run-1_dwi.nii.gz")
AP2 = nb.load("sub-vci010_dir-AP_run-2_dwi.nii.gz")
PA1 = nb.load("sub-vci010_dir-PA_run-1_dwi.nii.gz")
PA2 = nb.load("sub-vci010_dir-PA_run-2_dwi.nii.gz")

# fixed_AP2 = nb.Nifti1Image(AP2.get_data(), AP1.affine, header=AP1.header)
# fixed_PA1 = nb.Nifti1Image(PA1.get_data(), AP1.affine, header=AP1.header)
# fixed_PA2 = nb.Nifti1Image(PA2.get_data(), AP1.affine, header=AP1.header)

fixed_AP2 = nb.Nifti1Image(AP2.get_fdata(), AP1.affine, header=AP1.header)
fixed_PA1 = nb.Nifti1Image(PA1.get_fdata(), AP1.affine, header=AP1.header)
fixed_PA2 = nb.Nifti1Image(PA2.get_fdata(), AP1.affine, header=AP1.header)

fixed_AP2.to_filename("sub-vci010_dir-AP_run-2_acq-fixedhdr_dwi.nii.gz")
fixed_PA1.to_filename("sub-vci010_dir-PA_run-1_acq-fixedhdr_dwi.nii.gz")
fixed_PA2.to_filename("sub-vci010_dir-PA_run-2_acq-fixedhdr_dwi.nii.gz")

os.rename ("sub-vci010_dir-AP_run-2_dwi.bval","sub-vci010_dir-AP_run-2_acq-fixedhdr_dwi.bval")
os.rename ("sub-vci010_dir-PA_run-1_dwi.bval","sub-vci010_dir-PA_run-1_acq-fixedhdr_dwi.bval")
os.rename ("sub-vci010_dir-PA_run-2_dwi.bval","sub-vci010_dir-PA_run-2_acq-fixedhdr_dwi.bval")

os.rename ("sub-vci010_dir-AP_run-2_dwi.bvec","sub-vci010_dir-AP_run-2_acq-fixedhdr_dwi.bvec")
os.rename ("sub-vci010_dir-PA_run-1_dwi.bvec","sub-vci010_dir-PA_run-1_acq-fixedhdr_dwi.bvec")
os.rename ("sub-vci010_dir-PA_run-2_dwi.bvec","sub-vci010_dir-PA_run-2_acq-fixedhdr_dwi.bvec")

os.rename ("sub-vci010_dir-AP_run-2_dwi.json","sub-vci010_dir-AP_run-2_acq-fixedhdr_dwi.json")
os.rename ("sub-vci010_dir-PA_run-1_dwi.json","sub-vci010_dir-PA_run-1_acq-fixedhdr_dwi.json")
os.rename ("sub-vci010_dir-PA_run-2_dwi.json","sub-vci010_dir-PA_run-2_acq-fixedhdr_dwi.json")

# NOTE that some cleaning is needed, e.g. removing sub-vci010_dir-AP_run-2_dwi.nii, etc.