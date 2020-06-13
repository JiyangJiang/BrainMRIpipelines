#!/bin/bash

# +++++++++++++++++++++++++++++++++++++++++++++
#                     VBM
# +++++++++++++++++++++++++++++++++++++++++++++
# 1. following Smith 2019, use FreeSurfer intensity non-uniformity corrected T1 + FreeSurfer brainmask
#
# 		non-uniformity-corrected T1  @  subject_folder/mri/nu.mgz
#		brain mask                   @  subject_folder/mri/brainmask.mgz
#
#		convert to nii : mri_convert nu.mgz nu.nii.gz
#						 mri_convert brainmask.mgz brainmask.nii.gz
#
#		mask : fslmaths nu -mas brainmask brain
#
#		FSL-VBM with nu.nii.gz (as original T1), and brain as (struc/*_struc_brain.nii.gz)
#
#		April 25, 2020
#		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#		only apply nu_correct to T1_brain without running recon-all, as not sure why nu.mgz+brainmask.mgz
#		affects the following VBM results very much - much worse than applying c123 mask + direct FSLVBM
#
#		use cohort mask to correct the inaccurate brainmask for 1420A, 4062A, and 5788A.
#
#		for i in `ls *_brainmask_ero_ero.nii.gz`;do fslreorient2std $i $i;done
#		for i in `ls sub-*_anat_brainmask_ero_ero.nii.gz`;do a=`fslsize $i | grep -w dim2 | awk '{print $2}'`;[ $a != "190" ]&& rm -f $i;done
#		fslmerge -t all_brainmask_4D $(ls -1 *_ero_ero.nii.gz | tr '\n' ' ')
#		fslmaths T1_brain -mas mask
#
#		mri_convert T1_brain.nii.gz T1_brain.mnc
#		nu_correct T1_brain.mnc T1_brain_nucorr.mnc
#		mri_convert T1_brain_nucorr.mnc T1_brain_nucorr.nii.gz


# 2. GM_mod_merg_s2.nii.gz from FSL-VBM output was used (i.e. sigma=2; FWHM~4.6mm) to comply
#    with Smith 2019. Douaud 2014 (PNAS) used sigma=4; FHWM~9.4mm.
#    +++ 2020/04/24 - s4 was used due to results not smooth/too much noise

# 3. VBM was also done with CAT12 (SCS+MW24_VBM_N354.nii.gz) with customised sample-specific 
#    template (FWHM = 5mm)

# 4. modulated GM maps (VBM output) are resampled to 4mm to comply with Smith 2019 et al.
#    flirt -in GM_mod_merg_s2_N310.nii.gz -ref GM_mod_merg_s2_N310.nii.gz -init eye.mat -applyisoxfm 4 -out GM_mod_merg_s2_N310_4mm
#    +++ this step not done because input to flirt intended to be 3D. use the highres image for following steps.

# 5. GM_mod_merge_s2 was masked by GM_mask from FSL-VBM (as it seems the GM mask was not applied in FSL's script?)


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                          FreeSurfer thickness/area maps
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 1. FreeSurfer recon-all results cache, resample/normalise to fsaverage, and smoothing
#
# Ref : https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/GroupAnalysis (Search "Uncached Data")
#
# Note : according to the online code for Smith et al 2019, it seems ?h.area.pial instead of ?h.area
#        should be used for area.
#
#        Smith 2019 used fsaverage5, instead of the higher resolution fsaverage, as standard space.
#        However, my FreeSurfer recon-all processing was against fsaverage. So I had to use fsaverage
#        as target. Should not make much difference. Perhaps should increase FWHM?
#
export SUBJECTS_DIR=/data_int/jiyang/FLICA/no_dementia/all_FreeSurfer_output_N310

for i in lh rh
do
	for j in thickness area.pial
	do
		mris_preproc --fsgd g1v0.fsgd \
					 --target fsaverage \
					 --hemi ${i} \
					 --meas ${j} \
					 --out ${i}.g1v0.${j}.00.mgh
	done
