% function bmp_BIDS (dataset, operation);
%
% OPERATION MODES
% =========================================================================
%
%   'refresh' mode
%   ++++++++++++++
%   This mode is for generating DICOM2BIDS mappings and dcm2niix commands
%   and saving to BMP_PATH/BIDS. DICOM2BIDS is loaded when preparing for
%   running on real data. dcm2niix commands are mainly for internal testing.
%   This mode is used mostly for internal testing, and refreshing
%   DICOM2BIDS when a new bmp_ADNI_forDicom2BidsMapping.mat is created.
%
%
%  'prepare' mode
%  ++++++++++++++
%  This is the mode you should start with to converting real ADNI DICOM
%  data to BIDS. It prepares BIDS folder, load DICOM2BIDS mappings, and
%  prepare dcm2niix commands with real DICOM/BIDS paths. The prepared
%  dcm2niix commands are saved in 
%  /path/to/BIDS/code/BMP/bmp_ADNI_dcm2niix.mat.
%
%
%  'run' mode
%  ++++++++++
%  This mode runs dcm2niix to convert DICOM to BIDS, using the commands
%  prepared in 'prepare' mode (/path/to/BIDS/code/BMP/bmp_ADNI_dcm2niix.mat).
%

dataset = 'ADNI';

operation = 'run'; % 'refresh', 'prepare', 'run', 

% TP-W530
DICOM_directory  = '/sandbox/adni_examples/dicom';
BIDS_directory = '/sandbox/adni_examples/bids';


% MacBook
% DICOM_directory  = '/Users/z3402744/Work/ADNI_test';
% BIDS_directory   = '/Users/z3402744/Work/ADNI_test/BIDS';

switch dataset

	case 'ADNI'

		switch operation

			case 'refresh'

				bmp_ADNI ('refresh', DICOM_directory, BIDS_directory);

			case 'prepare'

				bmp_BIDSinitiator (BIDS_directory, 'ADNI');

				bmp_ADNI ('prepare', DICOM_directory, BIDS_directory);

			case 'run'

				dicom2niix = bmp_ADNI ('dcm2niix', fullfile (BIDS_directory, 'code', 'BMP', 'bmp_ADNI_dcm2niix.mat'));

				%% bmp_BIDSaslfixer to fix aslcontext.tsv and M0Type

		end

end