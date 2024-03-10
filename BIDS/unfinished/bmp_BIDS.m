function varargout = bmp_BIDS (dataset, operation_mode, DICOM_directory, BIDS_directory);
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
%   +++++++++++++++++++++++++++++++
%   This is the mode external users should start with to converting real 
%   ADNI DICOM data to BIDS. It prepares BIDS folder, load DICOM2BIDS 
%   mappings, and prepare dcm2niix commands with real DICOM/BIDS paths. 
%   The prepared dcm2niix commands are saved in 
%   /path/to/BIDS/code/BMP/bmp_ADNI.mat.
% 
% 
%   'run' mode
%   +++++++++++++++++++++++++++++++
%   This mode runs dcm2niix to convert DICOM to BIDS, using the commands
%   prepared in 'prepare' mode (/path/to/BIDS/code/BMP/bmp_ADNI.mat).
%
%
%   'clinica_prepare' mode
%   +++++++++++++++++++++++++++++++
%   Prepare dcm2niix commands (for ASL) using Clinica info, and save to
%   /path/to/BIDS/code/BMP/bmp_ADNI.mat.
%
%
%   'clinica_run' mode
%   +++++++++++++++++++++++++++++++
%   Run dcm2niix commands prepared in 'clinica_prepare' mode.
%
%
% HISTORY
% =========================================================================
%
% - 19 Dec 2022 : First version.
%
% - 23 Dec 2022 : 'clinica_prepare' and 'clinica_run' modes.
%
%


% TP-W530
% DICOM_directory  = '/sandbox/adni_examples/dicom';
% BIDS_directory = '/sandbox/adni_examples/bids';


% MacBook
% DICOM_directory  = '/Users/z3402744/Work/ADNI_test';
% BIDS_directory   = '/Users/z3402744/Work/ADNI_test/BIDS';
% CLINICA_ASL = bmp_BIDS('ADNI','clinica_prepare',DICOM_directory,BIDS_directory)



switch dataset

	case 'ADNI'

		switch operation_mode

			case 'refresh' % internal use : update embedded bmp_ADNI.mat

				bmp_ADNI ('refresh', DICOM_directory, BIDS_directory);

			case 'prepare' % prepare dcm2niix commands according to real DICOM/BIDS directories

				DCM2NIIX = bmp_ADNI ('prepare', DICOM_directory, BIDS_directory);

				varargout{1} = DCM2NIIX;

			case 'run' % run dcm2niix conversion

				DCM2NIIX = bmp_ADNI ('dcm2niix', fullfile (BIDS_directory, 'code', 'BMP', 'bmp_ADNI.mat'));

				varargout{1} = DCM2NIIX;

			case 'clinica_prepare' % prepare dcm2niix commands according to information in Clinica tsv files.

				CLINICA_ASL = bmp_ADNI ('clinica', DICOM_directory, BIDS_directory);

				varargout{1} = CLINICA_ASL;

			case 'clinica_run' % run dcm2niix conversion for clinica_prepare'ed commands.

				CLINICA_ASL = bmp_ADNI ('dcm2niix_clinica', BIDS_directory);

				varargout{1} = CLINICA_ASL;

		end

	case 'other'

end