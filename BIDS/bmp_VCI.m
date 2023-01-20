function varargout = bmp_VCI (operation_mode, DICOM_directory, varargin)
%
% DESCRIPTION
%
%   This script converts DICOM files acquired from the Siemens
%   Prisma scanner at Research Imaging NSW to BIDS-compatible
%   NIFTI files.
%
% ==============================================================
% USAGE
% ==============================================================
%
%   Run dicomCollection only
%   ------------------------
%   Running dicomCollection requires time and memory. This mode
%   can run dicomCollection only and save as a MAT file.
%
%
%   Organise DICOM folder
%   ---------------------
%   varargin{1} = MAT file with dicomCollection output table. 
%                 MAT file should have a table named 'dcm_coll' 
%                 which is output from dicomCollection.
%
%                 OR
%
%                 The table output from dicomCollection.
%
% HISTORY
%   

	BMP_TMP_PATH = getenv ('BMP_TMP_PATH');

	if isempty(BMP_TMP_PATH)
		BMP_TMP_PATH = pwd;	% if BMP_TMP_PATH is not set,
							% then use the current dir.
	end

	switch operation_mode

		case {'dc';'run_dicomCollection_only'}

			dcm_coll = dicomCollection (DICOM_directory, "IncludeSubfolders", true); 	% Note that DICOM folder is used
																						% as input, instead of DICOMDIR
																						% file. This is because output
																						% from dicomCollection with DICOMDIR
																						% will miss some series.

			varargout{1} = dcm_coll;
																							
			save (fullfile (BMP_TMP_PATH,'vci_dcm_coll.mat'), 'dcm_coll'); 	% save dicomCollection output because
																			% dicomCollection takes time.
																			% Running this on GRID is faster.

		case {'o';'organise_dicom_dir'}

			% if any part of path to DICOM files need to be replaced
			% this is useful if dicomCollection was ran on different machine with different paths
			% Can be left as empty if not replacing anyting.
			str_toBeReplaced = 'jiyang';
			str_replaceTo    = 'brain';

			DICOM_parent_folder = fileparts (DICOM_directory);

			modalities = {
							'T1'
							'T2'
							'FLAIR'
						};

			if nargin == 2
				dcm_coll = load (fullfile (BMP_TMP_PATH,'vci_dcm_coll.mat')).dcm_coll;
			elseif nargin == 3 && ischar(varargin{1}) && isfile (varargin{1})
				dcm_coll = load (varargin{1}).dcm_coll;
			elseif nargin == 3 && istable (varargin{1})
				dcm_coll = varargin{1};
			end

			% for i = 1 : length(modalities)
			% 	orgniseDICOMdir (dcm_coll, DICOM_parent_folder, modalities{i,1}, str_toBeReplaced, str_replaceTo);
			% end	

			orgniseDICOMdir_dwi	(dcm_coll, DICOM_parent_folder, str_toBeReplaced, str_replaceTo);

	end

end


