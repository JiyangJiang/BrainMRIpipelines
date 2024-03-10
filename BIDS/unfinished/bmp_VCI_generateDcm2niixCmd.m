function BMP_VCI = bmp_VCI_generateDcm2niixCmd (BMP_VCI, varargin)
%
%
% varargin{1} = 'runDcm2niix'
%
%
	BMP_VCI.BIDS.dcm2niixcmd = cell(0, 1);

	for i = 1 : length(BMP_VCI.BIDS.modalities)

		curr_modality = BMP_VCI.BIDS.modalities{i,1};
		fprintf ('%s : Current modality = ''%s''.\n', mfilename, curr_modality);
		
		if ismember(curr_modality, {'T1';'T2';'FLAIR';'ASL';'CVR_fmap';'CVR';'DCE'})

			availFields = cellstr(curr_modality);

		elseif strcmp (curr_modality, 'SWI')

			availFields = {'SWI_mag';'SWI_pha';'SWI_qsm';'SWI_swi';'SWI_mip'};

		elseif strcmp (curr_modality, 'DWI')

			availFields = {'DWI_ap1';'DWI_ap2';'DWI_pa1';'DWI_pa2';'DWI_fmapAP';'DWI_fmapPA'};

		elseif strcmp (curr_modality, 'MP2RAGE')

			availFields = {'MP2RAGE_unit1';'MP2RAGE_t1map';'MP2RAGE_inv1';'MP2RAGE_inv2'};
		
		end

		for j = 1 : length(availFields)

			fprintf ('%s : Current sequence = ''%s''.\n', mfilename, availFields{j,1});

			currDateTime = strrep(char(datetime),' ','_');

			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'IsDerivatives') && ...
				isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'Software')
				currBIDSdirectory = fullfile(	BMP_VCI.BIDS.cohortBIDSdirectory, ...
												'derivatives', ...
												BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Software, ...
												['sub-' BMP_VCI.BIDS.subject_label], ...
												BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).DataType);
			else
				currBIDSdirectory = fullfile(	BMP_VCI.BIDS.individualBIDSdirectory, ...
												BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).DataType);
			end

			currBIDSfilename = ['sub-' BMP_VCI.BIDS.subject_label '_'];

			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'Acquisition')
				currBIDSfilename = [currBIDSfilename 'acq-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Acquisition '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'Part')
				currBIDSfilename = [currBIDSfilename 'part-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Part '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'PhaseEncodingDirection')
				currBIDSfilename = [currBIDSfilename 'dir-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).PhaseEncodingDirection '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'RunID')
				currBIDSfilename = [currBIDSfilename 'run-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).RunID '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'Description')
				currBIDSfilename = [currBIDSfilename 'desc-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Description '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'Inversion')
				currBIDSfilename = [currBIDSfilename 'inv-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Inversion '_'];
			end
			if isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'ContrastEnhancingAgent')
				currBIDSfilename = [currBIDSfilename 'ce-' BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).ContrastEnhancingAgent '_'];
			end


			if ~isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'HasMultipleVolumes') || ...
				(isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'HasMultipleVolumes') && ...
									strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).HasMultipleVolumes, 'yes') && ...
									isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'EachVolumeAsSeparate3D') && ...
									strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).EachVolumeAsSeparate3D, 'no') && ...
									isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'AllVolumesAsSingle4D') && ...
									strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).AllVolumesAsSingle4D, 'yes'))

				currDicomInputDir = fullfile (BMP_VCI.BIDS.individualBmpDicomDirectory, ...
											strrep(BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).CorrespondingSeriesDescription,' ','_'));

				currBIDSfilename = [currBIDSfilename BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Modality];

				BMP_VCI.BIDS.dcm2niixcmd(end+1,1) = generateDcm2niixCmd (currDateTime, currDicomInputDir, currBIDSdirectory, currBIDSfilename);

			elseif isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'HasMultipleVolumes') && ...
					strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).HasMultipleVolumes, 'yes') && ...
					isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'EachVolumeAsSeparate3D') && ...
					strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).EachVolumeAsSeparate3D, 'yes') && ...
					isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'AllVolumesAsSingle4D') && ...
					strcmp (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).AllVolumesAsSingle4D, 'no') && ...
					isfield (BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}), 'NumEchoes')

				SeriesInstanceUID_dir = dir (fullfile (BMP_VCI.BIDS.individualBmpDicomDirectory, ...
														strrep(BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).CorrespondingSeriesDescription,' ','_')));

				if size(SeriesInstanceUID_dir,1) ~= BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).NumEchoes + 2

					error ('%s : [ERROR] : ''NumEchoes'' was set to %d, but %d SeriesInstanceUID found in ''%s''', ...
							mfilename, ...
							BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).NumEchoes, ...
							(size(SeriesInstanceUID_dir,1) - 2), ...
							fullfile (BMP_VCI.BIDS.individualBmpDicomDirectory, strrep(BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).CorrespondingSeriesDescription,' ','_')));

				else

					currBIDSfilename_temp = currBIDSfilename;

					fprintf ('%s : %d echoes in sequence ''%s''.\n', mfilename, BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).NumEchoes, availFields{j,1});

					for echo_idx = 1 : BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).NumEchoes

						fprintf (' >>> echo %d.\n', echo_idx);

						currBIDSfilename = [currBIDSfilename_temp 'echo-' num2str(echo_idx) '_'];
						currBIDSfilename = [currBIDSfilename BMP_VCI.BIDS.DICOM2BIDS.(availFields{j,1}).Modality];

						currDicomInputDir = fullfile (SeriesInstanceUID_dir(echo_idx+2).folder, SeriesInstanceUID_dir(echo_idx+2).name);

						BMP_VCI.BIDS.dcm2niixcmd(end+1,1) = generateDcm2niixCmd (currDateTime, currDicomInputDir, currBIDSdirectory, currBIDSfilename);

					end

				end

			end

		end

	end

	if nargin == 2 && strcmp (varargin{1}, 'runDcm2niix')
		BMP_VCI.BIDS.dcm2niixcmdStatus = cell (size(BMP_VCI.BIDS.dcm2niixcmd));
		BMP_VCI.BIDS.dcm2niixcmdOut	   = cell (size(BMP_VCI.BIDS.dcm2niixcmd));
		for idx_dcm2niixcmd = 1 : length (BMP_VCI.BIDS.dcm2niixcmd)
			fprintf ('%s : Running dcm2niix command : ''%s'' ... ', mfilename, BMP_VCI.BIDS.dcm2niixcmd{idx_dcm2niixcmd,1});
			[BMP_VCI.BIDS.dcm2niixcmdStatus{idx_dcm2niixcmd,1}, BMP_VCI.BIDS.dcm2niixcmdOut{idx_dcm2niixcmd,1}] = system (BMP_VCI.BIDS.dcm2niixcmd{idx_dcm2niixcmd,1});
			fprintf ('DONE!\n');
		end
	end

