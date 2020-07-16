#!/bin/bash


# ++++++++++++++++++++++++++++++++++
#              FLICA
# ++++++++++++++++++++++++++++++++++
#
# MATLAB code
#
addpath([getenv('FSLDIR') '/etc/matlab/']);
addpath ('/home/jiyang/Software/flica_Jmod');

% note / in the end of outdir path
outdir = '/data_int/jiyang/FLICA/no_dementia/output_FreeSurfer_VolThickArea_smooth15/';

Yfiles = {
['/data_int/jiyang/FLICA/no_dementia/?h.g1v0.thickness.15.mgh']
['/data_int/jiyang/FLICA/no_dementia/?h.g1v0.area.pial.15.mgh'],
['/data_int/jiyang/FLICA/no_dementia/?h.g1v0.volume.15.mgh']
};

% log-transform area and vol, to arrive at similar range as thickness ??
transformsIn = {'','','',''; 'log','','',''; 'log','','',''};

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','Vol'};

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
des.Age = load('/data_int/jiyang/FLICA/no_dementia/age_N310.txt');
des.Sex = load('/data_int/jiyang/FLICA/no_dementia/sex_N310.txt');
des.Edu = load('/data_int/jiyang/FLICA/no_dementia/edu_N310.txt');
des.ICV = load('/data_int/jiyang/FLICA/no_dementia/eTIVfromFreeSurfer_N310.txt');
flica_posthoc_correlations(outdir, des)


# SHELL
# generate reports (using high resolution output)
#
cd /data_int/jiyang/FLICA/no_dementia/output_FreeSurfer_VolThickArea_smooth15
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

cd /data_int/jiyang/FLICA/no_dementia/output_FreeSurfer_VolThickArea_smooth15
fslmaths niftiOut_mi1.nii.gz -sqr tmp1.nii.gz;fslstats -t tmp1.nii.gz -m > energy1.txt;fslmaths niftiOut_mi2.nii.gz -sqr tmp2.nii.gz;fslstats -t tmp2.nii.gz -m > energy2.txt;fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz;fslstats -t tmp3.nii.gz -m > energy3.txt;paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB
cd /data_int/jiyang/FLICA/no_dementia/output_FreeSurfer_VolThickArea_smooth15
energy_tmp = load ('energy_tmp.txt');
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100;
fid_energy = fopen('energy.txt','w');
for i = 1:size(energy,1)
	fprintf(fid_energy,'%.5f\t%.5f\t%.5f\n',energy(i,1),energy(i,2),energy(i,3));
end

% save environment/variables in MATLAB
cd /data_int/jiyang/FLICA/no_dementia
save ('output_FreeSurfer_VolThickArea_smooth15','-v7.3');