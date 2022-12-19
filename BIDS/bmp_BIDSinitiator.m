function bmp_BIDSinitiator (varargin)

% INPUT ARGUMENTS
%
% bmp_BIDSinitiator ();
%
% bmp_BIDSinitiator ('/path/to/BIDS');
%
% bmp_BIDSinitiator ('ADNI');
%
% bmp_BIDSinitiator ('/path/to/BIDS', 'ADNI');
%
% bmp_BIDSinitiator ('/path/to/BIDS', 'other');
%

	BMP_PATH = getenv ('BMP_PATH');

	supported_datasets = 	{
							'ADNI'
							};

	bmp_ver = bmp_version ({'BMP';'ADNI';'BIDS'});
	

	if nargin == 1

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = 'other';

		elseif ismember (varargin{1}, supported_datasets)

			BIDS_directory = pwd;

			dataset = varargin{1};

			bmp_print (bmp_convention_MATLAB ('s'), 	'%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('k'), 	'''%s''', varargin{1});
			bmp_print (bmp_convention_MATLAB ('t'), 	' dataset ');
			bmp_print (bmp_convention_MATLAB ('p'),		' ''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('t'), 	'.\n');

		else

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('e'), 'BIDS directory ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('e'), ' does not exist or is not a directory.\n');

		end

	elseif nargin < 1

		BIDS_directory = pwd;

		dataset = 'other';

	elseif nargin == 2 && ismember(varargin{2}, supported_datasets)

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = varargin{2};

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('k'), '''%s''', varargin{2});
			bmp_print (bmp_convention_MATLAB ('t'), ' dataset ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('t'), '.\n');

		else

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('e'), 'BIDS directory ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('e'), ' does not exist or is not a directory.\n');

		end

	else

		bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
		bmp_print (bmp_convention_MATLAB ('e'), 'Incorrect number of input arguments : \n');

		for i = 1 : nargin

			bmp_print (bmp_convention_MATLAB ('UnterminatedStrings'), '     - %s\n', varargin{i});

		end

	end






	switch dataset

		case 'ADNI'

			% dataset_description.json

			dset_desc = struct ('Name',			'ADNI', ...
								'BIDSVersion',	'1.8.0', ...
								'DataType',		'raw', ...
								'GeneratedBy',	struct ('Name',		'BrainMRIpipelines', ...
														'Version',	bmp_ver, ...
														'CodeURL',	'https://github.com/JiyangJiang/BrainMRIpipelines'));

			dset_desc_json = jsonencode(dset_desc,'PrettyPrint',true);

			dset_desc_fnam = fullfile (BIDS_directory, 'dataset_description.json');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', dset_desc_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (dset_desc_fnam, 'w');
			fprintf (fid, '%s\n', dset_desc_json);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');


			% CHANGES

			changes = sprintf (['1.0.0 (' char(datetime) ')\n' ...
								'  * First version created with BrainMRIpipelines.\n']);

			changes_fnam = fullfile (BIDS_directory, 'CHANGES');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', changes_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (changes_fnam, 'w');
			fprintf (fid, '%s\n', changes);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');

			

			% README

			readme = sprintf (['This is an Alzheimer''s Disease Neuroimaging Initiative (ADNI) dataset. The BIDS directory is constructed by using BrainMRIpipelines. More details about the ADNI cohort can be found at the official website (https://adni.loni.usc.edu/).\n']);

			readme_fnam = fullfile (BIDS_directory, 'README');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', readme_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (readme_fnam, 'w');
			fprintf (fid, '%s\n', readme);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');



			% participants.tsv

			ppts_tsv_fnam = fullfile (BIDS_directory, 'participants.tsv');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', ppts_tsv_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			ADNI_ppts_dat = load (fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat')).forBIDSpptsTsv;

			writetable (ADNI_ppts_dat, ppts_tsv_fnam, ...
							'FileType', 			'text', ...
							'WriteVariableNames', 	true, ...
							'Delimiter',			'\t' ...
						);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');




			% participants.json

			ADNI_ppts_vars = 	struct ('baseline_age', 		struct ('Description', 	'Baseline age. This is evidenced by observing the AGE variable being consistent at different timepoints for the same participant.',...
																		'Units',       	'Years'), ...
										'gender',				struct ('Description', 	'Gender of participant.', ...
																		'Levels',       struct ('Male', 	'Level for male participants', ...
																								'Female',	'Level for female participants')), ...
										'baseline_diagnosis',	struct ('Description', 	'Baseline diagnosis extracted from DX_bl variable in ADNI study data.', ...
																		'Levels',		struct ('CN',		'Level for cognitively normal participants.', ...
																								'MCI',		'Level for participants with Mild Cognitive Impairment (ADNI1/3).', ...
																								'EMCI',		'Level for participants with Early Mild Cognitive Impairment (ADNI GO/2).', ...
																								'LMCI',		'Level for participants with Late Mild Cognitive Impairment (ADNI GO/2).', ...
																								'SMC',		'Level for participants with Significant Memory Concern (ADNI 2).', ...
																								'AD',		'Level for participants with Alzheimer''s Disease.')));

			ADNI_ppts_json = jsonencode(ADNI_ppts_vars,'PrettyPrint', true);

			ppts_json_fnam = fullfile (BIDS_directory, 'participants.json');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', ppts_json_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (ppts_json_fnam, 'w');
			fprintf (fid, '%s\n', ADNI_ppts_json);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');



			% code, derivatives, sourcedata

			necessaryBIDSdirs = {fullfile('code','BMP'); 'derivatives'; 'sourcedata'};

			for i = 1 : size (necessaryBIDSdirs, 1)

				if ~ isfolder (fullfile (BIDS_directory, necessaryBIDSdirs{i,1}))

					bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
					bmp_print (bmp_convention_MATLAB ('t'), 'Making ');
					bmp_print (bmp_convention_MATLAB ('p'), '''%s''', fullfile (BIDS_directory, necessaryBIDSdirs{i,1}));
					bmp_print (bmp_convention_MATLAB ('t'), ' directory ...');

					[~] = mkdir (fullfile (BIDS_directory, necessaryBIDSdirs{i,1}));

					bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');

				end

			end


		case 'other'


			%% DEAL WITH OTHER DATASETS

	end

end




