%% You will need FSL and FreeSurfer installed, as well as MATLAB and of course, FLICA (most recent version here: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLICA).
% Inputs to FLICA are outputs from FreeSurfer (?h.thick.fsaverage5.10.mgh and ?h.pial.area.fsaverage5.10.mgh) 
% and from FSL-VBM https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLVBM (downsampled from 2 mm to 4 mm isotropic: in our case, GM_mod_merg_s2_4mm.nii.gz)


%%% In MATLAB: FLICA

%% Output directory setting

outdir = ['/home/flica']
mkdir(outdir);

%% Inputs

Yfiles = {
['?h.thick.fsaverage5.10.mgh']
['?h.pial.area.fsaverage5.10.mgh'],
['GM_mod_merg_s2_4mm.nii.gz']
};
transformsIn = {'','','',''; 'log','','',''; '','','',''}; % Log-transform area; everything else uses defaults.

[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'Thickness','Area','VBM'};

%% Non-default option setting (to see a list of options: run flica_parseoptions, with no arguments.)

opts = struct();
opts.num_components = 70; % number of maximum components
opts.maxits = 1000;
opts.calcFits = 'all'; % Be more careful, check F increases every iteration.

%% Running FLICA

Morig = flica(Y, opts);
[M,weights] = flica_reorder(Morig); % Sort components sensibly
flica_save_everything(outdir, M, fileinfo);

%% Post-hoc analyses and plots

design = load('design.csv')

des.Subject_Order.values = 1:size(design,1);
des.Subject_Order.style = '-';

age = design(:,1);
des.Age = age;

female = logical(design(:,2));
des.Sex.values = double(female);
des.Sex.dithered = double(female) -0.2 + 0.4*rand(size(female));
des.Sex.style = '.'; 
des.Sex.groups = double(female)+1;
des.Sex.limits = [-.5,1.5];
des.Sex.xtick = [0 1];
des.Sex.xticklabel = {'Male','Female'};

des.ICV.values = design(:,3)/1e6;    

flica_posthoc_correlations(outdir, des)

%% OPTIONAL: Upsampling for report

YfilesHR = Yfiles;
YfilesHR = regexprep(YfilesHR, '.fsaverage5.10.', '.fsaverage.10.');
YfilesHR = regexprep(YfilesHR, '_s2_4mm', '_s4');
flica_upsample(outdir, YfilesHR, Y)

%% Writing the report

dos(sprintf('flica_report.sh "%s" _HR', outdir))


%%% In FSL & MATLAB: Calculation of the variance explained

%% In FSL

cd /home/flica/
fslmaths niftiOut_mi1_LR.nii.gz -sqr tmp1.nii.gz  
fslstats -t tmp1.nii.gz -m > energy1.txt
fslmaths niftiOut_mi2_LR.nii.gz -sqr tmp2.nii.gz  
fslstats -t tmp2.nii.gz -m > energy2.txt
fslmaths niftiOut_mi3.nii.gz -sqr tmp3.nii.gz
fslstats -t tmp3.nii.gz -m > energy3.txt
paste energy1.txt energy2.txt energy3.txt > energy_tmp.txt

%% In MATLAB

load energy_tmp.txt
energy = energy_tmp * diag(1./sum(energy_tmp)) * 100