end

function curr_dcm2niix_cmd = generateDcm2niixCmd (currDateTime, currDicomInputDir, currBIDSdirectory, currBIDSfilename)

	if ~isfolder (currBIDSdirectory)
		[~] = mkdir (currBIDSdirectory);
	end

	curr_dcm2niix_cmd = strcat (	'dcm2niix   -6', ...
									' -a n', ...
									' -b y', ...
									' -ba n', ...
									' -c BMP_', currDateTime, ...
									' -d 1', ...
									' -e n', ...
									' -f', {' '}, currBIDSfilename, ...
									' -g n', ...
									' -i n', ...
									' -l o', ...
									' -o', {' '}, currBIDSdirectory, ...
									' -p n', ...
									' -r n', ...
									' -s n', ...
									' -v 0', ...
									' -w 1', ...
									' -x n', ...
									' -z n', ...
									' --big-endian o', ...
									' --progress n', ...
									' --terse', ...
									{' '}, currDicomInputDir);
									% Reference : --terse to omit '_ph', '_real', etc. in the end of filename
									% https://github.com/rordenlab/dcm2niix/blob/master/FILENAMING.md
									% If you do not want post-fixes, run dcm2niix in the terse mode (--terse). In this mode, most post-fixes will be omitted. Beware that this mode can have name clashes, and images from a series may over write each other.
									%
									% -a n : e.g., dwi - each vol in separate folder, but they're to be combined as a single 4D.

end