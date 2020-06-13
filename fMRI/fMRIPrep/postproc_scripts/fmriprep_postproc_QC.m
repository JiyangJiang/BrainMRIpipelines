% function fmriprep_postproc_QC (fmriprep_folder)

% example use
fmriprep_folder = '/data/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS/derivatives/fmriprep/v1.5.5/fmriprep';
% fmriprep_folder = '/data/jiyang/OW2_fMRI_cross-sectional/derivatives/fmriprep/v1.5.5/fmriprep';

firstNvolRemoved = 5;


% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ %

% delete fmriprep_folder/Jmod_cohort_info.tsv if exists
% system (['if [ -f "' fmriprep_folder '/Jmod_cohort_info.tsv" ];then rm -f ' fmriprep_folder '/Jmod_cohort_info.tsv;fi']);
fid = fopen ([fmriprep_folder '/Jmod_cohort_info.tsv'],'w');
fprintf (fid,'%s\t%s\r\n','ID','meanFD');
fclose (fid);


criterion = 1;


all_tsv = dir ([fmriprep_folder '/sub-*/func/*desc-confounds_regressors.tsv']);


[N_alltsv, ~] = size (all_tsv);

for i = 1 : N_alltsv

	all_tsv_parts = strsplit (all_tsv(i).name, '_');
	subID = all_tsv_parts{1};


	all_confounders = tdfread ([all_tsv(i).folder '/' all_tsv(i).name]);


	switch criterion

	case 1

		% Criterion 1
		% ------------------------------------------------------------------------------------
		% translation and/or rotation along any of x,y,z axis exceed 2 mm or 2 degrees

		trans_rot_xyz = [all_confounders.trans_x all_confounders.trans_y all_confounders.trans_z ...
						 all_confounders.rot_x all_confounders.rot_y all_confounders.rot_z];


		if sum (sum (trans_rot_xyz > 2 | trans_rot_xyz < -2)) > 0
			fprintf ('Suggest remove %s based on criterion 1.\n', subID);
		end

	case 2

		% Criterion 2
		% -----------------------------------------------------------------------------------
		% average framewise displace > 0.5
		% --- Is this criterion widely used?

		all_confounders.framewise_displacement (1, :) = '0';

		[Nrows_FD, ~] = size (all_confounders.framewise_displacement);

		for j = 1 : Nrows_FD
			FD (j,1) = str2num (convertCharsToStrings (all_confounders.framewise_displacement (j, :)));
		end

		if mean (FD) > 0.5
			fprintf ('Suggest remove %s based on criterion 2.\n', subID);
		end
	end



	% March 3, 2020
	% ----------------------------------------------------------------
	% calculate mean framewise displacement to be used as a regressor
	% in analyses. The first N of values will be disregarded when
	% calculating the average, complying with the first N volumes
	% removed to reach stable status.
	% ----------------------------------------------------------------

	all_confounders.framewise_displacement (1, :) = '0';

	[Nrows_FD, ~] = size (all_confounders.framewise_displacement);

	for k = 1 : Nrows_FD
		framewise_displacement_mtx (k,1) = str2num (convertCharsToStrings (all_confounders.framewise_displacement (k, :)));
	end

	meanFD = mean (framewise_displacement_mtx (firstNvolRemoved+1:end, 1));

	fprintf ("%s has a mean FD of %.5f.\n", subID, meanFD);

	fid = fopen ([fmriprep_folder '/Jmod_cohort_info.tsv'],'a');
	fprintf (fid,'%s\t%.5f\r\n',subID,meanFD);
	fclose (fid);
end



