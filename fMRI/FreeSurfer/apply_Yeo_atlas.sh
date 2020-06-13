#!/bin/bash

# Sept17, 2018 : Not working yet. bbregister needs to specify --mov,
#                and mri_label2vol needs --reg.





# export SUBJECTS_DIR=/data_int/jiyang/forHeidi/try
export SUBJECTS_DIR=/Users/jiyangjiang/Work/fMRI/FreeSurfer

# Example apply Yeo_7 to 8840

mri_surf2surf --srcsubject Yeo_JNeurophysiol11_FreeSurfer/fsaverage \
			  --trgsubject 8840 \
			  --hemi lh \
			  --sval-annot Yeo_JNeurophysiol11_FreeSurfer/fsaverage/label/lh.Yeo2011_7Networks_N1000.annot \
			  --tval 8840/label/lh.Yeo7.annot

mri_surf2surf --srcsubject Yeo_JNeurophysiol11_FreeSurfer/fsaverage \
			  --trgsubject 8840 \
			  --hemi rh \
			  --sval-annot Yeo_JNeurophysiol11_FreeSurfer/fsaverage/label/rh.Yeo2011_7Networks_N1000.annot \
			  --tval 8840/label/rh.Yeo7.annot


# annot to label
mri_annotation2label --subject 8840 \
					 --outdir 8840/label/test \
					 --hemi lh \
					 --annotation 8840/label/lh.Yeo7.annot

mri_annotation2label --subject 8840 \
					 --outdir 8840/label/test \
					 --hemi rh \
					 --annotation 8840/label/rh.Yeo7.annot


# ind to fsaverage register
bbregister --s 8840 \
		   --mov
		   --init-fsl \
		   --reg register.dat

# label to vol (NW1)
mri_label2vol --label 8840/label/test/lh.7Networks_1.label \
              --temp 8840/mri/rawavg.mgz \
              --subject 8840 \
              --hemi lh \
              --o 8840/Yeo_test/lh_7nw_1.nii.gz \
              --proj frac 0 1 0.01 \
              --reg 