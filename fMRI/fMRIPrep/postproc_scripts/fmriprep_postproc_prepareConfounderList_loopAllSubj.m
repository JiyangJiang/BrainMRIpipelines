function fmriprep_postproc_prepareConfounderList_loopAllSubj (fmriprep_folder, ...
															  selected_confounder_names, ...
															  FUTURE_folder)

% example use
% =======================================================================================================================
% fmriprep_folder = '/data/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/derivatives/fmriprep/v1.5.5/fmriprep/test';
% selected_confounder_names = {'csf','white_matter','trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'};
% FUTURE_folder = '/home/jiyang/my_software/FUTURE';


addpath ([FUTURE_folder '/fMRI/fMRIPrep/postproc_scripts']);

% read text to char cell array
% copied from: https://au.mathworks.com/matlabcentral/answers/321413-how-to-read-a-text-file-into-a-char-array
allsubID = regexp(fileread([fmriprep_folder '/subIDlist']), '\r?\n', 'split')
[~, Nsubj] = size (allsubID);

% loop Nsubj-1 as otherwise the last empty line 
% is counted, which will cause error
parfor (i = 1 : (Nsubj-1), 5)
	currSubID = allsubID{1,i};

	output_path_filename = [fmriprep_folder '/' currSubID '/func/' currSubID '_task-rest_desc-basic_confounds_noHeader_regressors.tsv']
	
	% sometimes the filename has 'run-01'
	conf_tsv = dir ([fmriprep_folder '/' currSubID '/func/' currSubID '_*_desc-confounds_regressors.tsv']);
	fmriprep_confounder_tsv = [conf_tsv.folder '/' conf_tsv.name];

	fmriprep_postproc_prepareConfounderList (fmriprep_confounder_tsv, ...
											 selected_confounder_names, ...
											 output_path_filename);
end