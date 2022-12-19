function DCM2NIIX = bmp_BIDSgenerator (dataset, DICOM2BIDS, DICOM_directory, BIDS_directory, varargin)
%
% DESCRIPTION
% ======================================================================================
%   BrainMRIpipelines BIDS converter (bmp_BIDSgenerator) aims to convert DICOM files to 
%   NIFTI files and store them in BIDS folder structure with BIDS-compliant filenames.
%
%
%
% ARGUMENTS
% ======================================================================================
%
%
% Compulsory
% +++++++++++++++++++++++++++
%
% dataset = 'ADNI' (use preset configuration for ADNI dataset), or 'other' (for any 
%           dataset other than ones described above).
%
% DICOM2BIDS = DICOM-to-BIDS mapping. This can be created by calling
%              'bmp_DICOMtoBIDSmapping'.
%
% DICOM_directory = '/path/to/overall/DICOM/directory'. This directory should contain
%                   DICOM folders for subjects.
%
% BIDS_directory = '/path/to/BIDS/output/directory'.
%
%
%
% Optional Name-Value pairs
% ++++++++++++++++++++++++++
%
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% |        Name        |        Value        |        Description        |
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% |    'Modalities'    |       cell array    |  A cell array of modality |
% |                    |      of modalities  |  names to be considered,  |
% |                    |                     |  e.g., {'T1w';'FLAIR'}.   |
% |                    |                     |  Default is {'T1w';       |
% |                    |                     |  'FLAIR';'asl'} for ADNI, |
% |                    |                     |  and {'T1w';'FLAIR'} for  |
% |                    |                     |  other datasets.          |
% ------------------------------------------------------------------------
% |    'Sandbox'       |     true/false      |  To display in terminal   |
% |                    |                     |  the intended structure   |
% |                    |                     |  of BIDS files, for       |
% |                    |                     |  validation. Default is   |
% |                    |                     |  true                     |
% ------------------------------------------------------------------------
% |    'MatOutDir'     | '/path/to/save/mat' |  Directory to save        |
% |                    |                     |  MAT files of dcm2niix    |
% |                    |                     |  commands and command     |
% |                    |                     |  outputs. Default is      |
% |                    |                     |  BMP_PATH/BIDS            |
% ------------------------------------------------------------------------


	BMP_PATH = getenv ('BMP_PATH');

	if ~ isfolder (BMP_PATH)

		fprintf (2, '%s : [WARNING] : BMP_PATH is not found. Was MATLAB openned from terminal?\n', mfilename);

	end


	p = inputParser;

	addRequired (p, 'Dataset',			@(x) ismember(x, {'ADNI';'other'}))
	addRequired (p, 'DICOM2BIDS',		@(x) istable(x))
	addRequired (p, 'DICOM_directory',	@isfolder);
	addRequired (p, 'BIDS_directory',	@isfolder);

	if strcmp (dataset, 'ADNI')

		addParameter (p, 'Modalities', 	{'T1w';'FLAIR';'asl'}, 	@iscell);

	else

		addParameter (p, 'Modalities',	{'T1w';'FLAIR'},		@iscell);

	end


	addParameter (p, 'Sandbox',		true,						@islogical);
	addParameter (p, 'MatOutDir',	fullfile(BMP_PATH,'BIDS'),	@isfolder);

	parse (p, dataset, DICOM2BIDS, DICOM_directory, BIDS_directory, varargin{:});

	DICOM2BIDS 			= p.Results.DICOM2BIDS;
	dataset 			= p.Results.Dataset;
	DICOM_directory 	= p.Results.DICOM_directory;
	BIDS_directory 		= p.Results.BIDS_directory;
	input_modalities	= p.Results.Modalities;
	sandbox				= p.Results.Sandbox;
	matOutDir			= p.Results.MatOutDir;


	switch dataset

		case 'ADNI'

			fprintf ('%s : Creating DICOM2BIDS for ADNI dataset ... ', mfilename);

			supported_modalities = {
									'T1w'
									'FLAIR'
									'asl'
									};

			modalities_to_consider = intersect (supported_modalities, input_modalities);

			DICOM2BIDS(find(strcmp(DICOM2BIDS.DATATYPE,'UNKNOWN')),:) = [];
			DICOM2BIDS(find(strcmp(DICOM2BIDS.MODALITY,'UNKNOWN')),:) = [];

			STUDYDATE_yyyy = cellfun(@(x) x(1:4), DICOM2BIDS.STUDYDATE, 'UniformOutput', false);
			STUDYDATE_mm   = cellfun(@(x) x(5:6), DICOM2BIDS.STUDYDATE, 'UniformOutput', false);
			STUDYDATE_dd   = cellfun(@(x) x(7:8), DICOM2BIDS.STUDYDATE, 'UniformOutput', false);
			STUDYDATE_dash = strcat (STUDYDATE_yyyy, '-', STUDYDATE_mm, '-', STUDYDATE_dd);


			datetime_dirout = cellfun(@dir, fullfile (	DICOM_directory, ...
														DICOM2BIDS.PATIENTID, ...
														DICOM2BIDS.DICOMSUBDIR, ...
														strcat (STUDYDATE_dash,'*')), 'UniformOutput', false);
			imageuid_dirout = cellfun(@dir, fullfile (	DICOM_directory, ...
														DICOM2BIDS.PATIENTID, ...
														DICOM2BIDS.DICOMSUBDIR, ...
														strcat (STUDYDATE_dash,'*'), ...
														strcat ('I',DICOM2BIDS.IMAGEUID)), 'UniformOutput', false);
			idx_existActualDICOM   = find(~cellfun(@isempty, imageuid_dirout));

			datetime_foldername = cellfun(@(x) x.name, datetime_dirout(idx_existActualDICOM), 'UniformOutput', false);

			DICOM_INPUT_DIR = cell(size(idx_existActualDICOM,1),1); % only those exist real DICOM directory
			DICOM_INPUT_DIR(:,1) = {'UNKNOWN'};
			DICOM_INPUT_DIR = fullfile (DICOM_directory, ...
										DICOM2BIDS.PATIENTID(idx_existActualDICOM), ...
										DICOM2BIDS.DICOMSUBDIR(idx_existActualDICOM), ...
										datetime_foldername, ...
										strcat ('I',DICOM2BIDS.IMAGEUID(idx_existActualDICOM)));


			BIDS_OUTPUT_DIR = cell(size(idx_existActualDICOM,1),1);
			BIDS_OUTPUT_DIR(:,1) = {'UNKNOWN'};
			BIDS_OUTPUT_DIR = fullfile (BIDS_directory, ...
										strcat('sub-', DICOM2BIDS.SUBJECT(idx_existActualDICOM)), ...
										strcat('ses-', DICOM2BIDS.SESSION(idx_existActualDICOM)), ...
										DICOM2BIDS.DATATYPE(idx_existActualDICOM));

			BIDS_NII_NAME = cell(size(idx_existActualDICOM,1),1);
			BIDS_NII_NAME(:,1) = {'UNKNOWN'};
			BIDS_NII_NAME = strcat(	'sub-', 	DICOM2BIDS.SUBJECT(idx_existActualDICOM), ...
									'_ses-', 	DICOM2BIDS.SESSION(idx_existActualDICOM), ...
									'_run-0', 	num2str(DICOM2BIDS.RUN(idx_existActualDICOM)), ...
									'_acq-', 	DICOM2BIDS.ACQUISITION(idx_existActualDICOM), ...
									'_',		DICOM2BIDS.MODALITY(idx_existActualDICOM));
			BIDS_NII_NAME(find(contains(BIDS_NII_NAME,'acq-UNKNOWN')),1) = erase (BIDS_NII_NAME(find(contains(BIDS_NII_NAME,'acq-UNKNOWN')),1), '_acq-UNKNOWN');
			

			TO_CONVERT = cell(size(idx_existActualDICOM,1),1);
			TO_CONVERT(:,1) = {'No'};
			TO_CONVERT(ismember(DICOM2BIDS.MODALITY(idx_existActualDICOM),modalities_to_consider)) = {'Yes'};


			curr_datetime = strrep(char(datetime),' ','_');
			CMD = strcat ('dcm2niix   -6', ...
									' -a y', ...
									' -b y', ...
									' -ba n', ...
									' -c BMP_', curr_datetime, ...
									' -d 1', ...
									' -e n', ...
									' -f', {' '}, BIDS_NII_NAME, ...
									' -g n', ...
									' -i y', ...
									' -l o', ...
									' -o', {' '}, BIDS_OUTPUT_DIR, ...
									' -p y', ...
									' -r n', ...
									' -s n', ...
									' -v 0', ...
									' -w 2', ...
									' -x n', ...
									' -z n', ...
									' --big-endian o', ...
									' --progress n', ...
									{' '}, DICOM_INPUT_DIR);

			fprintf ('DONE!\n');


			if sandbox

				DCM2NIIX = table (CMD, TO_CONVERT, DICOM_INPUT_DIR, BIDS_OUTPUT_DIR, BIDS_NII_NAME);

			else

				fprintf (2, '%s : [WARNING] : Runing dcm2niix to convert DICOM to BIDS NIFTI. Suggest testing with ''sandbox'' mode first if you haven''t done so.\n', mfilename);

				CMD_OUT = cell(size(CMD));
				CMD_OUT(:,1) = {'UNKNOWN'};
				CMD_STATUS = cell(size(CMD));
				CMD_STATUS(:,1) = {'UNKNOWN'};
				CMD_WARNINGS = cell(size(CMD));
				CMD_WARNINGS(:,1) = {'NONE'};

				for i = 1 : size (CMD,1)

					if ~ isfolder (BIDS_OUTPUT_DIR{i,1})

						status = mkdir (BIDS_OUTPUT_DIR{i,1});

						if status

							BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Success';

							fprintf ('%s : BIDS output directory ''%s'' has been successfully created.\n', mfilename, BIDS_OUTPUT_DIR{i,1});

						else

							BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Fail';

							fprintf(2, '%s : Creating BIDS directory ''%s'' failed.\n', mfilename, BIDS_OUTPUT_DIR{i,1});

							continue

						end

					else

						BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Exist';

					end

					if strcmp (TO_CONVERT{i,1}, 'Yes')

						[~, curr_imageuidfoldername] = fileparts (DICOM_INPUT_DIR{i,1});

						fprintf ('%s : (%d / %d) : Running dcm2niix to convert ''%s'' to ''%s'' ...', ...
								mfilename, i, size (CMD,1), curr_imageuidfoldername, BIDS_NII_NAME{i,1};

						[CMD_STATUS{i,1}, CMD_OUT{i,1}] = system (CMD{i,1});

						if contains (CMD_OUT{i,1}, 'warning', 'IgnoreCase', true)

							CMD_WARNINGS{i,1} = CMD_OUT{i,1};

						end

						fprintf (' DONE!\n');

					end

				end

				DCM2NIIX = table (CMD, TO_CONVERT, CMD_STATUS, CMD_OUT, CMD_WARNINGS, DICOM_INPUT_DIR, BIDS_OUTPUT_DIR, BIDS_NII_NAME);

			end

			fprintf ('%s : Saving dcm2niix commands and command outputs to bmp_ADNI.mat ... ', mfilename);
			
			if isfile (fullfile (matOutDir, 'bmp_ADNI.mat'))
				
				save (fullfile (matOutDir, 'bmp_ADNI.mat'), 'DCM2NIIX', '-append');

			else

				save (fullfile (matOutDir, 'bmp_ADNI.mat'), 'DCM2NIIX');

			end

			fprintf ('DONE!\n');


			

		case 'other'


			%% TO DO
			%
			%
			% FOR DATASET-LEVEL/SUBGROUP-LEVEL MAPPING, IGNORE 'session' AND/OR 'run' IF THERE IS
			% ONLY ONE SESSION LABEL AND/OR ONE RUN INDEX SPECIFIED IN DICOM2BIDS.
			% ###################################################################################
			%
			%
			% FOR DATASET-/SUBGROUP-LEVEL MAPPINGS, USE SUB-FOLDER NAMES IN DICOM DIRECTORY
			% AS SUBJECT LABEL.
			% ####################################################################################

	end

end

