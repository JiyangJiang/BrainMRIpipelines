function cadsyd_dcm2bids_config = bmp_BIDS_CHeBA_genCADSYDconfigFile (varargin)
%
% DESCRIPTION :
%
%   This script generates dcm2bids configuration file for CADASIL Sydney site 
%   at RINSW.
%
% USAGE :
%
%   varargin{1} = a cell array of additional modalities to be converted.
%
%   "MEMPRAGE_echoes" : % additionally convert MEMPRAGE individual
%                       % echoes.
%
%
% FUTURE WORK :
%
%   - For those that can be converted to BIDS, but may confuse BIDS pipelines,
%     can choose either not to convert them, or add them to .bidsignore.
%
% HISTORY :
%
%   20240309 - Dr. Jiyang Jiang created the 1st version.
%

	clear cadsyd_dcm2bids_config;

	% MEMPRAGE RMS
	cadsyd_dcm2bids_config.descriptions(1).id = "id_memprage_rms";
	cadsyd_dcm2bids_config.descriptions(1).datatype = "anat";
	cadsyd_dcm2bids_config.descriptions(1).suffix = "T1w";
	cadsyd_dcm2bids_config.descriptions(1).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740 RMS";
	cadsyd_dcm2bids_config.descriptions(1).criteria.ProtocolName = "ABCD_T1w_MPR_vNav_BW740";
	cadsyd_dcm2bids_config.descriptions(1).custom_entities = "rec-RMS";
	cadsyd_dcm2bids_config.descriptions(1).sidecar_changes.InstitutionName = "RINSW"; 	% this sidecar change works as
																					% a placeholder, to avoid empty
																					% []. It does not intend to change
																					% anything.

	% FLAIR
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_flair";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "FLAIR";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "t2_space_DF_BW651";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-spaceDarkFluid";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";

	% T2w
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_t2w";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "T2w";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T2w_SPC_ vNav Iso0.8mm BW744";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-space";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";


	% Diffusion-weighted imaging
	% =====================================================
	% BIDS specification for multi-part DWI scheme:
	%
	%   https://bids-specification.readthedocs.io/en/latest/modality-specific-files/magnetic-resonance-imaging-data.html#multipart-split-dwi-schemes
	%

	% DWI - AP 1
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_ap1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_BLOCK_1_DIFFUSION_30DIR";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP_run-1";

	% DWI - AP 2
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_ap2";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_BLOCK_2_DIFFUSION_30DIR";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP_run-2";

	% DWI - PA 1
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_pa1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_BLOCK_1_DIFFUSION_30DIR";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA_run-1";

	% DWI - PA 2
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_pa2";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_BLOCK_2_DIFFUSION_30DIR";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA_run-2";

	% ASL
	% =====================================================
	%
	% References :
	%
	%   ASL-BIDS         : https://www.nature.com/articles/s41597-022-01615-9
	%
	%   ASL data scaling : https://bids-standard.github.io/bids-starter-kit/tutorials/asl.html
	%
	%   ASL BIDS and REPETITION_TIME_PREPARATION_MISSING error : 
	%       - https://neurostars.org/t/bids-asl-pld-vs-ti/21521
	%       - https://neurostars.org/t/repetitiontime-parameters-what-are-they-and-where-to-find-them/20020
	%
	%

	% ASL - ASL
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_asl_asl";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "perf";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "asl";
	
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc"; % most common
	
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.M0Type = "Included";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalAcquiredPairs = 16;
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.AcquisitionVoxelSize = [3.4,3.4,4];
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingDuration = [0,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8];
	% cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingDuration = [0,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8];
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PostLabelingDelay = [0,0,0,0,0,0,0,0,0,0,0,0,0,0.2,0.2,0.4,0.4,0.6,0.6,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,2.0,2.0];
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LookLocker = false;
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingEfficiency = 0.60; 	% From Siemens WIP ASL doc, experimentally, with PCASL
																					% background suppression gray-white-strong (which was
																					% used in VCI), labeling efficiency alpha is 60%.
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.BackgroundSuppression = true;																				
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.BackgroundSuppressionNumberPulses = 4; % From Siemens WIP ASL doc, "gray-white-strong"
																								% background suppression has 4 pulses.
	% The following sidecar changes are recommended metadata fields by BIDS v1.9.0 spec,
	% Data come from "WipMemBlock" field of JSON file - it says "wip_Adv3DASL(Mar 28 2023) 
	% PCASL unbalanced: B1_ave=1.8uT/FA27.6,  G_ave=1mT/m, G_max=8mT/m"
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseAverageGradient = 1; 	% average labeling gradient switched on during the
																							% application of the labelling RF pulses, in
																							% milliteslas per meter.
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseMaximumGradient = 8;	% max amplitude of gradient switched on during the
																							% application of the labelling RF pulses, in
																							% milliteslas per meter.
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseAverageB1 = 1.8;		% average B1-field strength of the RF labeling pulses
																							% in microteslas.
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PCASLType = "unbalanced";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseFlipAngle = 27.6; % That's my guess on "FA27.6".
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.RepetitionTimePreparation = 4.14; % https://neurostars.org/t/repetitiontime-parameters-what-are-they-and-where-to-find-them/20020

	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_asl";


	% ASL - PEPolar FMAP - AP M0
	%
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_asl_pepolar_fmap_apm0";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "m0scan";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "A-P m0 field map";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.ProtocolName = "A-P m0 field map";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_asl_asl";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_asl";

	% rsfMRI
	%
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	% rsfMRI - Note that VCI doesn't have rsfMRI, however AusCADASIL has, therefore borrow MAS2 rsfMRI
	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "func";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "bold";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "fMRI _RESTING STATE_MB6_PA normalise OFF";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "task-rest";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TaskName = "rest";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_rsfmri";

	% rsfMRI fmap AP
	%
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri_pepolar_fmap_ap";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP_for resting state fMRI normalise OFF";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForRsfmri_dir-AP";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
	% cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_rsfmri";

	% rsfMRI fmap PA
	%
	curr_length = length(cadsyd_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	cadsyd_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri_pepolar_fmap_pa";
	cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP_for resting state fMRI normalise OFF";
	cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
	cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForRsfmri_dir-PA";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
	% cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";
	cadsyd_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_rsfmri";

	% TO-DO's
	%

	% SWI
	%
	% Reference: https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	if nargin == 1

		additional_mods = varargin{1};

		for i = 1 : length(additional_mods)

			switch additional_mods{i}

			case "MEMPRAGE_echoes"

				cadsyd_dcm2bids_config = conv_additional_MEMPRAGEechoes (cadsyd_dcm2bids_config);

			end

		end

	end

	% write to file
	bmp_path = getenv ('BMP_PATH');
	fid = fopen(fullfile(bmp_path, 'BIDS', 'config_files', 'CADSYD_config.json'), 'w');
	fprintf(fid,'%s', jsonencode(cadsyd_dcm2bids_config,PrettyPrint=true));
	fclose(fid);

	% fprintf ('Note that any empty fields in VCI_config.json needs to be removed.\n');


	function cadsyd_dcm2bids_config = conv_additional_MEMPRAGEechoes (cadsyd_dcm2bids_config)

		% MEMPRAGE echo 1
		curr_length = length(cadsyd_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 1;
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00181;
		cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-1";

		% MEMPRAGE echo 2
		curr_length = length(cadsyd_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 2;
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.0036;
		cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-2";

		% MEMPRAGE echo 3
		curr_length = length(cadsyd_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 3;
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00539;
		cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-3";

		% MEMPRAGE echo 4
		curr_length = length(cadsyd_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		cadsyd_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		cadsyd_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 4;
		cadsyd_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00718;
		cadsyd_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-4";

	end

end