#!/bin/bash


mrconvert dwi.nii.gz dwi_raw.mif -fslgrad bvec bval

dwidenoise dwi_raw.mif dwi_den.mif -noise noise.mif