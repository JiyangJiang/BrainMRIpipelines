function fmriprep_postproc_prepareConfounderList (fmriprep_confounder_tsv, ...
												  selected_confounder_names, ...
												  output_path_filename)


% example usage
% ==================================================================================
% fmriprep_confounder_tsv = '/data/jiyang/OW2_fMRI_cross-sectional/derivatives/fmriprep/v1.5.5/fmriprep/sub-11001/func/sub-11001_task-rest_desc-confounds_regressors.tsv';
% selected_confounder_names = {'csf','white_matter','trans_x','trans_y','trans_z','rot_x','rot_y','rot_z','framewise_displacement'};
% output_path_filename = '/data/jiyang/OW2_fMRI_cross-sectional/derivatives/fmriprep/v1.5.5/fmriprep/sub-11001/func/test.txt';


% further development plan
% ==================================================================================
% - Various number of a_comp_cor_??, t_comp_cor_??, and motion_outlier??. May use
%   the 'contains' function to identify each category and combine them as one group
%   of confounder, and include in the output if selected.


% ==================================================================================
% If the first value of a confounder is 'n/a', the confounder will be read in as a
% vector of char arrays. Therefore, first convert each char array (i.e. each row)
% to a string, and then convert the string to number
% ==================================================================================

all_confounders = tdfread (fmriprep_confounder_tsv);

% a cell array of field names
conf_names = fieldnames (all_confounders);
% number of all confounders
[N_conf, ~] = size (conf_names);

% number of selected confounders
[~, N_selected_conf] = size (selected_confounder_names);
fprintf ("--------------------------------------------\n");
fprintf ("%d confounders selected.\n", N_selected_conf);
fprintf ("--------------------------------------------\n");

% number of rows in each confounders
[Nrows, ~] = size (all_confounders.(conf_names{1}));
fprintf ("--------------------------------------------\n");
fprintf ("%d fMRI volumes.\n", Nrows)
fprintf ("--------------------------------------------\n");

% initiate
selected_confounder = zeros (Nrows, N_selected_conf);
c = 0;


for i = 1 : N_conf

	% if the confounder is selected
	if ismember (conf_names{i}, selected_confounder_names)

		fprintf ('Confounder %s is selected.\n', conf_names{i});

		c = c + 1;

		curr_conf = all_confounders.(conf_names{i});

		% if the current confounder is char type, and
		% the first row of the current confounder
		% contains 'n/a'
		if ischar (curr_conf)

			fprintf ('\tDealing with n/a in confounder %s ...\n',conf_names{i});

			for j = 1 : Nrows

				% replace n/a with 0
				if contains (curr_conf (j, :), 'n/a')

					curr_conf (j,:) = '0';

				end

				% convert chars to strings, and then to num
				selected_confounder (j,c) = str2num (convertCharsToStrings (curr_conf (j, :)));


			end

		% if the variable is a number already
		else
			selected_confounder (:,c) = curr_conf;
		end
	end
end

dlmwrite (output_path_filename, ...
		  selected_confounder, ...
		  'delimiter', ...
		  '\t')

