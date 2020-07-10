% ----------------------------------------------------------------
% This script is modified from the example code of the Example box 
% in "Introduction to Resting State fMRI Functional Connectivity"
% ----------------------------------------------------------------
%
%
% seed_nii = path to the seed nifti image.
%
% func_data = functional MRI data.
%
% example_func = used for copying the geometry info to the resultant SCA_result.nii.gz.
%
%                if doing seed-based in native space: path to the example_func.nii.gz 
%                                                     in the processed "reg" folder.
%
%                if doing seed-based in standard space: 
%                
% fsl_dir = FSLDIR
%
% output_dir = output folder name without filename ('SCA_result' will be the filename)
%
% varargin{1} = 'dr' if using dual regression (output is regression beta values,
%                instead of correlation coefficient).


function H_lv_seedbased_corrCoeffMap (seed_nii, func_data, example_func, fsl_dir, output_dir, varargin)

% FSL matlab code
addpath ([fsl_dir '/etc/matlab']);

% extract mean timeseries
[~,~] = call_fsl (['fslmeants -i ' func_data ...
							' -o ' output_dir '/seed_meants.txt'...
							' -m ' seed_nii]);

if nargin == 5

	fprintf ('seed-based correlation with pearson correlation.\n');

	% Load seed ROI timeseries:
	seedROIts = load ([output_dir '/seed_meants.txt']);

	% Load BOLD dataset:
	[func_img, func_img_dims] = read_avw (func_data);
	func_img_oneVolAsOneCol = reshape (func_img, ...
				   					   func_img_dims (1) * func_img_dims (2) * func_img_dims (3), ...
				   					   func_img_dims (4));

	% Calculate correlation of each volxel with the seed meants.
	func_img_oneVolAsOneRow = func_img_oneVolAsOneCol';
	corr_eff_oneVolAsOneRow = corr (seedROIts, func_img_oneVolAsOneRow);
	corr_eff_oneVolAsOneCol = corr_eff_oneVolAsOneRow';
	corr_eff_img = reshape(corr_eff_oneVolAsOneCol, ...
				  		   func_img_dims (1), ...
				 		   func_img_dims (2), ...
						   func_img_dims (3), ...
						   1);
	corr_eff_img (isnan (corr_eff_img) == 1) = 0;

	% r to z transform:
	corr_eff_img = 0.5 * log((1 + corr_eff_img) ./ (1 - corr_eff_img));

	% Save output image:
	save_avw (corr_eff_img, ...
			  [output_dir '/SCA_result'], ...
			  'f', ...
			  [2 2 2 1]);

	[~,~] = call_fsl (['fslcpgeom ' example_func ' ' ...
									output_dir '/SCA_result.nii.gz']);

elseif nargin == 6

	fprintf ('seed-based correlation with dual regression.\n');
	
	[~,~] = call_fsl (['dual_regression ' seed_nii ' 0 -1 0 ' output_dir ' ' func_data]);

	call_fsl (['fslmaths ' output_dir '/dr_stage2_subject00000.nii.gz ' output_dir '/SCA_result']);


end
	