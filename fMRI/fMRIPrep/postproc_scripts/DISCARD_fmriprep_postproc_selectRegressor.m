
% EXAMPLE fMRIPrep OUTPUT FIELDS
% ===============================================================================
%
% csf
% white_matter
% global_signal
% std_dvars
% dvars
% framewise_displacement
% t_comp_cor_00
% t_comp_cor_01
% t_comp_cor_02
% t_comp_cor_03
% t_comp_cor_04
% t_comp_cor_05
% a_comp_cor_00
% a_comp_cor_01
% a_comp_cor_02
% a_comp_cor_03
% a_comp_cor_04
% a_comp_cor_05
% cosine00
% cosine01
% cosine02
% cosine03
% cosine04
% non_steady_state_outlier00
% non_steady_state_outlier01
% trans_x
% trans_y
% trans_z
% rot_x
% rot_y
% rot_z
%
%
%
% USAGE
% ==============================================================================
%
% fmriprep_tsv = path to tsv file containing regressors generated from fMRIPrep
%
% selected_regressor_names = list of regressor names delimited by comma
%
% output_format = 'spreadsheet' or 'matrix', indicating if the output should be
%                 a spreadseet (for fsl_glm) or a matrix which can be used in
%                 MATLAB.
%
% varargin{1} = path to output including filename if output_format = 'spreadsheet'.

function output = fmriprep_postproc_selectRegressor (fmriprep_tsv, ...
													 selected_regressor_names, ...
													 output_format, ...
													 varargin)

	tsv_struct = tdfread (fmriprep_tsv);

	selected_regressor_names_cellArr = strsplit (selected_regressor_names, ',');

	selected_regressors_Nrows = size(tsv_struct.(selected_regressor_names_cellArr{1}), 1);
	selected_regressors_Ncols = size(selected_regressor_names_cellArr, 2);

	selected_regressors = cell (selected_regressors_Nrows, selected_regressors_Ncols);


	for i = 1 : size(selected_regressor_names_cellArr,2)

		curr_regressor = tsv_struct.(selected_regressor_names_cellArr{i});

		selected_regressors ):,i) = curr_regressor;
	end


	% output
	switch output_format

	case 'matrix'

		output = selected_regressors;

	case 'spreadsheet'

		dlmwrite (varargin{1}, selected_regressors, ...
				  'delimiter','\t', ...
				  'precision','%.5f');

		output = varargin{1};

	end