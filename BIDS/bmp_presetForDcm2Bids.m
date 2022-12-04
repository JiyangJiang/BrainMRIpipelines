function json = bmp_presetForDcm2Bids (dataset)
%
% ============================================================
% DESCRIPTION
% ============================================================
%   This script generates preset configuration json files for
%   a few public datasets and datasets at CHeBA. These files 
%   can then be used in BIDS converters, such as Dcm2Bids.
%
%   Currently supported datasets include :
%
%   - ADNI 3 (T1w, FLAIR, ASL)
%
% ============================================================
% USAGE
% ============================================================
%   json = bmp_presetForDcm2Bids (dataset)
%
% ============================================================
% ARGUMENTS
% ============================================================
%
%
% ============================================================
% OUTPUTS
% ============================================================
%   json : A structure of structures. Each sub-structure
%          contains information for modalities that have
%          the same fields. See 'KNOWN ISSUES' for details.
%
% ============================================================
% EXAMPLES
% ============================================================
%
%
% ============================================================
% DEPENDENCIES
% ============================================================
%
%
% ============================================================
% HISTORY
% ============================================================
%   01 Dec 2022 - first version.
%
% ============================================================
% KNOWN ISSUES
% ============================================================
%   - MATLAB requires structures to be of same size/fields 
%     for concatenation. Therefore, configuration json files 
%     need to be grouped for modalities with the same fields.
%

	switch dataset

		case 'ADNI3'

			json.asl = jsonencode ( struct("descriptions",  [...
															struct(	...
																	"dataType",       	"perf", ...
																	"modalityLabel",	"asl", ...
																	"customLabels",		"desc-raw", ...
																	"criteria",			struct ("SeriesDescription",	"Axial 3D PASL (Eyes Open)")...
																	); ...
															struct( ...
																	"dataType",			"perf", ...
																	"modalityLabel",	"asl", ...
																	"customLabels",		"desc-perfw", ...
																	"criteria",			struct ("SeriesDescription",	"Perfusion_Weighted")...
																	) ...
															]...
										), ...
									PrettyPrint=true);


			json.anat = jsonencode ( struct("descriptions",	[...
															struct( ...
																	"dataType",			"anat", ...
																	"modalityLabel",	"T1w", ...
																	"criteria",			struct ("SeriesDescription",	"Accelerated Sagittal MPRAGE")...
																	); ...
															struct( ...
																	"dataType",			"anat", ...
																	"modalityLabel",	"FLAIR", ...
																	"criteria",			struct ("SeriesDescription",	"Sagittal 3D FLAIR")...
																	)...
															]...
											), ...
									PrettyPrint=true);

	end
end

% bmp_prepConfig : Key field 'SeriesDescription' has 21 different value(s):
%   - 3 Plane Localizer
%   - ADNI3-BRAIN
%   - AV1451 Co-registered Dynamic
%   - AV1451 Co-registered, Averaged
%   - AV1451 Coreg, Avg, Standardized Image and Voxel Size
%   - AV1451 Coreg, Avg, Std Img and Vox Siz, Uniform 6mm Res
%   - AV1451 Coreg, Avg, Std Img and Vox Siz, Uniform Resolution
%   - Accelerated Sagittal MPRAGE
%   - Axial 3D PASL (Eyes Open)
%   - Axial 3TE T2 STAR
%   - Axial MB DTI
%   - Axial MB rsfMRI (Eyes Open)
%   - FBB Co-registered Dynamic
%   - FBB Co-registered, Averaged
%   - FBB Coreg, Avg, Standardized Image and Voxel Size
%   - FBB Coreg, Avg, Std Img and Vox Siz, Uniform 6mm Res
%   - FBB Coreg, Avg, Std Img and Vox Siz, Uniform Resolution
%   - Field Mapping
%   - HighResHippocampus
%   - Perfusion_Weighted
%   - Sagittal 3D FLAIR