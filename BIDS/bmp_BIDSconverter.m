function bmp_BIDSconverter (varargin)
%
%
%
% BIDS_struct
%       |
%       |
%       --- modality --- datatype --- DICOM --- keyfields = values
%                           |
%                           |
%                           --------- BIDS --- keys = values
%
%
% REFERENCES:
%
%   https://bids-specification.readthedocs.io/en/stable/02-common-principles.html
%   https://bids-specification.readthedocs.io/en/stable/appendices/entities.html
%


	switch dataset

		case 'ADNI3'

			% DICOM (keyfields = values)
			BIDS_struct.anat.T1w.DICOM.SeriesDescription = 'Accelerated Sagittal MPRAGE';
			BIDS_struct.anat.FLAIR.DICOM.SeriesDescription = 'Sagittal 3D FLAIR';

			% BIDS (keys = values)
			BIDS_struct.anat.T1w.BIDS.acquisition = 'acceleratedSagittalMPRAGE';
			BIDS_struct.anat.FLAIR.BIDS.acquisition = 'sagittal3DFLAIR';


		    % Use 'fieldnames' function to access name of field.

		    % if BIDS_struct.anat.T1w.BIDS.session exist,
		    % then need to consider each session

	end

end