done

for m in lh rh
do
	for n in thickness area.pial
	do
		for k in 5 10 15
		do
			mri_surf2surf --hemi ${m} \
						  --s fsaverage \
						  --sval ${m}.g1v0.${n}.00.mgh \
						  --fwhm ${k} \
						  --cortex \
						  --tval ${m}.g1v0.${n}.${k}.mgh
		done
	done
done


# ++++++++++++++++++++++++++++++++++
#              FLICA
# ++++++++++++++++++++++++++++++++++
#
# MATLAB code
#
addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data_int/jiyang/FLICA/no_dementia/output_complyWithSmith2019_onGRID_VBMs2/';

Yfiles = {
['/data_int/jiyang/FLICA/no_dementia/?h.g1v0.thickness.10.mgh']
['/data_int/jiyang/FLICA/no_dementia/?h.g1v0.area.pial.10.mgh'],
['/data_int/jiyang/FLICA/no_dementia/GM_mod_merg_s2_N310.nii.gz']
};

% Log-transform area; everything else uses defaults.
% Note that 4 arguments for each Yfiles input - log, subtractThis,
% divideByThis, single/double (refer to the MATLAB code)
transformsIn = {'','','',''; 'log','','',''; '','','',''};

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','VBM'};

opts = struct();
opts.num_components = 100;
opts.maxits = 1000;
opts.calcFits = 'all'; % Be more careful, check F increases every iteration.

% Run FLICA
Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig); % Sort components sensibly
flica_save_everything(outdir, M, fileinfo);

% post hoc correlation
% Jmod - this part is different from Smith 2019 code.
%        this part is according to online FLICA instruction.
clear des
des.Subject_Index = (1:size(Y{1},2))';
des.Age = load('/data_int/jiyang/FLICA/no_dementia/age_N310.txt');
des.Sex = load('/data_int/jiyang/FLICA/no_dementia/sex_N310.txt');
des.Edu = load('/data_int/jiyang/FLICA/no_dementia/edu_N310.txt');
des.ICV = load('/data_int/jiyang/FLICA/no_dementia/eTIVfromFreeSurfer_N310.txt');
flica_posthoc_correlations(outdir, des)


# SHELL
# generate reports (using high resolution output)
#
cd /data_int/jiyang/FLICA/no_dementia/output_complyWithSmith2019_onGRID_VBMs2
export PATH=/home/jiyang/Software/flica_Jmod:$PATH
render_surfaces.sh  # this step was run on cluster instead of GRID (upload only *.mgh) due to unresolved "limited resources" issue
ln -s /data_pub/Software/FreeSurfer/FS-6.0.0/subjects/fsaverage ./fsaverage
surfaces_to_volumes_all.sh $(pwd)/fsaverage $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
render_lightboxes_all.sh
flica_html_report.sh


# SHELL
# Calculation of the variance explained
# Jmod : calculation based on low resolution results, as high res is only for display
#

cd /data_int/jiyang/FLICA/no_dementia/output_complyWithSmith2019_onGRID_VBMs2
fslmaths niftiOut_mi1.nii.gz -sqr tmp1.nii.gz  
fslstats -t tmp1.nii.gz -m > energy1.txt
fslmaths niftiOut_mi2.nii.gz -sqr tmp2.nii.gz  
fslstats -t tmp2.nii.gz -m > energy2.txt
fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz
fslstats -t tmp3.nii.gz -m > energy3.txt
paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB
cd /data_int/jiyang/FLICA/no_dementia/output_complyWithSmith2019_onGRID_VBMs2
energy_tmp = load ('energy_tmp.txt');
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100;
fid_energy = fopen('energy.txt','w');
for i = 1:size(energy,1)
	fprintf(fid_energy,'%.5f\t%.5f\t%.5f\n',energy(i,1),energy(i,2),energy(i,3));
end

% save environment/variables in MATLAB
cd /data_int/jiyang/FLICA/no_dementia
save ('output_complyWithSmith2019_onGRID_VBMs2','-v7.3');