#!/bin/bash


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
# +++ Note : This script uses FreeSurfer recon-all generated volume instead of any VBM results.
#

# cache, resample, and blur volume
export SUBJECTS_DIR=/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FreeSurfer_recon-all

for i in lh rh
do
	mris_preproc --fsgd g1v0.fsgd \
				 --target fsaverage \
				 --hemi ${i} \
				 --meas volume \
				 --out ${i}.g1v0.volume.00.mgh
done

for m in lh rh
do
	for k in 5 10 15
	do
		mri_surf2surf --hemi ${m} \
					  --s fsaverage \
					  --sval ${m}.g1v0.volume.00.mgh \
					  --fwhm ${k} \
					  --cortex \
					  --tval ${m}.g1v0.volume.${k}.mgh
	done
done


# ++++++++++++++++++++++++++++++++++
#              FLICA
# ++++++++++++++++++++++++++++++++++
#
# MATLAB code
#
addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/my_software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_FSLVBMsigma2Resample4mm_FSthicknessAreaFWHM10mm_d70_1000perm/';

Yfiles = {
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/?h.g1v0.thickness.10.mgh']
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/?h.g1v0.area.pial.10.mgh'],
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/GM_mod_merg_s2_4mm.nii.gz']
};

% Log-transform area; everything else uses defaults.
% Note that 4 arguments for each Yfiles input - log, subtractThis,
% divideByThis, single/double (refer to the MATLAB code)
transformsIn = {'','','',''; 'log','','',''; '','','',''};

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','VBM'};

opts = struct();
opts.num_components = 70;
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
des.Age = load('age.txt');
des.Sex = load('sex.txt');
des.Edu = load('edu.txt');
des.ICV = load('eTIV_from_recon-all_aseg.txt');
flica_posthoc_correlations(outdir, des)

% upsample for report
YfilesHR = Yfiles;
YfilesHR = regexprep(YfilesHR, '_s2_4mm', '_s4');  % only FSL-VBM result was downsampled. Note Smith 2019 upsample s2_4mm to s4
flica_upsample(outdir, YfilesHR, Y)


# SHELL
# generate reports (using high resolution output)
#
export PATH=/home/jiyang/my_software/flica_Jmod:$PATH
flica_report.sh /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_FSLVBMsigma2Resample4mm_FSthicknessAreaFWHM10mm_d70_1000perm/ _HR


# SHELL
# Calculation of the variance explained
# Jmod : calculation based on low resolution results, as high res is only for display
#

# surface2volume low res mgh
surfaces_to_volumes_all.sh fsaverage $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz

cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_FSLVBMsigma2Resample4mm_FSthicknessAreaFWHM10mm_d70_1000perm
fslmaths niftiOut_mi1.nii.gz -sqr tmp1.nii.gz  
fslstats -t tmp1.nii.gz -m > energy1.txt
fslmaths niftiOut_mi2.nii.gz -sqr tmp2.nii.gz  
fslstats -t tmp2.nii.gz -m > energy2.txt
fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz
fslstats -t tmp3.nii.gz -m > energy3.txt
paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_FSLVBMsigma2Resample4mm_FSthicknessAreaFWHM10mm_d70_1000perm
energy_tmp = load ('energy_tmp.txt');
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100;
fid_energy = fopen('energy.txt','w');
for i = 1:size(energy,1)
	fprintf(fid_energy,'%.5f\t%.5f\t%.5f\n',energy(i,1),energy(i,2),energy(i,3));
end

% save environment/variables in MATLAB
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA
save ('output_FSLVBMsigma2Resample4mm_FSthicknessAreaFWHM10mm_d70_1000perm');