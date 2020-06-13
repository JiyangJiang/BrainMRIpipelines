#!/bin/bash

# run without MATLAB graphics
tmux new -s flica
matlab -nosplash -nodesktop


# ++++++++++++++++++++++++++++++++++
#              FLICA
# ++++++++++++++++++++++++++++++++++
#
# MATLAB code
#
addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/my_software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_CAT12VBMfwhm5mmNative1p5mm_FSthicknessAreaFWHM10mm_d70_5000perm/';

Yfiles = {
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/?h.g1v0.thickness.10.mgh']
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/?h.g1v0.area.pial.10.mgh'],
['/data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/SCS+MW24_VBM_N354.nii.gz']
};

% Log-transform area; everything else uses defaults.
% Note that 4 arguments for each Yfiles input - log, subtractThis,
% divideByThis, single/double (refer to the MATLAB code)
transformsIn = {'','','',''; 'log','','',''; '','','',''};

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','VBM'};

opts = struct();
opts.num_components = 70;
opts.maxits = 5000;
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
des.ICV = load('TIV_from_CAT12.txt');
flica_posthoc_correlations(outdir, des)


# SHELL
# generate reports (using high resolution output)
#
export PATH=/home/jiyang/my_software/flica_Jmod:$PATH
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_CAT12VBMfwhm5mmNative1p5mm_FSthicknessAreaFWHM10mm_d70_5000perm
render_surfaces.sh
surfaces_to_volumes_all.sh fsaverage $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
mv niftiOut_mi3.nii.gz niftiOut_mi3_DARTEL1p5mm.nii.gz
# affine from DARTEL to MNI for lightbox
flirt -in niftiOut_mi3_DARTEL1p5mm.nii.gz -ref ../DARTEL2MNI/MNI152_T1_2mm_brain.nii.gz -applyxfm -init ../DARTEL2MNI/dartel2mni.mat -out niftiOut_mi3
render_lightboxes_all.sh
flica_html_report.sh


# SHELL
# Calculation of the variance explained
#
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_CAT12VBMfwhm5mmNative1p5mm_FSthicknessAreaFWHM10mm_d70_5000perm
fslmaths niftiOut_mi1.nii.gz -sqr tmp1.nii.gz  
fslstats -t tmp1.nii.gz -m > energy1.txt
fslmaths niftiOut_mi2.nii.gz -sqr tmp2.nii.gz  
fslstats -t tmp2.nii.gz -m > energy2.txt
fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz
fslstats -t tmp3.nii.gz -m > energy3.txt
paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA/output_CAT12VBMfwhm5mmNative1p5mm_FSthicknessAreaFWHM10mm_d70_5000perm
energy_tmp = load ('energy_tmp.txt');
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100;
fid_energy = fopen('energy.txt','w');
for i = 1:size(energy,1)
	fprintf(fid_energy,'%.5f\t%.5f\t%.5f\n',energy(i,1),energy(i,2),energy(i,3));
end

% save environment/variables in MATLAB
cd /data2/jiyang/Work/SCS+MW24_cross-sectional_FIXdenoising/FLICA
save ('output_CAT12VBMfwhm5mmNative1p5mm_FSthicknessAreaFWHM10mm_d70_5000perm', '-v7.3');