function orgniseDICOMdir (dcm_coll, DICOM_parent_folder, modality, str_toBeReplaced, str_replaceTo)

	switch modality

		case 'T1'

			series_description_keyword = 'T1_MPRAGE_0.8_iso';

		case 'T2'

			series_description_keyword = 'T2_spc_sag_0.8mm';

		case 'FLAIR'

			series_description_keyword = 't2_space_dark-fluid_sag_p2_ns-t2prep';

	end


	fprintf ('%s : Start organising %s DICOM directory. We assume all %s sequences have keyword of ''%s''.\n', mfilename, modality, modality, series_description_keyword);

	curr_dcmCollection_subtable = dcm_coll(find(contains(dcm_coll.SeriesDescription,series_description_keyword,'IgnoreCase',true)),:);
	
	fprintf ('%s : %d entries found in the dicomCollection table with keyword ''%s''. Series description includes: \n', mfilename, size (curr_dcmCollection_subtable,1), series_description_keyword);

	for i = 1 : size(curr_dcmCollection_subtable,1)
		fprintf ('  >>> %s\n', curr_dcmCollection_subtable.SeriesDescription{i});
	end

	for i = 1 : size(curr_dcmCollection_subtable,1)

		fprintf ('%s : Now dealing with SeriesDescription = ''%s''.\n', mfilename, curr_dcmCollection_subtable.SeriesDescription{i});

		DICOM_bmp_path = fullfile (DICOM_parent_folder, 'DICOM_bmp', strrep(curr_dcmCollection_subtable.SeriesDescription{i},' ','_'));

		if ~isfolder (DICOM_bmp_path)

			fprintf ('%s : %s folder doesn''t exist. Creating ... ', mfilename, DICOM_bmp_path);
			mkdir (DICOM_bmp_path);
			fprintf ('DONE!\n');

		else

			fprintf ('%s : %s folder exists.\n', mfilename, DICOM_bmp_path);

		end

		filenames_for_curr_seq = strrep(curr_dcmCollection_subtable.Filenames{i}, str_toBeReplaced, str_replaceTo); 

		fprintf ('%s : Copying DICOM files for %s (N = %d) to %s ... ', mfilename, curr_dcmCollection_subtable.SeriesDescription{i}, size (filenames_for_curr_seq,1), DICOM_bmp_path);

		for j = 1 : size (filenames_for_curr_seq,1)

			[status,message,messageId] = copyfile (filenames_for_curr_seq(j,1), DICOM_bmp_path);

			if ~status
				fprintf ('%s : [WARNING] : %s\n', mfilename, message);
			end

		end

		fprintf ('DONE!\n');

	end

end


function orgniseDICOMdir_dwi (dcm_coll, DICOM_parent_folder, str_toBeReplaced, str_replaceTo)

	fprintf ('%s : Start organising dMRI DICOM directory. We assume all dMRI sequences have keyword of ''DIFFUSION''.\n', mfilename);

	dwi_dcmCollection_subtable = dcm_coll(find(contains(dcm_coll.SeriesDescription,'DIFFUSION','IgnoreCase',true)),:);

	dwi_dcmCollection_SeriesDescUniqueVal = unique(dwi_dcmCollection_subtable.SeriesDescription);
	
	fprintf ('%s : %d entries found in the dicomCollection table with keyword ''DIFFUSION''. Series description includes: \n', mfilename, length(dwi_dcmCollection_SeriesDescUniqueVal));

	for i = 1 : length(dwi_dcmCollection_SeriesDescUniqueVal)
		fprintf ('  >>> %s\n', dwi_dcmCollection_SeriesDescUniqueVal(i));
	end

	% for i = 1 : size(dwi_dcmCollection_subtable,1)

	% 	fprintf ('%s : Now dealing with SeriesDescription = ''%s''.\n', mfilename, dwi_dcmCollection_subtable.SeriesDescription{i});

	% 	DICOM_bmp_path = fullfile (DICOM_parent_folder, 'DICOM_bmp', strrep(dwi_dcmCollection_subtable.SeriesDescription{i},' ','_'));

	% 	if ~isfolder (DICOM_bmp_path)

	% 		fprintf ('%s : %s folder doesn''t exist. Creating ... ', mfilename, DICOM_bmp_path);
	% 		mkdir (DICOM_bmp_path);
	% 		fprintf ('DONE!\n');

	% 	else

	% 		fprintf ('%s : %s folder exists.\n', mfilename, DICOM_bmp_path);

	% 	end

	% 	filenames_for_curr_seq = strrep(dwi_dcmCollection_subtable.Filenames{i}, str_toBeReplaced, str_replaceTo); 

	% 	fprintf ('%s : Copying DICOM files for %s (N = %d) to %s ... ', mfilename, dwi_dcmCollection_subtable.SeriesDescription{i}, size (filenames_for_curr_seq,1), DICOM_bmp_path);

	% 	for j = 1 : size (filenames_for_curr_seq,1)

	% 		[status,message,messageId] = copyfile (filenames_for_curr_seq(j,1), DICOM_bmp_path);

	% 		if ~status
	% 			fprintf ('%s : [WARNING] : %s\n', mfilename, message);
	% 		end

	% 	end

	% 	fprintf ('DONE!\n');

	% end

end