function bmp_BIDS (dataset, operation_mode, DICOM_directory, BIDS_directory);
%
% DESCRIPTION
% =========================================================================
%
% This is the master command for the BIDS module in BMP.
%
%
%
% OPERATION MODES
% =========================================================================
%
%   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                           --== INTERNAL USE ==--
%   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%   'refresh' mode
%   ++++++++++++++
%   This mode is for generating DICOM2BIDS mappings and dcm2niix commands.
%   This mode is used mostly for internal testing, and refreshing
%   bmp_ADNI.mat when bmp_ADNI_studyData.m is updated.
%
%
%
%   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                   --== EXTERNAL USERS START FROM HERE ==--
%   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%   'prepare' mode
%   ++++++++++++++
%   This is the mode external users should start with to converting real 
%   ADNI DICOM data to BIDS. It prepares BIDS folder, load DICOM2BIDS 
%   mappings, and prepare dcm2niix commands with real DICOM/BIDS paths. 
%   The prepared dcm2niix commands are saved in 
%   /path/to/BIDS/code/BMP/bmp_ADNI.mat.
% 
% 
%   'run' mode
%   ++++++++++
%   This mode runs dcm2niix to convert DICOM to BIDS, using the commands
%   prepared in 'prepare' mode (/path/to/BIDS/code/BMP/bmp_ADNI.mat).
%
%
%
% HISTORY
% =========================================================================
%
% - 19 Dec 2022 : First version.
%
%

dataset = 'ADNI';

operation_mode = 'run'; % 'refresh', 'prepare', 'run', 

% TP-W530
DICOM_directory  = '/sandbox/adni_examples/dicom';
BIDS_directory = '/sandbox/adni_examples/bids';


% MacBook
% DICOM_directory  = '/Users/z3402744/Work/ADNI_test';
% BIDS_directory   = '/Users/z3402744/Work/ADNI_test/BIDS';

switch dataset

	case 'ADNI'

		switch operation_mode

			case 'refresh'

				bmp_ADNI ('refresh', DICOM_directory, BIDS_directory);

			case 'prepare'

				bmp_BIDSinitiator (BIDS_directory, 'ADNI');

				DCM2NIIX = bmp_ADNI ('prepare', DICOM_directory, BIDS_directory);

			case 'run'

				DCM2NIIX = bmp_ADNI ('dcm2niix', fullfile (BIDS_directory, 'code', 'BMP', 'bmp_ADNI.mat'));

		end

	case 'other'

end