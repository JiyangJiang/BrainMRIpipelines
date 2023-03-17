%-----------
% bmp_fmri_ini_Xbrain_SPMnbtrN
%-----------
%
% DESCRIPTION:
%   non-brain tissue removal in native space
%
% INPUT:
%   inputImg = path to the image of which non-brain tissue will be removed
%   cGM = path to c1*.nii
%   cWM = path to c2*.nii
%   cCSF = path to c3*.nii
%   outputImg = path to the output
%	varargin{1} = 'maskout'
%
% USAGE:
%   bmp_fmri_ini_Xbrain_SPMnbtrN (inputImg, cGM, cWM, cCSF, outputImg)
%
% NOTE:
%   need to run CNSP_segmentation to generate cGM, cWM and cCSF
%

function bmp_fmri_ini_Xbrain_SPMnbtrN (inputImg, cGM, cWM, cCSF, outputImg, varargin)

    % get scripts folder
    [scriptsFolder,currMfilename,ext] = fileparts(which([mfilename '.m']));
    
    % grant execute
    % system (['chmod +x ' scriptsFolder '/bmp_fmri_ini_Xbrain_SPMnbtrN_combSegsMaskSrcImg.sh']);
    
    % combine GM/WM/CSF, threshold 0.3, binarize, and mask input img

    if (nargin == 5)
    	system ([scriptsFolder '/bmp_fmri_ini_Xbrain_SPMnbtrN_combSegsMaskSrcImg.sh ' inputImg ' ' cGM ' ' cWM ' ' cCSF ' ' outputImg]);
    elseif (nargin == 6)
    	system ([scriptsFolder '/bmp_fmri_ini_Xbrain_SPMnbtrN_combSegsMaskSrcImg.sh ' inputImg ' ' cGM ' ' cWM ' ' cCSF ' ' outputImg ' ' varargin{1}]);
    end