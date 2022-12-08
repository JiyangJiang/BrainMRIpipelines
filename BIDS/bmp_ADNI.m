function varargout = bmp_ADNI (operation_mode, varargin)
%
% DESCRIPTION
% ====================================================================================
%
%   bmp_ADNI aims to generate DICOM-to-BIDS mappings for ADNI dataset. It is called
%   by bmp_DICOMtoBIDSmapper if predefined dataset 'ADNI' is specified. Results of
%   bmp_ADNI can be directly used in bmp_BIDSgenerator. Details on the structure of
%   DICOM-to-BIDS mappings can be found in the header of bmp_BIDSgenerator.m, or by
%   typing 'help bmp_BIDSgenerator' in MATLAB Command Window.
%
%   Note that since ADNI dataset has multiple sessions (i.e., timepoints) and subject
%   ID and scan date need to be used to identify session label, we specify ADNI
%   DICOM-to-BIDS mappings in individual-level.
%
%
% EVIDENCE TO CREATE MAPPINGS
% ====================================================================================
%
%   ASL
%
%     For ADNI ASL data, we considered 5 CSV files of study data downloaded from 
%     https://ida.loni.usc.edu/pages/access/studyData.jsp?project=ADNI
%
%       - MRILIST.csv
%       - UCSFASLQC.csv
%       - UCSFASLFS_11_02_15_V2.csv
%       - UCSFASLFSCBF_08_17_22.csv
%       - ADNIMERGE.csv
%
%     Refer to /path/to/BrainMRIpipelines/BIDS/ADNI_study_data/bmp_procADNIstudyData.m.
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in two modes:
%
%     'create'   mode : This mode is used to generate DICOM-to-BIDS mappings, and save
%                       the mappings in a .mat file. In this mode, pass 'create'
%                       to the argument 'operation_mode', and /path/to/save/XXX.mat
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
%
%     'retrieve' mode : This mode load the previously created .mat file to retrieve the 
%                       predefiend mappings. In this mode, pass 'retrieve'
%                       to the argument 'operation_mode', and /path/to/retrieve/XXX.mat 
%                       to varargin{1}. If varargin{1} is not specified, default value
%                       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be used.
%
%
% SUPPORTED MODALITIES
% ====================================================================================
%
%   - asl
%
%
% HISTORY
% ====================================================================================
%
%   05 December 2022 - first version.
%
%
% KNOWN LIMITATIONS
% ====================================================================================
%
%  - Depending on VISCODE to identify multiply runs in the same session.
%
%  - Assumes max of 2 runs for each session.
%
%


	BMP_PATH = getenv ('BMP_PATH');



	% possible keywords in DICOM sequence name for each modality in ADNI
	possibleASLkeywords = 	{
							'ASL'
							'cerebral blood flow'
							'perfusion'
							};

	possibleT1keywords = 	{
							'MPRAGE'
							'T1'
							'IR-SPGR'
							'IR-FSPGR'
							'MP-RAGE'
							'MP RAGE'
							};

	possibleFLAIRkeywords = {
							'FLAIR'
							};



	switch operation_mode

		case 'create'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''create'' mode. Will save DICOM2BIDS mapping to %s.\n',mfilename,output);

			fprintf ('%s : Loading bmp_ADNI_forDicom2BidsMapping.mat ... ', mfilename);

			ADNI_mat = load (fullfile (BMP_PATH, 'BIDS', 'ADNI_study_data', 'bmp_ADNI_forDicom2BidsMapping.mat'));

			fprintf ('DONE!\n', mfilename);

			ADNI = ADNI_mat.ADNI_forDicom2BidsMapping;
			ADNI_uniqueSID = unique(ADNI.SID);

			fprintf ('%s : Start to create DICOM2BIDS mapping.\n', mfilename);

			


			for i = 1 : size (ADNI_uniqueSID,1)

				fprintf ('%s : Processing subject ID (SID) %s (index = %d/%d).\n', mfilename, ADNI_uniqueSID{i}, i, size(ADNI_uniqueSID,1));

				DICOM2BIDS(i).subject = ['ADNI' erase(ADNI_uniqueSID{i},'_')];

				sid_data = ADNI(find(strcmp(ADNI.SID, ADNI_uniqueSID{i})),:);

				fprintf ('%s :  --> Subject %s has %d entrie(s) in bmp_ADNI_forDicom2BidsMapping.mat.\n', mfilename, ADNI_uniqueSID{i}, size(sid_data,1));

				for j = 1 : size (sid_data, 1)



					% +++++++++++++++++++++++++
					%            ASL
					% +++++++++++++++++++++++++

					if contains (sid_data.SEQUENCE{j}, possibleASLkeywords, 'IgnoreCase', true)

						if any (strcmp (fieldnames (DICOM2BIDS(i)), sid_data.VISCODE{j})) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j})) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j})), 'perf')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf), 'asl')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl), 'run01')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.run01) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.run01), 'DICOM')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.run01.DICOM) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.run01.DICOM), 'SeriesDescription')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.run01.DICOM.SeriesDescription)
						   	run_idx = 'run02';
					    else
					    	run_idx = 'run01';
						end

						fprintf ('%s :  --> ASL found in bmp_ADNI_forDicom2BidsMapping.mat for %s (SEQUENCE = ''%s''; SCANDATE = ''%s''; VISCODE = ''%s''; IMAGEUID = ''%s''; run_idx = ''%s'').\n', mfilename, ADNI_uniqueSID{i}, sid_data.SEQUENCE{j}, char(sid_data.SCANDATE(j)), sid_data.VISCODE{j}, sid_data.IMAGEUID{j}, run_idx);

						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).DICOM.SeriesDescription 	= sid_data.SEQUENCE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).DICOM.PatientID         	= sid_data.SID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).DICOM.StudyDate  	    = erase(char(sid_data.SCANDATE(j)),'-');
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).DICOM.IMAGEUID			= sid_data.IMAGEUID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).DICOM.subfoldername		= strrep(strrep(strrep(sid_data.SEQUENCE{j},' ','_'),'(','_'),')','_');

						switch sid_data.SEQUENCE{j}

							case 'Axial 3D PASL (Eyes Open)'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPasl';
							case 'Axial 3D PASL (Eyes Open)    straight no angle'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPasl';
							case 'Axial 3D PASL (Eyes Open) REPEAT'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPasl'; 	% this happened once for 036_S_6316
																															% on 2019-08-13. However, we cannot
																															% find another ASL on the same day
																															% therefore, we are not assigning
																															% 'run' entity although it said
																															% 'REPEAT'.

							case 'Ax 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPcasl';
							case 'Axial 3D pCASL'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPcasl';
							case 'Axial 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPcasl';
							case 'Axial_3D_pCASL_Eyes_Open'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPcasl';
							case 'WIP SOURCE - Axial 3D pCASL (Eyes Open)'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial3dPcasl';

							case 'Axial 2D PASL'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';
							case 'Axial 2D PASL (EYES OPEN)'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';
							case 'Axial 2D PASL 0 angle L'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';
							case 'Axial 2D PASL straight no ASL'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';
						    case 'SOURCE - Axial 2D PASL'
						    	DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';
							case 'WIP SOURCE - Axial 2D PASL'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'axial2dPasl';

							case 'tgse_pcasl_PLD2000'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'pcaslPLD2000'

							case 'Cerebral Blood Flow'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'cbf';

							case 'Perfusion_Weighted'
								DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.acquisition = 'perfusionWeighted';

						end

						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.subject     = DICOM2BIDS(i).subject;
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.session     = sid_data.VISCODE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).perf.asl.(run_idx).BIDS.modality    = 'asl';



					% ++++++++++++++++++++++++++	
					%            T1
					% ++++++++++++++++++++++++++

					elseif contains (sid_data.SEQUENCE{j}, possibleT1keywords, 'IgnoreCase', true)

						if any (strcmp (fieldnames (DICOM2BIDS(i)), sid_data.VISCODE{j})) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j})) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j})), 'anat')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat), 'T1w')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w), 'run01')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.run01) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.run01), 'DICOM')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.run01.DICOM) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.run01.DICOM), 'SeriesDescription')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.run01.DICOM.SeriesDescription)
						   	run_idx = 'run02';
					    else
					    	run_idx = 'run01';
						end

						if contains (sid_data.SEQUENCE{j}, {'repeat', 'repe', 'rpt','rep', 'repea'}, 'IgnoreCase', true)		% if has keywords ~ 'repeat', force run_idx = '02'.
							run_idx = 'run02';
						end

						fprintf ('%s :  --> T1w found in bmp_ADNI_forDicom2BidsMapping.mat for %s (SEQUENCE = ''%s''; SCANDATE = ''%s''; VISCODE = ''%s''; IMAGEUID = ''%s''; run_idx = ''%s'').\n', mfilename, ADNI_uniqueSID{i}, sid_data.SEQUENCE{j}, char(sid_data.SCANDATE(j)), sid_data.VISCODE{j}, sid_data.IMAGEUID{j}, run_idx);

						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).DICOM.SeriesDescription 	= sid_data.SEQUENCE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).DICOM.PatientID         	= sid_data.SID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).DICOM.StudyDate  	    = erase(char(sid_data.SCANDATE(j)),'-');
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).DICOM.IMAGEUID			= sid_data.IMAGEUID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).DICOM.subfoldername		= strrep(strrep(strrep(sid_data.SEQUENCE{j},' ','_'),'(','_'),')','_');

						T1w_acquisition_label = '';
						if contains (sid_data.SEQUENCE{j}, {'SAG';'SAGITTAL'}, 'IgnoreCase', true)
							T1w_acquisition_label = [T1w_acquisition_label 'sag'];
						end
						if contains (sid_data.SEQUENCE{j}, '3D', 'IgnoreCase', true)
							T1w_acquisition_label = [T1w_acquisition_label '3d'];
						end
						if contains (sid_data.SEQUENCE{j}, 		{'MPRAGE', 'MP-RAGE', 'MP RAGE'}, 	'IgnoreCase', true) && (~ strcmp (sid_data.SEQUENCE{j}, 'IR-FSPGR (replaces MP-Rage)'))
							T1w_acquisition_label = [T1w_acquisition_label 'Mprage'];
						elseif contains (sid_data.SEQUENCE{j}, 	'IR-SPGR', 							'IgnoreCase', true)
							T1w_acquisition_label = [T1w_acquisition_label 'Irspgr'];
						elseif contains (sid_data.SEQUENCE{j}, 	'IR-FSPGR', 						'IgnoreCase', true)
							T1w_acquisition_label = [T1w_acquisition_label 'Irfspgr'];
						end

						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).BIDS.subject     = DICOM2BIDS(i).subject;
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).BIDS.session     = sid_data.VISCODE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).BIDS.acquisition = T1w_acquisition_label;
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.T1w.(run_idx).BIDS.modality    = 'T1w';



					% ++++++++++++++++++++++++++
					%           FLAIR
					% ++++++++++++++++++++++++++

					elseif contains (sid_data.SEQUENCE{j}, possibleFLAIRkeywords, 'IgnoreCase', true) && ...
							~ strcmp (sid_data.SEQUENCE{j}, 'Axial T2 Star-Repeated with exact copy of FLAIR')

						if any (strcmp (fieldnames (DICOM2BIDS(i)), sid_data.VISCODE{j})) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j})) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j})), 'anat')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat), 'FLAIR')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR), 'run01')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.run01) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.run01), 'DICOM')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.run01.DICOM) && ...
						   any (strcmp (fieldnames (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.run01.DICOM), 'SeriesDescription')) && ~ isempty (DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.run01.DICOM.SeriesDescription)
						   	run_idx = 'run02';
					    else
					    	run_idx = 'run01';
						end

						if contains (sid_data.SEQUENCE{j}, {'repeat'; 'rpt'}, 'IgnoreCase', true)
							run_idx = 'run02';
						end

						fprintf ('%s :  --> FLAIR found in bmp_ADNI_forDicom2BidsMapping.mat for %s (SEQUENCE = ''%s''; SCANDATE = ''%s''; VISCODE = ''%s''; IMAGEUID = ''%s''; run_idx = ''%s'').\n', mfilename, ADNI_uniqueSID{i}, sid_data.SEQUENCE{j}, char(sid_data.SCANDATE(j)), sid_data.VISCODE{j}, sid_data.IMAGEUID{j}, run_idx);

						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).DICOM.SeriesDescription 	= sid_data.SEQUENCE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).DICOM.PatientID         	= sid_data.SID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).DICOM.StudyDate  	    	= erase(char(sid_data.SCANDATE(j)),'-');
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).DICOM.IMAGEUID				= sid_data.IMAGEUID{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).DICOM.subfoldername		= strrep(strrep(strrep(sid_data.SEQUENCE{j},' ','_'),'(','_'),')','_');

						FLAIR_acquisition_label = '';

						if contains (sid_data.SEQUENCE{j}, {'AX';'AXIAL'}, 'IgnoreCase', true)
							FLAIR_acquisition_label = [FLAIR_acquisition_label 'ax'];
						elseif contains (sid_data.SEQUENCE{j}, 'Sagittal', 'IgnoreCase', true)
							FLAIR_acquisition_label = [FLAIR_acquisition_label 'sag'];
						end
						if contains (sid_data.SEQUENCE{j}, '3D', 'IgnoreCase', true)
							FLAIR_acquisition_label = [FLAIR_acquisition_label '3d'];
						end

						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).BIDS.subject     = DICOM2BIDS(i).subject;
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).BIDS.session     = sid_data.VISCODE{j};
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).BIDS.acquisition = FLAIR_acquisition_label;
						DICOM2BIDS(i).(sid_data.VISCODE{j}).anat.FLAIR.(run_idx).BIDS.modality    = 'FLAIR';

					end

				end

			end


			fprintf ('%s : DICOM2BIDS mapping has been created.\n', mfilename);

			fprintf ('%s : Saving DICOM2BIDS to %s ... ', mfilename, output);

			save (output, 'DICOM2BIDS');

			fprintf ('DONE!\n');




		case 'retrieve'

			if nargin == 2 && endsWith(varargin{1},'.mat')
				predefined_mapping = varargin{1};
			else
				predefined_mapping = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''retrieve'' mode. Will retrieve DICOM2BIDS mapping from %s.\n',mfilename,predefined_mapping);

			fprintf ('%s : Loading %s ... ', mfilename, predefined_mapping);

			DICOM2BIDS = load(predefined_mapping).DICOM2BIDS;

			fprintf ('DONE!\n');

	end



	varargout{1} = DICOM2BIDS;

end
	
