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
%   varargin{1} = MAT file containing dicomCollection output table. 
%                 Table should have the name 'dcm_coll'.
%
%                 OR
%
%                 The dicomCollection output table.
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

			BMP_VCI.BIDS.modalities = {
										'T1'
										'T2'
										'FLAIR'
										'SWI'
										'DTI'
										'ASL'
										'CVR_fmap'
										'CVR'
										'MP2RAGE'
										'DCE'
									};

			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.t1 = 'T1_MPRAGE_0.8_iso';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.t2 = 'T2_spc_sag_0.8mm';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.flair = 't2_space_dark-fluid_sag_p2_ns-t2prep';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.swi = 'greME7_p31_256_Iso1mm';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dti = 'DIFFUSION';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.asl = 'asl_3d_tra_p2_iso_3mm_highres';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr_fmap = 'gre_field_mapping 3.8mm';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr = 'CVR_ep2d_bold 3.8mm TR1500 adaptive';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.mp2rage = 't1_mp2rage_sag_0.8x0.8x2';
			BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dce = 't1_vibe_sag_DCE_2mm XL FOV 40s temporal res';

			BMP_VCI.BIDS.DICOM_directory = varargin{1};

			BMP_VCI.BIDS.dicomCollection = dicomCollection (DICOM_directory, "IncludeSubfolders", true); 	% Note that DICOM folder is used
																											% as input, instead of DICOMDIR
																											% file. This is because output
																											% from dicomCollection with DICOMDIR
																											% will miss some series.

			varargout{1} = BMP_VCI;


		case {'o';'organise_dicom_dir'}

			BMP_VCI = varargin{1};

			% if any part of path to DICOM files need to be replaced
			% this is useful if dicomCollection was ran on different machine with different paths
			% Can be left as empty if not replacing anyting.
			str_toBeReplaced = 'jiyang';
			str_replaceTo    = 'brain';

			DICOM_parent_folder = fileparts (BMP_VCI.BIDS.DICOM_directory);
			dcm_coll = BMP_VCI.BIDS.dicomCollection;
			modalities = BMP_VCI.BIDS.modalities;

			for i = 1 : length(modalities)

				modality = modalities{i,1};

				switch modality
					case 'T1'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.t1;
					case 'T2'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.t2;
					case 'FLAIR'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.flair;
					case 'SWI'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.swi;
					case 'DTI'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dti;
					case 'ASL'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.asl;
					case 'CVR_fmap'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr_fmap;
					case 'CVR'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr;
					case 'MP2RAGE'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.mp2rage;
					case 'DCE'
						series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dce;
				end

				fprintf ('%s : Start organising %s DICOM directory. We assume all %s sequences have keyword of ''%s''.\n', mfilename, modality, modality, series_description_keyword);

				curr_dcmCollection_subtable = dcm_coll(find(contains(dcm_coll.SeriesDescription, series_description_keyword, 'IgnoreCase', true)),:);

				curr_dcmCollection_SeriesDescUniqueVal = unique(curr_dcmCollection_subtable.SeriesDescription);
				
				fprintf ('%s : %d entries found in the dicomCollection table with keyword ''%s''. Unique SeriesDescription values include: \n', mfilename, length(curr_dcmCollection_SeriesDescUniqueVal), series_description_keyword);

				for i = 1 : length(curr_dcmCollection_SeriesDescUniqueVal)
					fprintf ('  >>> %s\n', curr_dcmCollection_SeriesDescUniqueVal(i));
				end

				for i = 1 : size(curr_dcmCollection_SeriesDescUniqueVal,1)

					fprintf ('%s : Now dealing with SeriesDescription = ''%s''.\n', mfilename, curr_dcmCollection_SeriesDescUniqueVal(i));

					curr_dcmCollection_subtable_currSeriesDescSubTable = curr_dcmCollection_subtable(find(strcmp(curr_dcmCollection_subtable.SeriesDescription, curr_dcmCollection_SeriesDescUniqueVal(i))),:);

					for j = 1 : size (curr_dcmCollection_subtable_currSeriesDescSubTable,1)

						fprintf ('%s : Current SeriesDescription = %s; SeriesInstanceUID = %s.\n', mfilename, curr_dcmCollection_SeriesDescUniqueVal(i), curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j});

						DICOM_bmp_path = fullfile (DICOM_parent_folder, 'DICOM_bmp', strrep(curr_dcmCollection_SeriesDescUniqueVal(i),' ','_'), curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j});

						if ~isfolder (DICOM_bmp_path)

							fprintf ('%s : %s folder doesn''t exist. Creating ... ', mfilename, DICOM_bmp_path);
							mkdir (DICOM_bmp_path);
							fprintf ('DONE!\n');

						else

							fprintf ('%s : %s folder exists.\n', mfilename, DICOM_bmp_path);

						end

						filenames_for_curr_seq = strrep(curr_dcmCollection_subtable_currSeriesDescSubTable.Filenames{j}, str_toBeReplaced, str_replaceTo); 

						fprintf ('%s : Copying ''SeriesDescription=%s'' DICOM files ''SeriesInstanceUID=%s'' (N = %d) ... ', mfilename, curr_dcmCollection_SeriesDescUniqueVal(i), curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j}, size (filenames_for_curr_seq,1));

						for k = 1 : size (filenames_for_curr_seq,1)

							[status,message,messageId] = copyfile (filenames_for_curr_seq(k,1), DICOM_bmp_path);

							if ~status
								fprintf ('%s : [WARNING] : %s\n', mfilename, message);
							end

						end

						fprintf ('DONE!\n');

					end

				end
			end	


		case {'gd2n';'generate_dcm2niix_cmd'}

			DICOM_parent_folder = fileparts (DICOM_directory);
			dicom_bmp_dir = dir (fullfile (DICOM_parent_folder,'DICOM_bmp'));

	end

end


