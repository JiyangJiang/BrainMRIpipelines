function bmp_BIDSgenerator (varargin)
%
% DESCRIPTION
% ======================================================================================
%   BrainMRIpipelines BIDS converter (bmp_BIDSgenerator) aims to convert DICOM files to 
%   NIFTI files and store them in BIDS folder structure with BIDS-compliant filenames.
%
%
% MAPPING TYPES
% ======================================================================================
%   There are 3 types of mapping
%
%   - Individual-level mapping : Specify criteria for each individual. For example, 
%                                in ADNI, session labels can only be mapped through 
%                                looking at scan date and/or patient name.
%
%   - Dataset-level mapping : All subjects in the dataset share the same criteria 
%                             for a modality.
%
%   - Subgroup-level mapping : A sub-group in the dataset shares a set of criteria.
%
%
%
% CONSTRUCTING MAPPING
% ======================================================================================
%   The DICOM-to-BIDS mapping is through constructing a MATLAB structure (DICOM2BIDS). 
%   Illustration of the structure is below:
% 
%                  DICOM2BIDS
%                   /     \
%                  /       \
%             subject     datatype --- modality --- DICOM --- keyfields (= values)
%  (if individual-level)                  |
%                                         |
%                                         --------- BIDS ---- keys (= values)
%
%
%   An example of individual-level DICOM-to-BIDS mapping:
%
%     % DICOM (keyfields = values)
%	  DICOM2BIDS(1).subject = 'sub-128S0272'
%	  DICOM2BIDS(1).anat.T1w.DICOM.SeriesDescription = 'Accelerated Sagittal MPRAGE';
%	  DICOM2BIDS(1).anat.FLAIR.DICOM.SeriesDescription = 'Sagittal 3D FLAIR';
%
%	  % BIDS (keys = values) (this BIDS field is optional)
%	  DICOM2BIDS(1).anat.T1w.BIDS.acquisition = 'acceleratedSagittalMPRAGE';
%	  DICOM2BIDS(1).anat.FLAIR.BIDS.acquisition = 'sagittal3DFLAIR';
%
%
%   DICOM2BIDS can be derived from calling bmp_DICOMenquirer and bmp_DICOMtoBIDSmapper, 
%   or through creating one by yourself.
%
% REFERENCES:
% ======================================================================================
%   https://bids-specification.readthedocs.io/en/stable/02-common-principles.html
%   https://bids-specification.readthedocs.io/en/stable/appendices/entities.html
%


	switch dataset

		case 'ADNI3'

			% DICOM (keyfields = values)
			DICOM2BIDS.subject = 'sub-128S0272'
			DICOM2BIDS.anat.T1w.DICOM.SeriesDescription = 'Accelerated Sagittal MPRAGE';
			DICOM2BIDS.anat.FLAIR.DICOM.SeriesDescription = 'Sagittal 3D FLAIR';

			% BIDS (keys = values)
			DICOM2BIDS.anat.T1w.BIDS.acquisition = 'acceleratedSagittalMPRAGE';
			DICOM2BIDS.anat.FLAIR.BIDS.acquisition = 'sagittal3DFLAIR';


		    % Use 'fieldnames' function to access name of field.

		    % if DICOM2BIDS.anat.T1w.BIDS.session exist,
		    % then need to consider each session

	end

end