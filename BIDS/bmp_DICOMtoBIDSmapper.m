function [mapping_level, DICOM2BIDS] = bmp_DICOMtoBIDSmapper (varargin)
%
% DESCRIPTION
% =================================================================================================
%
%   bmp_DICOMtoBIDSmapper generates DICOM-to-BIDS mappings. This is done by 1) passing, as 
%   arguments, a cell array of key DICOM fieldnames and a cell array of DICOM fieldvalues 
%   associated to them, or 2) passing the name of dataset which mapping has been preset. Curretly
%   available preset mappings include ADNI3.
%
%
% SUPPORTED MODALITIES
% ================================================================================================
%
%   T1w : supported keywords = 'MPRAGE', 'T1' (all case-insensitive)
%

	supported_datasets = 	{
							'ADNI3'
							};

	
	if nargin == 2

		fnam_arr = varargin{1};
		fval_arr = varargin{2};

		% Make guesses
		fprintf ('%s : Trying to suggest field(s) for DICOM-to-BIDS convertion.\n', mfilename);
		fprintf ('%s : ''SeriesDescription'' is prioritised from our experience.\n', mfilename);

		if any (strcmp (fnam_arr, 'SeriesDescription'))

			fprintf ('%s : ''SeriesDescription'' is found.\n', mfilename);

			fnam = 'SeriesDescription';

		elseif any (strcmp (fnam_arr, 'ProtocolName'))

			fprintf ('%s : ''SeriesDescription'' is not found. ''ProtocolName'' is found, and it is preferred after ''SeriesDescription''.\n', mfilename);

			fnam = 'ProtocolName';

		end

		fval = fval_arr{find (strcmp (fnam_arr, fnam)),1};

		
		% Assuming 'SeriesDescription' and 'ProtocolName' sharing the same keywords

		for i = 1 : size (fval,1)

			% guess T1w DICOM-to-BIDS mapping
			
			if contains (fval{i,1}, 'MPRAGE', IgnoreCase=true)

				fprintf ('%s : Substring ''MPRAGE'' (case-insensitive) exists in ''%s''. I guess this is T1w.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.T1w, 'fieldname') || isfield (criteria.T1w, 'fieldvalue')

					criteria.T1w.fieldname = fnam;
					criteria.T1w.fieldvalue = fval{i,1};

				else

					warning ('%s : ''MPRAGE'' (case-insensitive) has been found, which is thought to relate to T1w. However, it seems another criterion for T1w had already been found (''%s'' in field ''%s''). This criterion may have keyword ''T1'' (case-insensitive). Therefore, I am confused now. I''ll prefer keyword ''MPRAGE'' (case-insensitive).\n', mfilename, criteria.T1w.fieldvalue, criteria.T1w.fieldname);

					criteria.T1w.fieldname = fnam;
					criteria.T1w.fieldvalue = fval{i,1};

				end

			elseif contains (fval{i,1}, 'T1', IgnoreCase=true)

				fprintf ('%s : Substring ''T1'' (case-insensitive) exists in ''%s''. I guess this is T1w.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.T1w, 'fieldname') || isfield (criteria.T1w, 'fieldvalue')

					criteria.T1w.fieldname = fnam;
					criteria.T1w.fieldvalue = fval{i,1};

				else

					warning ('%s : ''T1'' (case-insensitive) has been found, which is thought to relate to T1w. However, it seems another criterion for T1w had already been found (''%s'' in field ''%s''). This criterion may have keyword ''MPRAGE'' (case-insensitive). Therefore, I am confused now. I''ll prefer keyword ''MPRAGE'' (case-insensitive).\n', mfilename, criteria.T1w.fieldvalue, criteria.T1w.fieldname);
				end

			end


			% guess FLAIR DICOM-to-BIDS mapping
			% +++++++++++++++++++++++++++++++++

		end



		% suggest DICOM2BIDS for bmp_BIDSgenerator
		fprintf ('%s : Making suggestions for DICOM-to-BIDS mapping for bmp_BIDSgenerator.\n', mfilename);
		fprintf ('%s : These suggestions may only work for dataset-level mapping.\n', mfilename);

		mapping_level = 'dataset';

		DICOM2BIDS.anat.T1w.DICOM.(criteria.T1w.fieldname) = criteria.T1w.fieldvalue;



	elseif nargin == 1 && any(strcmp(supported_datasets, varargin{1}))



	else

		error ('bmp_DICOMtoBIDSmapper:InvalidInputs',...
				'%s : Invalid inputs. Inputs should be 1) cell arrays of fieldnames and fieldvalues, or 2) name of supported datasets (e.g., ADNI3).');

	end

end