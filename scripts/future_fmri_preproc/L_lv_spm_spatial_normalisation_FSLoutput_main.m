% DESCRIPTION
% ---------------------------------------------------------------------------------
% This script aims to piggyback my FSL processing outputs, warping fMRI to
% group-specific DARTEL template (grp1 and grp2 separately). Meta-ICA and dual
% regression can be done in group-specific DARTEL space separately. The individual
% spatial maps can then be affine-registered to MNI space for statistical
% tests (e.g. FSL's randomise).
%
%
% USAGE
% ---------------------------------------------------------------------------------
%
% voxsiz = e.g. [4 4 4]
%
% step = 'beforeGrpICA' or 'afterGrpICA'

function L_lv_spm_spatial_normalisation_FSLoutput_main (cohortFolder, ...
													    N_vol_preproc_epi, ...
														N_grps, ...
														voxsiz, ...
														CNSpath, ...
														SPMpath, ...
														step, ...
														N_cpucores)

[currdir, ~, ~] = fileparts (mfilename ('fullpath'));

addpath (currdir, [CNSpath '/Scripts'], SPMpath);


% 2019 April 30 : keep smwc1 images in 1.5 isotropic voxel size
% -------------------------------------------------------------
voxsiz = [NaN NaN NaN];


switch step

case 'beforeGrpICA'

	% register EPI to ANAT
	L_lv_spm_regEPI2ANAT_FSLoutput (cohortFolder, N_vol_preproc_epi, CNSpath, SPMpath, N_cpucores);

	% anat segmentations
	L_lv_spm_anatSegmentation (cohortFolder, N_grps, CNSpath, SPMpath, N_cpucores);

	% run DARTEL (creating group-specific template)
	L_lv_spm_runDARTELc (cohortFolder, N_grps, SPMpath);

	% anat --> sample-specific DARTEL (epi and c1)
	L_lv_spm_warpANAT2DARTEL_FSLoutput (cohortFolder, N_grps, CNSpath, SPMpath, N_cpucores);

	% sample-specific DARTEL --> MNI (c1 only)
	L_lv_spm_warpDARTEL2MNI_gmSeg (cohortFolder, N_grps, voxsiz, SPMpath, N_cpucores);

	% generate sample-specific anat brain and mask
	L_lv_spm_genDARTELbrainAndMask (cohortFolder, N_grps, CNSpath, SPMpath);

case 'afterGrpICA'

	% registering individual spatial map after meta-ICA (group ICA) and dual regression
	% to MNI space
	% L_lv_spm_warpDARTEL2MNI_indSptMap (cohortFolder,);

end

