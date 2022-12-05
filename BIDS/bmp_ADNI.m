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
%     For ADNI ASL data, we considered 5 CSV files of study data downloaded from 
%     https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI
%
%       - MRILIST.csv
%       - UCSFASLQC.csv
%       - UCSFASLFS_11_02_15_V2.csv
%       - UCSFASLFSCBF_08_17_22.csv
%       - ADNIMERGE.csv
%
%     Refer to /path/to/BrainMRIpipelines/BIDS/ADNI_study_data/bmp_procADNIstudyData.m.
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in two modes:
%
%     'create'   mode : This mode is used to generate DICOM-to-BIDS mappings, and save
%                       the mappings in a .mat file. In this mode, pass 'create'
%                       to the argument 'operation_mode', and /path/to/save/XXX.mat
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
%
%     'retrieve' mode : This mode load the previously created .mat file to retrieve the 
%                       predefiend mappings. In this mode, pass 'retrieve'
%                       to the argument 'operation_mode', and /path/to/retrieve/XXX.mat 
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
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
%   05 December 2022 - first version.
%
%
% KNOWN ISSUES
% ====================================================================================

	BMP_PATH = getenv ('BMP_PATH');

	switch operation_mode

		case 'create'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''create'' mode. Will save DICOM2BIDS mapping to %s.\n',mfilename,output);

			fprintf ('%s : Loading bmp_ADNI_ASL_forDicom2BidsMapping.mat ... ', mfilename);

			ASL_mat = load (fullfile (BMP_PATH, 'BIDS', 'ADNI_study_data', 'bmp_ADNI_ASL_forDicom2BidsMapping.mat'));

			fprintf ('DONE!\n', mfilename);

			ADNI_ASL = ASL_mat.ADNI_ASL_forDicom2BidsMapping;

			fprintf ('%s : Start to create DICOM2BIDS mapping.\n', mfilename)

			for i = 1 : size (ADNI_ASL, 1)

				fprintf ('%s : Index %d of %d.\n', mfilename, i, size(ADNI_ASL,1));
				

				% subject label
				DICOM2BIDS(i).subject = ['sub-ADNI' erase(ADNI_ASL.SID{i,1}, '_')];
				
				% DICOM - ASL
				DICOM2BIDS(i).perf.asl.DICOM.SeriesDescription = 'Axial 3D PASL (Eyes Open)';
				DICOM2BIDS(i).perf.asl.DICOM.PatientID = ADNI_ASL.SID{i};
				DICOM2BIDS(i).perf.asl.DICOM.StudyDate = erase(char(ADNI_ASL.SCANDATE(i)),'-');

				% DICOM - T1w
				DICOM2BIDS(i).anat.T1w.DICOM.SeriesDescription = 'Accelerated Sagittal MPRAGE';
				DICOM2BIDS(i).anat.T1w.DICOM.PatientID = ADNI_ASL.SID{i};
				DICOM2BIDS(i).anat.T1w.DICOM.StudyDate = erase(char(ADNI_ASL.SCANDATE(i)),'-');

				% DICOM - FLAIR
				DICOM2BIDS(i).anat.FLAIR.DICOM.SeriesDescription = 'Sagittal 3D FLAIR';
				DICOM2BIDS(i).anat.FLAIR.DICOM.PatientID = ADNI_ASL.SID{i};
				DICOM2BIDS(i).anat.FLAIR.DICOM.StudyDate = erase(char(ADNI_ASL.SCANDATE(i)),'-');

				% BIDS - ASL
				DICOM2BIDS(i).perf.asl.BIDS.session = ADNI_ASL.VISCODE{i};

				% BIDS - T1w
				DICOM2BIDS(i).anat.T1w.BIDS.acquisition = 'acceleratedSagittalMPRAGE';
				DICOM2BIDS(i).anat.T1w.BIDS.session = ADNI_ASL.VISCODE{i};

				% BIDS - FLAIR
				DICOM2BIDS(i).anat.FLAIR.BIDS.acquisition = 'sagittal3DFLAIR';
				DICOM2BIDS(i).anat.FLAIR.BIDS.session = ADNI_ASL.VISCODE{i};


			end

			fprintf ('%s : DICOM2BIDS mapping has been created.\n', mfilename);

			fprintf ('%s : Saving DICOM2BIDS to %s ... ', mfilename, output);

			save (output, 'DICOM2BIDS');

			fprintf ('DONE!\n')


		case 'retrieve'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				predefined_mapping = varargin{1};
			else
				predefined_mapping = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''retrieve'' mode. Will retrieve DICOM2BIDS mapping from %s.\n',mfilename,predefined_mapping);

			fprintf ('%s : Loading %s ... ', mfilename, predefined_mapping);

			DICOM2BIDS = load(predefined_mapping).DICOM2BIDS;

			fprintf ('DONE!\n');
	end

end