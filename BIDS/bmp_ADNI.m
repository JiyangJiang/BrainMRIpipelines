function DICOM2BIDS = bmp_ADNI (operation_mode, varargin)
%
% DESCRIPTION
% ====================================================================================
%
%   bmp_ADNI aims to generate DICOM-to-BIDS mappings for ADNI dataset. It is called
%   by bmp_DICOMtoBIDSmapper if predefined dataset 'ADNI' is specified. Results of
%   bmp_ADNI can be directly used in bmp_BIDSgenerator. Details on the structure of
%   DICOM-to-BIDS mappings can be found in the header of bmp_BIDSgenerator.m, or by
%   typing 'help bmp_BIDSgenerator' in MATLAB Command Window.
%
%   Note that since ADNI dataset has multiple sessions (i.e., timepoints) and subject
%   ID and scan date need to be used to identify session label, we specify ADNI
%   DICOM-to-BIDS mappings in individual-level.
%
%
% EVIDENCE TO CREATE MAPPINGS
% ====================================================================================
%
%   ASL
%
%     For ADNI ASL data, we considered 4 CSV files of study data downloaded from 
%     https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI
%
%       - MRILIST.csv
%       - UCSFASLFS_11_02_15_V2.csv
%       - UCSFASLFSCBF_08_17_22.csv
%       - UCSFASLQC.csv
%
%     For details, refer to /path/to/BrainMRIpipelines/BIDS/ADNI/bmp_ADNI_ASL.m.
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in two modes:
%
%     'create'   mode : This mode is used to generate DICOM-to-BIDS mappings, and save
%                       the mappings in a ADNI.mat file. In this mode, pass 'create'
%                       to the argument 'operation_mode', and /path/to/save/ADNI.mat to
%                       varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/ADNI.mat will be used.
%
%     'retrieve' mode : This mode load the previously created ADNI.mat file to 
%                       retrieve the predefiend mappings. In this mode, pass 'retrieve'
%                       to the argument 'operation_mode', and /path/to/retrieve/ADNI.mat 
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/ADNI.mat will be used.
%
%
% SUPPORTED MODALITIES
% ====================================================================================
%
%   - asl
%
%
% HISTORY
% ====================================================================================
%
%   04 December 2022 - first version.
%
%
% KNOWN ISSUES
% ====================================================================================

	BMP_PATH = getenv ('BMP_PATH');

	switch operation_mode

		case 'create'

			if nargin == 2
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'ADNI.mat');
			end

			ADNI_ASL = load (fullfile (BMP_PATH, 'BIDS', 'ADNI_study_data', 'bmp_ADNI_ASL.mat'));

			for i = 1 : size (ADNI_ASL.ADNI_ASL_table, 1)

				% for sujects with complete SID, SCANDATE, and VISCODE info,
				% and VISCODE is not 'sc' or 'scmri'.
				if ~strcmp(ADNI_ASL.ADNI_ASL_table.('SID'){i,1}, 'UNKNOWN') && ...
					~strcmp(ADNI_ASL.ADNI_ASL_table.('SCANDATE'){i,1}, 'UNKNOWN') && ...
					 ~strcmp(ADNI_ASL.ADNI_ASL_table.('VISCODE'){i,1}, 'UNKNOWN') && ...
					  ~strcmp(ADNI_ASL.ADNI_ASL_table.('VISCODE'){i,1}, 'sc') && ...
					   ~strcmp(ADNI_ASL.ADNI_ASL_table.('VISCODE'){i,1}, 'scmri')

					% subject label
					DICOM2BIDS(i).subject = ['sub-ADNI' erase(ADNI_ASL.ADNI_ASL_table.('SID'){i,1}, '_')];
					
					% DICOM criteria
					DICOM2BIDS(i).perf.asl.DICOM.SeriesDescription = 'Axial 3D PASL (Eyes Open)';
					DICOM2BIDS(i).perf.asl.DICOM.PatientID = ADNI_ASL.ADNI_ASL_table.('SID'){i,1};
					DICOM2BIDS(i).perf.asl.DICOM.StudyDate = ADNI_ASL.ADNI_ASL_table.('SCANDATE'){i,1};

					% BIDS
					DICOM2BIDS(i).perf.asl.BIDS.session = ADNI_ASL.ADNI_ASL_table.('VISCODE'){i,1};


				else
					
					% ++++++++++++++++++++++++++++
					% TO-DO :
					% ++++++++++++++++++++++++++++
					% 1) if not complete data.
					% 2) what to do with sc/scmri?

					% subject label
					DICOM2BIDS(i).subject = 'placeholder';
					
					% DICOM criteria
					DICOM2BIDS(i).perf.asl.DICOM.SeriesDescription = 'placeholder';
					DICOM2BIDS(i).perf.asl.DICOM.PatientID = 'placeholder';
					DICOM2BIDS(i).perf.asl.DICOM.StudyDate = 'placeholder';

					% BIDS
					DICOM2BIDS(i).perf.asl.BIDS.session = 'placeholder';

				end

			end

	end

end