function dcm2niix = bmp_BIDSgenerator (dataset, DICOM2BIDS, DICOM_directory, BIDS_directory, varargin)
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
	addRequired (p, 'DICOM2BIDS',		@(x) isstruct(x) && isscalar(x))
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

	if strcmp (dataset, 'ADNI')

		DICOM2BIDS = p.Results.DICOM2BIDS.DICOM2BIDS;

	else

		DICOM2BIDS = p.Results.DICOM2BIDS;

	end

	dataset 			= p.Results.Dataset;
	DICOM_directory 	= p.Results.DICOM_directory;
	BIDS_directory 		= p.Results.BIDS_directory;
	input_modalities	= p.Results.Modalities;
	sandbox				= p.Results.Sandbox;
	matOutDir			= p.Results.MatOutDir;


	switch dataset

		case 'ADNI'

			supported_modalities = {
									'T1w'
									'FLAIR'
									'asl'
									};

			modalities_to_consider = intersect (supported_modalities, input_modalities);

			all_DICOM2BIDS_fields 	= fieldnames(DICOM2BIDS);
			all_sessions 			= all_DICOM2BIDS_fields(find(~strcmp(all_DICOM2BIDS_fields,'subject')));

			clear to_run_dcm2niix;
			to_run_dcm2niix_idx = 1;

			for subj_idx = 1 : size (DICOM2BIDS,2)

				for ses_idx = 1 : size (all_sessions)

					if ~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}))

						curr_session 		= all_sessions{ses_idx};
						curr_subjectLabel 	= DICOM2BIDS(subj_idx).subject;

						fprintf ('%s : subject label = %s\n', mfilename, curr_subjectLabel);
						fprintf ('%s : session label = %s\n', mfilename, curr_session);

						subj_avail_datype = fieldnames (DICOM2BIDS(subj_idx).(curr_session));

						for datype_idx = 1 : size (subj_avail_datype, 1)

							curr_datype = subj_avail_datype{datype_idx,1};

							fprintf ('%s : datatype = %s, session label = %s, subject label = %s\n', mfilename, curr_datype, curr_session, curr_subjectLabel);

							subj_avail_mod_for_curr_datype = fieldnames (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype));

							for mod_idx = 1 : size (subj_avail_mod_for_curr_datype, 1)

								curr_mod = subj_avail_mod_for_curr_datype{mod_idx,1};

								fprintf ('%s : modality = %s, datatype = %s, session label = %s, subject label = %s\n', mfilename, curr_mod, curr_datype, curr_session, curr_subjectLabel);

								if ismember (curr_mod, modalities_to_consider)

									subj_avail_run_for_curr_mod = fieldnames (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod));

									for run_idx = 1 : size (subj_avail_run_for_curr_mod)

										curr_run 		= subj_avail_run_for_curr_mod{run_idx,1}; % 'run01', 'run02'
										curr_run_index 	= erase (curr_run, 'run');

										fprintf ('%s : run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);
										
										

										% +++++++++++++++++++++++++++++++++
										%          DICOM criteria
										% +++++++++++++++++++++++++++++++++

										subj_avail_DICOMfields_for_curr_run = fieldnames (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM);
										
										% DICOM - SeriesDescription

										if any(strcmp(subj_avail_DICOMfields_for_curr_run,'SeriesDescription')) && ...
											~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.SeriesDescription)

											fprintf ('%s : DICOM SeriesDescription is found in DICOM2BIDS and not empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											curr_DICOMseriesDesc 	= DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.SeriesDescription;

										else

											fprintf (2, '%s : DICOM SeriesDescription is NOT found in DICOM2BIDS and/or is empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											continue;

										end


										% DICOM - PatientID

										if any(strcmp(subj_avail_DICOMfields_for_curr_run,'PatientID')) && ...
											~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.PatientID)

											fprintf ('%s : DICOM PatientID is found in DICOM2BIDS and not empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);
										
											curr_DICOMpatID			= DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.PatientID;

										else

											fprintf (2, '%s : DICOM PatientID is NOT found in DICOM2BIDS and/or is empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											continue;

										end


										% DICOM - StudyDate

										if any(strcmp(subj_avail_DICOMfields_for_curr_run,'StudyDate')) && ...
											~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.StudyDate)

											fprintf ('%s : DICOM StudyDate is found in DICOM2BIDS and not empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);
										
											curr_DICOMstudyDate		= DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.StudyDate;

										else

											fprintf (2, '%s : DICOM StudyDate is NOT found in DICOM2BIDS and/or is empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											continue;

										end


										% DICOM - IMAGEUID

										if any(strcmp(subj_avail_DICOMfields_for_curr_run,'IMAGEUID')) && ...
											~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.IMAGEUID)

											fprintf ('%s : DICOM IMAGEUID is found in DICOM2BIDS and not empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);
										
											curr_DICOMimageuid		= DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.IMAGEUID;

										else

											fprintf (2, '%s : DICOM IMAGEUID is NOT found in DICOM2BIDS and/or is empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											continue;

										end


										% DICOM - subfoldername

										if any(strcmp(subj_avail_DICOMfields_for_curr_run,'subfoldername')) && ...
											~ isempty (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.subfoldername)

											fprintf ('%s : DICOM subfoldername is found in DICOM2BIDS and not empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);
										
											curr_DICOMsubfolder		= DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).DICOM.subfoldername;

										else
											
											fprintf (2, '%s : DICOM subfoldername is NOT found in DICOM2BIDS and/or is empty (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

											continue;

										end


										dicom_seq_dir = dir ( fullfile (	DICOM_directory, curr_DICOMpatID, curr_DICOMsubfolder, ...
																[curr_DICOMstudyDate(1:4) '-' curr_DICOMstudyDate(5:6) '-' curr_DICOMstudyDate(7:8) '*']));

										if size (dicom_seq_dir,1) == 1

											dicom_uid_dir = dir ( fullfile (dicom_seq_dir(1).folder, dicom_seq_dir(1).name));

											if size (dicom_uid_dir,1) == 3     % 2 additional directories - '.' and '..'

												if strcmp (dicom_uid_dir(3).name, ['I' curr_DICOMimageuid])

													curr_DICOMinputdir = fullfile (dicom_uid_dir(3).folder, dicom_uid_dir(3).name);

													to_run_dcm2niix.DICOMinputdir{to_run_dcm2niix_idx,1} = curr_DICOMinputdir;

													% +++++++++++++++++++++++++++++++++++
													%           BIDS entities
													% +++++++++++++++++++++++++++++++++++
													% Only set BIDS entities for those
													% exist  DICOM folder.
													% +++++++++++++++++++++++++++++++++++

													% ADNI_customisedBISDfields = {	'subject'
													% 								'session'
													% 								'run'
													% 								'acquisition'
													% 								'modality'
													% 								};

													subj_avail_BIDSfields_for_curr_run = fieldnames (DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS);
													subj_avail_BIDSfields_for_curr_run = subj_avail_BIDSfields_for_curr_run(find(~cellfun(@isempty,subj_avail_BIDSfields_for_curr_run)),1);

													acq = '';

													for BIDSfld_idx = 1 : size (subj_avail_BIDSfields_for_curr_run, 1)

														curr_BIDSfield = subj_avail_BIDSfields_for_curr_run{BIDSfld_idx,1};

														switch curr_BIDSfield

															case 'subject'

																% just checking. curr_subjectLabel should be set before, from DICOM2BIDS.subject.
																if ~strcmp (curr_subjectLabel, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield))

																	fprintf (2, '%s : subject label in DICOM2BIDS BIDS subject field (''%s'') does NOT match DICOM2BIDS.subject (''%s'') (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield), curr_subjectLabel, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

																	continue;

																end

															case 'session'

																if ~strcmp (curr_session, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield))

																	fprintf (2, '%s : session label in DICOM2BIDS BIDS session field (''%s'') does NOT match curr_session set previously (''%s'') (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield), curr_session, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

																	continue;

																end

															case 'run'

																if ~strcmp (curr_run, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield))

																	fprintf (2, '%s : run index in DICOM2BIDS BIDS run field (''%s'') does NOT match curr_run set previously (''%s'') (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield), curr_run, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

																	continue;

																end

															case 'acquisition'

																acq = [acq '_acq-' DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield)];

															case 'modality'

																if ~strcmp (curr_mod, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield))

																	fprintf (2, '%s : modality in DICOM2BIDS BIDS modality field (''%s'') does NOT match curr_mod set previously (''%s'') (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, DICOM2BIDS(subj_idx).(all_sessions{ses_idx}).(curr_datype).(curr_mod).(curr_run).BIDS.(curr_BIDSfield), curr_mod, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

																	continue;

																end

														end

													end

													curr_BIDSoutputdir 		= fullfile (BIDS_directory, ['sub-' curr_subjectLabel], ['ses-' curr_session], curr_datype);

													curr_BIDSniibasename	= ['sub-' curr_subjectLabel '_ses-' curr_session '_run-' curr_run_index acq '_' curr_mod];

													to_run_dcm2niix.BIDSoutputdir{to_run_dcm2niix_idx,1} = curr_BIDSoutputdir;
													to_run_dcm2niix.BIDSniibasename{to_run_dcm2niix_idx,1} = curr_BIDSniibasename;

													to_run_dcm2niix_idx = to_run_dcm2niix_idx + 1;

												else

													fprintf (2, '%s : IMAGEUID not matching - ''%s'' (actual DICOM dir) vs. ''%s'' (DICOM2BIDS) (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, dicom_uid_dir(3).name, ['I' curr_DICOMimageuid], curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

													continue;

												end

											elseif size (dicom_uid_dir,1) > 3

												fprintf (2, '%s : More than one IMAGEUID folder in DICOM datetime folder (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

												continue;

											elseif size (dicom_uid_dir,1) == 0

												fprintf (2, '%s : DICOM datetime folder %s does NOT have IMAGEUID folder (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, fullfile (dicom_seq_dir(1).folder, dicom_seq_dir(1).name), curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

												continue;

											end

										elseif size (dicom_seq_dir,1) == 0

											fprintf (2, '%s : [WARNING] : DICOM folder %s does NOT exist. The DICOM2BIDS mapping was created from ADNI study data. Therefore, it is possible the actually downloaded DICOM data do not contain this DICOM folder (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, fullfile (DICOM_directory, curr_DICOMpatID, curr_DICOMsubfolder, [curr_DICOMstudyDate(1:4) '-' curr_DICOMstudyDate(5:6) '-' curr_DICOMstudyDate(7:8) '*']), curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

										elseif size (dicom_seq_dir,1) > 1
											
											fprintf (2, '%s : Incorrect number of DICOM sequence folders. Should be only one (run = %s, modality = %s, datatype = %s, session label = %s, subject label = %s).\n', mfilename, curr_run_index, curr_mod, curr_datype, curr_session, curr_subjectLabel);

										end
									
									end

								else

									fprintf ('%s : Modality ''%s'' is not to be considered.\n', mfilename, curr_mod);

								end

							end

						end

					end

				end

			end

			if 1 == exist ('to_run_dcm2niix', 'var')

				if sandbox

					dcm2niix = run_dcm2niix (to_run_dcm2niix, 'ADNI', matOutDir, 'sandbox');

				else

					dcm2niix = run_dcm2niix (to_run_dcm2niix, 'ADNI', matOutDir);

				end

			else

				fprintf (2, '%s : [WARNING] : Variable ''to_run_dcm2niix'' does NOT exist. This may be because the current DICOM directory does not have any files matching criteria defined in DICOM2BIDS loaded from bmp_ADNI.mat.\n', mfilename);

			end


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



function dcm2niix = run_dcm2niix (to_run_dcm2niix, dataset, matOutDir, varargin)

	dcm2niix = to_run_dcm2niix;

	if strcmp (dataset, 'ADNI')

		for i = 1 : size (dcm2niix.DICOMinputdir,1)

			curr_datetime = strrep(char(datetime),' ','_');

			dcm2niix_opts_ADNI = [' -6 -a y -b y -ba n -c BMP_' curr_datetime ' -d 1 -e n -f ' dcm2niix.BIDSniibasename{i,1} ' -g n -i y -l o -o ' dcm2niix.BIDSoutputdir{i,1} ' -p y -r n -s n -v 0 -w 2 -x n -z n --big-endian o --progress n '];

			dcm2niix.cmd{i,1} = ['dcm2niix' dcm2niix_opts_ADNI dcm2niix.DICOMinputdir{i,1}];

		end


		if nargin == 4 && strcmp(varargin{1}, 'sandbox')

			fprintf('%s : Saving dcm2niix commands to bmp_ADNI_dcm2niixcmd.mat.\n', mfilename);

			save (fullfile (matOutDir, 'bmp_ADNI_dcm2niixcmd.mat'), 'dcm2niix');


		elseif nargin == 3

			fprintf (2, '%s : [WARNING] : Runing dcm2niix to convert DICOM to BIDS NIFTI. Suggest testing with ''sandbox'' mode first if you haven''t done so.\n', mfilename);

			for i = 1 : size (dcm2niix.cmd,1)

				if ~ isfolder (dcm2niix.BIDSoutputdir{i,1})

					dcm2niix.BIDSmkdirStatus{i,1} = mkdir (dcm2niix.BIDSoutputdir{i,1});

					if dcm2niix.BIDSmkdirStatus{i,1}

						fprintf ('%s : BIDS output directory ''%s'' has been successfully created.\n', mfilename, dcm2niix.BIDSoutputdir{i,1});

					else

						continue

					end

				end

				fprintf ('%s : (%d / %d) : Running dcm2niix to convert ''%s'' to ''%s''.nii ...', mfilename, i, size (dcm2niix.DICOMinputdir,1), dcm2niix.DICOMinputdir{i,1}, fullfile(dcm2niix.BIDSoutputdir{i,1}, dcm2niix.BIDSniibasename{i,1}));

				[dcm2niix.status{i,1}, dcm2niix.cmdout{i,1}] = system (dcm2niix.cmd{i,1});

				if contains (dcm2niix.cmdout{i,1}, 'warning', 'IgnoreCase', true)

					dcm2niix.warnings{i,1} = true;

				else

					dcm2niix.warnings{i,1} = false;

				end

				fprintf (' DONE!\n');

			end


			fprintf('%s : Saving dcm2niix commands and command outputs to bmp_ADNI_dcm2niixout.mat.\n', mfilename);

			save (fullfile (matOutDir, 'bmp_ADNI_dcm2niixcmdout.mat'), 'dcm2niix');

		end

	end

end

% to_run_dcm2niix

% ans = 

%   struct with fields:

%       DICOMinputdir: '/Users/z3402744/Work/ADNI_test/018_S_4399/Sagittal_3D_Accelerated_MPRAGE/2021-07-30_11_29_32.0/I1475316'
%       BIDSoutputdir: '/Users/z3402744/Work/ADNI_test/BIDS/sub-ADNI018S4399/ses-m114/anat'
%     BIDSniibasename: 'sub-ADNI018S4399_ses-m114_run-01_acq-sag3dMprage_T1w'

