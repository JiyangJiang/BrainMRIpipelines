function BMP_VCI = bmp_VCI_organiseDicomDir (BMP_VCI)

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
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.t1;
				BIDS_modality = 'T1w';
			case 'T2'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.t2;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.t2;
				BIDS_modality = 'T2w';
			case 'FLAIR'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.flair;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.flair;
				BIDS_modality = 'FLAIR'
			case 'SWI'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.swi;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.swi
			case 'DTI'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dti;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.dti;
			case 'ASL'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.asl;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.asl;
			case 'CVR_fmap'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr_fmap;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.cvr_fmap;
			case 'CVR'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.cvr;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.cvr;
			case 'MP2RAGE'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.mp2rage;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.mp2rage;
			case 'DCE'
				series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.dce;
				series_description_toConv  = BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.dce;
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


				%% ---=== TO DO ===---
				%
				% if SeriesDescription within BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI,
				% then create dcm2niix commands
				% if ismember (curr_dcmCollection_SeriesDescUniqueVal(i), series_description_toConv)
				% 	BMP_VCI.BIDS.dcm2niix_cmd


				% Copying DICOM files to DICOM_bmp folders
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

end