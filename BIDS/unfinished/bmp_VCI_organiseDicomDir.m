function BMP_VCI = bmp_VCI_organiseDicomDir (BMP_VCI)

	dcm_coll = BMP_VCI.BIDS.dicomCollection;

	for i = 1 : length(BMP_VCI.BIDS.modalities)

		curr_modality = BMP_VCI.BIDS.modalities{i,1};

		series_description_keyword = BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.(curr_modality);
		
		fprintf ('%s : Start organising %s DICOM directory. We assume all %s sequences have keyword of ''%s''.\n', ...
						mfilename, curr_modality, curr_modality, series_description_keyword);

		curr_dcmCollection_subtable = dcm_coll(find(contains(dcm_coll.SeriesDescription, series_description_keyword, 'IgnoreCase', true)),:);

		curr_dcmCollection_SeriesDescUniqueVal = unique(curr_dcmCollection_subtable.SeriesDescription);
		
		fprintf ('%s : %d entries found in the dicomCollection table with keyword ''%s''. Unique SeriesDescription values include: \n', ...
						mfilename, length(curr_dcmCollection_SeriesDescUniqueVal), series_description_keyword);

		for i = 1 : length(curr_dcmCollection_SeriesDescUniqueVal)
			fprintf ('  >>> %s\n', curr_dcmCollection_SeriesDescUniqueVal(i));
		end


		for i = 1 : size(curr_dcmCollection_SeriesDescUniqueVal,1)

			fprintf ('%s : Now dealing with SeriesDescription = ''%s''.\n', ...
						mfilename, curr_dcmCollection_SeriesDescUniqueVal(i));

			curr_dcmCollection_subtable_currSeriesDescSubTable = curr_dcmCollection_subtable(find(strcmp(curr_dcmCollection_subtable.SeriesDescription, curr_dcmCollection_SeriesDescUniqueVal(i))),:);

			for j = 1 : size (curr_dcmCollection_subtable_currSeriesDescSubTable,1)

				fprintf ('%s : Current SeriesDescription = %s; SeriesInstanceUID = %s.\n', ...
							mfilename, curr_dcmCollection_SeriesDescUniqueVal(i), curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j});

				DICOM_BMP_path = fullfile (BMP_VCI.BIDS.individualBmpDicomDirectory, ...
											strrep(curr_dcmCollection_SeriesDescUniqueVal(i),' ','_'), ...
											curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j});

				if ~isfolder (DICOM_BMP_path)

					fprintf ('%s : %s folder doesn''t exist. Creating ... ', mfilename, DICOM_BMP_path);
					mkdir (DICOM_BMP_path);
					fprintf ('DONE!\n');

				else

					fprintf ('%s : %s folder exists.\n', mfilename, DICOM_BMP_path);

				end

				% Copying DICOM files to DICOM_bmp folders
				filenames_for_curr_seq = strrep(curr_dcmCollection_subtable_currSeriesDescSubTable.Filenames{j}, ...
												BMP_VCI.BIDS.stringInFilenamesInDicomCollectionstrToBeReplaced, ...
												BMP_VCI.BIDS.stringInFilenamesInDicomCollectionstrToReplaceTo); 

				fprintf ('%s : Copying ''SeriesDescription=%s'' DICOM files ''SeriesInstanceUID=%s'' (N = %d) ... ', mfilename, curr_dcmCollection_SeriesDescUniqueVal(i), curr_dcmCollection_subtable_currSeriesDescSubTable.SeriesInstanceUID{j}, size (filenames_for_curr_seq,1));

				for k = 1 : size (filenames_for_curr_seq,1)

					[status,message,messageId] = copyfile (filenames_for_curr_seq(k,1), DICOM_BMP_path);

					if ~status
						fprintf ('%s : [WARNING] : %s\n', mfilename, message);
					end

				end

				fprintf ('DONE!\n');

			end

		end

	end	

end