function varargout = bmp_VCI (operation_mode, varargin)
%
% DESCRIPTION
%
%   This script converts DICOM files acquired from the Siemens
%   Prisma scanner at Research Imaging NSW to BIDS-compatible
%   NIFTI files.
%
% ==============================================================
%                             USAGE
% ==============================================================
%
%   Initialise BMP_VCI
%   ------------------------
%   Initialise BMP_VCI, including running dicomCollection.
%
%   operation_mode = 'i' or 'initialise_BMP_VCI'
%
%   varargin{1} = DICOM directory.
%   varargin{2} = BIDS directory.
%
%   varargout{1} = BMP_VCI
%
%
%
%   Organise DICOM folder
%   ---------------------
%
%   operation_mode = 'o' or 'organise_dicom_dir'
%
%   varargin{1} = BMP_VCI
%
% ==============================================================
%                          HISTORY
% ==============================================================
%   

	BMP_TMP_PATH = getenv ('BMP_TMP_PATH');

	if isempty(BMP_TMP_PATH)
		BMP_TMP_PATH = pwd;	% if BMP_TMP_PATH is not set,
							% then use the current dir.
	end

	switch operation_mode

		case {'i';'initialise_BMP_VCI'}

			BMP_VCI = bmp_VCI_initialiseBmpVci (DICOM_directory, BIDS_directory);

			varargout{1} = BMP_VCI;


		case {'o';'organise_dicom_dir'}

			BMP_VCI = varargin{1};

			


		case {'gd2n';'generate_dcm2niix_cmd'}

			DICOM_parent_folder = fileparts (DICOM_directory);
			dicom_bmp_dir = dir (fullfile (DICOM_parent_folder,'DICOM_bmp'));

	end

end


