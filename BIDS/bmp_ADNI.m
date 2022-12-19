function varargout = bmp_ADNI (operation_mode, varargin)
%
% DESCRIPTION
% ====================================================================================
%
%   bmp_ADNI contains a few shortcuts for ADNI cohort, including processing ADNI study
%   data downloaded from ADNI website, creating or retrieving existing DICOM-to-BIDS 
%   mappings, running dcm2niix to convert DICOM to BIDS, and diagnosing/check any 
%   missing by examining actual DICOM folders or comparing with Clinica outputs (TO
%   BE DEVELOPED).
%
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in the following modes:
%
%
%     'initiate' mode
%     +++++++++++++++++++++++++++++++++
%
%       Call bmp_ADNI_studyData.m to process ADNI study data, and generate
%       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat. The MAT file saves
%       MRI_master, DEM_master, forDICOM2BIDS, and forBIDSpptsTsv.
%
%         operation_mode = 'initiate';
%
%         varargout{1} = DEM_master;
%         varargout{2} = MRI_master;
%         varargout{3} = forDICOM2BIDS;
%         varargout{4} = forBIDSpptsTsv;
%
%
%     'create' or 'create_mapping' mode 
%     +++++++++++++++++++++++++++++++++
%       
%        This mode is used to generate DICOM-to-BIDS mappings, and append the mappings 
%        to /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat.
%
%        operation_mode = 'create'; % or 'create_mapping'
%
%        varargin{1} = /path/to/mat/file/to/save, if not 
%                      /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat
%
%        varargout{1} = DICOM2BIDS;
%
%
%     'retrieve' or 'retrieve_mapping' mode
%     +++++++++++++++++++++++++++++++++++++
%
%        This mode load /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat to retrieve 
%        the predefiend mappings.
%
%        operation_mode = 'retrieve'; % or 'retrieve_mapping'
%
%        varargout{1} = DICOM2BIDS;
%
%
%     'dcm2niix' or 'run_dcm2niix' mode
%     +++++++++++++++++++++++++++++++++
%
%        This mode will call dcm2niix to convert DICOM to BIDS. By default,
%        /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be read for
%        predefined dcm2niix commands.
%
%        operation_mode = 'dcm2niix'; % or 'run_dcm2niix'
%
%        varargin{1} = /path/to/mat/file, if not 
%                      /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat.
%
%        varargout{1} = DCM2NIIX
%
%
%     'refresh' or 'refresh_mat_file' mode
%     +++++++++++++++++++++++++++++++++++++
%
%        This mode refreshes the predefined bmp_ADNI.mat in BMP. This mode is
%        for internal use.
%
%        operation_mode = 'refresh'; % or 'refresh_mat_file'
%
%        varargin{1} = DICOM directory
%        varargin{2} = BIDS directory
%
%        varargout{1} = DCM2NIIX;
%
%
%     'prepare' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        This mode prepares dcm2niix commands and save in 
%        /path/to/BIDS/code/BMP/bmp_ADNI.mat. These commands are with real paths
%        to BIDS and DICOM.
%
%        operation_mode = 'prepare';
%
%        varargin{1} = DICOM directory
%        varargin{2} = BIDS directory
%
%        varargout{1} = DCM2NIIX;
%
%
%     'checkback' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        --== TO BE DEVELOPED ==--
%
%
%
% SUPPORTED MODALITIES
% ====================================================================================
%
%   - T1w
%   - FLAIR
%   - asl
%
%
% HISTORY
% ====================================================================================
%
%   05 December 2022 - first version.
%
%   09 December 2022 - bmp_BIDSgenerator needs scalar input. Therfore, change
%                      DICOM2BIDS(i) to ADNI.DICOM2BIDS(i).
%
%   19 December 2022 - update to describe DICOM2BIDS using MATLAB tables.
%
%
%
% KNOWN LIMITATIONS
% ====================================================================================
%
%  - Some limitations are commented in-line.
%
%  - Assumes max of 9 runs for each modality.
%
%


	BMP_PATH = getenv ('BMP_PATH');



	% possible keywords in DICOM sequence name for each modality in ADNI
	possibleASLkeywords = 	{
							'ASL'
							'cerebral blood flow'
							'perfusion'
							'MoCoSeries'
							};						% 16Dec2022 : 	According to ASL QC files, SEQUENCE with
													% 				'MoCoSeries' corresponds to ASL.

	possibleT1keywords = 	{
							'MPRAGE'
							'T1'
							'IR-SPGR'
							'IR-FSPGR'
							'MP-RAGE'
							'MP RAGE'
							};

	possibleFLAIRkeywords = {
							'FLAIR'
							};



	switch operation_mode


		case 'initiate'

			clear all
			clc

			fprintf ('%s : Running in ''initiate'' mode.\n', mfilename);
			fprintf ('%s : Calling bmp_ADNI_studyData.m to process ADNI study data ... ', mfilename);

			[varargout{1}, varargout{2}, varargout{3}, varargout{4}] = bmp_ADNI_studyData;

			fprintf ('DONE!\n');


		case {'create'; 'create_mapping'}

			if nargin == 2 && endsWith(varargin{1},'.mat')
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''create'' mode. Will save DICOM2BIDS mapping to %s.\n',mfilename,output);

			fprintf ('%s : Loading bmp_ADNI.mat ... ', mfilename);

			ADNI_mat = load (fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat'));

			fprintf ('DONE!\n', mfilename);

			forDICOM2BIDS = ADNI_mat.forDICOM2BIDS;
			
			fprintf ('%s : Start to create DICOM2BIDS mapping.\n', mfilename);


			% Initialise
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SUBJECT = strcat('ADNI',erase(forDICOM2BIDS.SID,'_'));
			SESSION = forDICOM2BIDS.VISCODE;
			DATATYPE = cell (size (forDICOM2BIDS,1),1);
			DATATYPE(:,1) = {'UNKNOWN'};
			MODALITY = cell (size (forDICOM2BIDS,1),1);
			MODALITY(:,1) = {'UNKNOWN'};
			RUN = ones (size (forDICOM2BIDS,1),1);
			ACQUISITION = cell (size (forDICOM2BIDS,1),1);
			ACQUISITION(:,1) = {'UNKNOWN'};
			SEQUENCE = forDICOM2BIDS.SEQUENCE;
			PATIENTID = forDICOM2BIDS.SID;
			STUDYDATE = strrep(cellstr(forDICOM2BIDS.SCANDATE),'-','');
			IMAGEUID = forDICOM2BIDS.IMAGEUID;
			DICOMSUBDIR = strrep(strrep(strrep(forDICOM2BIDS.SEQUENCE,' ','_'),'(','_'),')','_');


			% Modality
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			MODALITY(find(contains(SEQUENCE,possibleT1keywords,		'IgnoreCase',true)),1) = {'T1w'};
			MODALITY(find(contains(SEQUENCE,possibleFLAIRkeywords,	'IgnoreCase',true)),1) = {'FLAIR'};
			MODALITY(find(strcmp(SEQUENCE,'Axial T2 Star-Repeated with exact copy of FLAIR')),1) = {'UNKNOWN'};
			MODALITY(find(contains(SEQUENCE,possibleASLkeywords,	'IgnoreCase',true)),1) = {'asl'};

			% Datatype
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			DATATYPE(find(strcmp(MODALITY,'T1w')),1) 	= {'anat'};
			DATATYPE(find(strcmp(MODALITY,'FLAIR')),1) 	= {'anat'};
			DATATYPE(find(strcmp(MODALITY,'asl')),1) 	= {'perf'};

			% Run
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			RUN(find(contains(SEQUENCE,{'repeat', 'repe', 'rpt','rep', 'repea'},'IgnoreCase',true)),1) = 2;

			for i = 1 : 9 												% support up to 9 runs
				forDICOM2BIDS_temp = table(	forDICOM2BIDS.SID,...
											forDICOM2BIDS.SCANDATE,...
											forDICOM2BIDS.VISCODE,...
											forDICOM2BIDS.SEQUENCE,...
											RUN);
				forDICOM2BIDS_temp.Properties.VariableNames = {'SID';'SCANDATE';'VISCODE';'SEQUENCE';'RUN'};
				[~, uniqIdx] = unique(forDICOM2BIDS_temp);
				RUN(setdiff(1:size(forDICOM2BIDS_temp,1), uniqIdx),1) = i+1;
			end

			RUN(find(strcmp(SEQUENCE,'Axial 3D PASL (Eyes Open) REPEAT')),1) = 1; 	% this happened once for 036_S_6316 in 2019-08-13. However, we cannot
																					% find another ASL on the same day therefore, we are not assigning
																					% 'run' entity although it said 'REPEAT'.
																					%
			RUN(find(strcmp(SEQUENCE,'Axial 3D PASL (Eyes Open) REPEAT')),1) = 2;	% 16Dec2022 : Run 1 does exist in DICOM, although not
																					%             documented in study data. Therefore,
																					%             resuming RUN = 2. Run 1 should be converted
																					%             in 'checkback' mode.


			% Acquisition
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			ACQUISITION(find(contains(SEQUENCE,'Axial 3D PASL',										'IgnoreCase',true)),1) = {'ax3dpasl'}; 
			ACQUISITION(find(contains(SEQUENCE,{'Ax 3D pCASL'; 'Axial 3D pCASL';'Axial_3D_pCASL'},	'IgnoreCase',true)),1) = {'ax3dpcasl'};
			ACQUISITION(find(contains(SEQUENCE,'Axial 2D PASL',										'IgnoreCase',true)),1) = {'ax2dpasl'};
			ACQUISITION(find(contains(SEQUENCE,'tgse_pcasl_PLD2000',								'IgnoreCase',true)),1) = {'tgsepcasl2000pld'}; 
			ACQUISITION(find(contains(SEQUENCE,'Cerebral Blood Flow',								'IgnoreCase',true)),1) = {'cbf'};
			ACQUISITION(find(contains(SEQUENCE,'Perfusion_Weighted',								'IgnoreCase',true)),1) = {'perfwei'}; 	% Note over 3000 perfusion-
																																			% weighted and relCBF cannot
																																			% find SID. Therefore, DICOM2BIDS
																																			% for these images is not able
																																			% to establish from study data.
																																			% This should be resolved in
																																			% 'checkback' mode to find
																																			% mapping based on existing
																																			% DICOM.

			ACQUISITION(find(contains(SEQUENCE, {	'MPRAGE'
													'MP RAGE'
													'MP-RAGE'}, 					'IgnoreCase', true)),1) = {'mprage'};

			ACQUISITION(find(contains(SEQUENCE, 	'IR-SPGR',						'IgnoreCase', true)),1) = {'irspgr'};

			ACQUISITION(find(contains(SEQUENCE, 	'IR-FSPGR',						'IgnoreCase', true)),1) = {'irfspgr'}; 	% keywords in SEQUENCE, such as '3D' and 'SAGITTAL'
																															% are not included in ACQUISITION for now.

			ACQUISITION(find(contains(SEQUENCE, {	'AX FLAIR'
													'AX T2 FLAIR'
													'AXIAL FLAIR'
													'AX_T2_FLAIR'
													'Axial T2 FLAIR'
													'Axial T2-FLAIR'
													'FLAIR AX'
													'FLAIR AXIAL'},					'IgnoreCase', true)),1) = {'ax'};
			
			ACQUISITION(find(contains(SEQUENCE, 	'Axial 3D FLAIR', 				'IgnoreCase', true)),1) = {'ax3d'};

			ACQUISITION(find(contains(SEQUENCE,	{	'Sagittal 3D FLAIR'
													'Sagittal_3D_FLAIR'
													'Sagittal 3D 0 angle FLAIR'}, 	'IgnoreCase', true)),1) = {'sag3d'};

			ACQUISITION(find(contains(SEQUENCE,		'Sagittal 3D FLAIR_MPR',		'IgnoreCase', true)),1) = {'sag3dmpr'};

			ACQUISITION(find(contains(SEQUENCE,		't2_flair SAG',					'IgnoreCase', true)),1) = {'sag'};


			DICOM2BIDS = table (SUBJECT,SESSION,DATATYPE,MODALITY,RUN,ACQUISITION,SEQUENCE,PATIENTID,STUDYDATE,IMAGEUID,DICOMSUBDIR);


			fprintf ('%s : ADNI DICOM2BIDS mapping has been created.\n', mfilename);

			fprintf ('%s : Saving ADNI DICOM2BIDS to %s ... ', mfilename, output);

			save (output, 'DICOM2BIDS', '-append');

			fprintf ('DONE!\n');

			varargout{1} = DICOM2BIDS;




		case {'retrieve'; 'retrieve_mapping'}

			ADNI_mat = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			
			fprintf ('%s : Running in ''retrieve'' mode.\n', mfilename);
			fprintf ('%s : Loading %s ... ', mfilename, ADNI_mat);

			varargout{1} = load(ADNI_mat).DICOM2BIDS;

			fprintf ('DONE!\n');




		case {'dcm2niix'; 'run_dcm2niix'}

			if nargin == 2 && isfile (varargin{1}) && endsWith(varargin{1},'.mat')
				ADNI_mat = varargin{1};
			else
				ADNI_mat = fullfile(BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			DCM2NIIX = load(ADNI_mat).DCM2NIIX;
			DCM2NIIX.CMD_OUT = cell(size(DCM2NIIX.CMD));
			DCM2NIIX.CMD_OUT(:,1) = {'UNKNOWN'};
			DCM2NIIX.CMD_STATUS = cell(size(DCM2NIIX.CMD));
			DCM2NIIX.CMD_STATUS(:,1) = {'UNKNOWN'};
			DCM2NIIX.CMD_WARNINGS = cell(size(DCM2NIIX.CMD));
			DCM2NIIX.CMD_WARNINGS(:,1) = {'NONE'};
			DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS = cell(size(DCM2NIIX.CMD));
			DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS(:,1) = {'UNKNOWN'};
			

			for i = 1 : size(DCM2NIIX.CMD,1)

				if ~ isfolder (DCM2NIIX.BIDS_OUTPUT_DIR{i,1})

					status = mkdir (DCM2NIIX.BIDS_OUTPUT_DIR{i,1});

					if ~ status

						DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Fail';

						fprintf(2, '%s : Creating BIDS directory ''%s'' failed. This may be because you don''t have the BIDS directory in bmp_ADNI.mat. You may need to run bmp_BIDSgenerator with proper BIDS_directory argument.\n', mfilename, DCM2NIIX.BIDS_OUTPUT_DIR{i,1});

						continue

					else

						DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Success';

					end

				else

					DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Exist';

				end

				if strcmp (DCM2NIIX.TO_CONVERT{i,1}, 'Yes')

					[~, curr_imageuidfoldername] = fileparts (DCM2NIIX.DICOM_INPUT_DIR{i,1});

					fprintf ('%s : (%d / %d) : Running dcm2niix to convert ''%s'' to ''%s''.nii ... ', ...
									mfilename, i, size (DCM2NIIX.CMD,1), curr_imageuidfoldername, DCM2NIIX.BIDS_NII_NAME{i,1});

					[DCM2NIIX.CMD_STATUS{i,1}, DCM2NIIX.CMD_OUT{i,1}] = system (DCM2NIIX.CMD{i,1});

					if contains (DCM2NIIX.CMD_OUT{i,1}, 'warning', 'IgnoreCase', true)

						DCM2NIIX.CMD_WARNINGS{i,1} = DCM2NIIX.CMD_OUT{i,1};

					end

					fprintf (' DONE!\n');

				end

			end

			fprintf('%s : Saving dcm2niix commands and command outputs to bmp_ADNI.mat.\n', mfilename);

			save (ADNI_mat, 'DCM2NIIX', '-append');

			varargout{1} = DCM2NIIX;



		case {'refresh'; 'refresh_mat_file'} % refresh mode is for internal testing.

			[~,~,~,~] = bmp_ADNI ('initiate'); % call bmp_ADNI_studyData.m to process ADNI study data.

			DICOM2BIDS = bmp_ADNI ('create'); % create DICOM2BIDS

			DCM2NIIX = bmp_BIDSgenerator ('ADNI', DICOM2BIDS, varargin{1}, varargin{2});

			%% not running dcm2niix in refresh mode.

			varargout{1} = DCM2NIIX;



		case {'prepare'} % prepare for real run

			DICOM2BIDS = bmp_ADNI ('retrieve');

			DCM2NIIX = bmp_BIDSgenerator ('ADNI', DICOM2BIDS, varargin{1}, varargin{2}, 'MatOutDir', fullfile (varargin{2}, 'code', 'BMP'));

			varargout{1} = DCM2NIIX;


		case {'checkback'} 	% using info from MRI scans (e.g., ???_S_???? IDs) and comparing with info
							% in MRI_master table in bmp_ADNI.mat, in order to try to savage some of
							% the scans.

	end

end
	
