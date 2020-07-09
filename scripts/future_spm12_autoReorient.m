% Modified from http://www.nemotos.net/?p=1779
%
% batch script for AC-PC reorientation
% ++++++++++++++++++++++++++++++++++++
% This script tries to set AC-PC with 2 steps.
%
% 1. Set origin to center (utilizing a script by F. Yamashita)
% 2. Coregistration of the image to icbm152.nii under spm/toolbox/DARTEL
% 
% K. Nemoto 22/May/2017
% ==================================================================
%
% Modified on July 8, 2020 by Dr. Jiyang Jiang
%
% This method can fix the orientation issue in SPM after forcing the
% modification of orientations using fslswapdim introduced in
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Orientation%20Explained.
%
%
% varargin{1} = vertical cell array with path to nii. spm_select will
%               be called if no arguments are input.

function future_spm12_autoReorient (varargin)

if nargin==1
    imglist = varargin{1};
elseif nargin==0
    %% Select images
    imglist = cellstr(spm_select(Inf,'image','Choose MRI you want to set AC-PC'));
end

%% Initialize batch
spm_jobman('initcfg');
matlabbatch = {};

%% Set the origin to the center of the image
% This part is written by Fumio Yamashita.
for i=1:size(imglist,1)
    file = deblank(imglist{i,1});
    st.vol = spm_vol(file);
    vs = st.vol.mat\eye(4);
    vs(1:3,4) = (st.vol.dim+1)/2;
    spm_get_space(st.vol.fname,inv(vs));
end

%% Prepare the SPM window
% interactive window (bottom-left) to show the progress, 
% and graphics window (right) to show the result of coregistration 

%spm('CreateMenuWin','on'); %Comment out if you want the top-left window.
% spm('CreateIntWin','on');
% spm_figure('Create','Graphics','Graphics','on');

%% Coregister images with icbm152.nii under spm12/toolbox/DARTEL
parfor i=1:size(imglist,1)
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {fullfile(spm('dir'),'toolbox','DARTEL','icbm152.nii,1')};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {deblank(imglist{i,1})};
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    %% Run batch
    %spm_jobman('interactive',matlabbatch);
    spm_jobman('run',matlabbatch);
end
