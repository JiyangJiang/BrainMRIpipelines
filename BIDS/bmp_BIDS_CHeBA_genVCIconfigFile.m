function vci_dcm2bids_config = bmp_BIDS_CHeBA_genVCIconfigFile (varargin)
%
% DESCRIPTION :
%
%   This script generates dcm2bids configuration file for VCI study carried
%   out at RINSW.
%
% USAGE :
%
%   varargin{1} = a cell array of additional modalities to be converted.
%
%   "MEMPRAGE_echoes" : % additionally convert MEMPRAGE individual
%                       % echoes.
%
%   "DWI_pepolar"     : % additionally convert individually acquired
%                       % everse PE B0's.
%
%   "rsfMRI"          : % additionally convert rsfMRI and reverse PE EPI's.
%                       % Note that rsfMRI is not acquired in VCI.
%                       % Borrowed MAS2 rsfMRI to prepare for AusCADASIL,
%                       % which will have rsfMRI acquired.
%
%   "all"             : % additionally convert all mentioned above.
%
% FUTURE WORK :
%
%   - For those that can be converted to BIDS, but may confuse BIDS pipelines,
%     can choose either not to convert them, or add them to .bidsignore.
%
% HISTORY :
%
%   20231031 - Dr. Jiyang Jiang created the 1st version.
%	20240223 - Include reverse PE M0 for ASL distortion correction.
%			   Include resting and CO2-challenged BOLD images
%

	clear vci_dcm2bids_config;

	% MEMPRAGE RMS
	vci_dcm2bids_config.descriptions(1).id = "id_memprage_rms";
	vci_dcm2bids_config.descriptions(1).datatype = "anat";
	vci_dcm2bids_config.descriptions(1).suffix = "T1w";
	vci_dcm2bids_config.descriptions(1).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740 RMS";
	vci_dcm2bids_config.descriptions(1).criteria.ProtocolName = "ABCD_T1w_MPR_vNav_BW740";
	vci_dcm2bids_config.descriptions(1).custom_entities = "rec-RMS";
	vci_dcm2bids_config.descriptions(1).sidecar_changes.InstitutionName = "RINSW"; 	% this sidecar change works as
																					% a placeholder, to avoid empty
																					% []. It does not intend to change
																					% anything.

	% MEMPRAGE RMS (vci001 only)
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_memprage_rms_vci001";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "T1_MEMPRAGE Iso0.9mm_64ch RMS";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.ProtocolName = "T1_MEMPRAGE Iso0.9mm_64ch";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "rec-RMS";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";

	% FLAIR
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_flair";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "FLAIR";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "t2_space_DF_BW651";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-spaceDarkFluid";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";

	% T2w
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_t2w";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "T2w";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T2w_SPC_ vNav Iso0.8mm BW744";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-space";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";

	% T2w (vci001 only)
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_t2w_vci001";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "T2w";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T2w_SPC_ vNav Iso0.9mm BW650";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-space";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.InstitutionName = "RINSW";

	% Diffusion-weighted imaging
	% =====================================================
	% BIDS specification for multi-part DWI scheme:
	%
	%   https://bids-specification.readthedocs.io/en/latest/modality-specific-files/magnetic-resonance-imaging-data.html#multipart-split-dwi-schemes
	%

	% DWI - AP 1
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_ap1";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_BLOCK_1_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP_run-1";

	% DWI - AP 2
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_ap2";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_BLOCK_2_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP_run-2";

	% DWI - PA 1
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_pa1";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_BLOCK_1_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA_run-1";

	% DWI - PA 2
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_dwi_pa2";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "dwi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_BLOCK_2_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA_run-2";

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
	for i = 1 : 2  % for adding special cases
		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		vci_dcm2bids_config.descriptions(curr_idx).id = "id_asl_asl";
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "perf";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "asl";
		if i == 1
			vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc"; % most common
		elseif i == 2
			vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc_RR"; % vci001
		end
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.M0Type = "Included";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalAcquiredPairs = 16;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.AcquisitionVoxelSize = [3.4,3.4,4];
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingDuration = [0,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8];
		% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingDuration = [0,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8,1.8];
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PostLabelingDelay = [0,0,0,0,0,0,0,0,0,0,0,0,0,0.2,0.2,0.4,0.4,0.6,0.6,0.8,0.8,1.0,1.0,1.2,1.2,1.4,1.4,1.6,1.6,1.8,1.8,2.0,2.0];
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LookLocker = false;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingEfficiency = 0.60; 	% From Siemens WIP ASL doc, experimentally, with PCASL
																						% background suppression gray-white-strong (which was
																						% used in VCI), labeling efficiency alpha is 60%.
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.BackgroundSuppression = true;																				
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.BackgroundSuppressionNumberPulses = 4; % From Siemens WIP ASL doc, "gray-white-strong"
																									% background suppression has 4 pulses.
		% The following sidecar changes are recommended metadata fields by BIDS v1.9.0 spec,
		% Data come from "WipMemBlock" field of JSON file - it says "wip_Adv3DASL(Mar 28 2023) 
		% PCASL unbalanced: B1_ave=1.8uT/FA27.6,  G_ave=1mT/m, G_max=8mT/m"
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseAverageGradient = 1; 	% average labeling gradient switched on during the
																								% application of the labelling RF pulses, in
																								% milliteslas per meter.
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseMaximumGradient = 8;	% max amplitude of gradient switched on during the
																								% application of the labelling RF pulses, in
																								% milliteslas per meter.
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseAverageB1 = 1.8;		% average B1-field strength of the RF labeling pulses
																								% in microteslas.
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PCASLType = "unbalanced";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.LabelingPulseFlipAngle = 27.6; % That's my guess on "FA27.6".
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.RepetitionTimePreparation = 4.14; % https://neurostars.org/t/repetitiontime-parameters-what-are-they-and-where-to-find-them/20020

		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_asl";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.VascularCrushing = false;
	end

	% ASL - PEPolar FMAP - AP
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_asl_pepolar_fmap_ap";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP pcasl";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.ProtocolName = "AP_FMAP pcasl";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForAsl_dir-AP";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_asl_asl";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_asl";

	% ASL - PEPolar FMAP - PA
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_asl_pepolar_fmap_pa";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP pcasl";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.ProtocolName = "PA_FMAP pcasl";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForAsl_dir-PA";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_asl_asl";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_asl";

	% ASL - PEPolar FMAP - AP M0
	%
	% Note that since VCI004 (15/02/2024), AP M0 was acquired for ASL distortion
	% correction.
	%
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;
	vci_dcm2bids_config.descriptions(curr_idx).id = "id_asl_pepolar_fmap_apm0";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "m0scan";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "A-P m0 field map";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.ProtocolName = "A-P m0 field map";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_asl_asl";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_asl";

	% CVR resting
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	vci_dcm2bids_config.descriptions(curr_idx).id = "id_cvr_rest";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "func";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "bold";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "Resting state_ep2d_bold 3.8mm TR1500 adaptive";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "task-rest_dir-PA";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TaskName = "rest";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_cvr_rest";

	% CVR CO2
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	vci_dcm2bids_config.descriptions(curr_idx).id = "id_cvr_co2";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "func";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "bold";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "CVR_ep2d_bold 3.8mm TR1500 adaptive";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "task-co2_dir-PA";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TaskName = "co2";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_cvr_co2";

	% CVR FMAP AP
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	vci_dcm2bids_config.descriptions(curr_idx).id = "id_cvr_pepolar_fmap_ap";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP cvr";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-APforCVR_dir-AP";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
	% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(1) = "id_cvr_rest";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(2) = "id_cvr_co2";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier(1) = "pepolar_cvr_rest";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier(2) = "pepolar_cvr_co2";

	% CVR FMAP PA
	curr_length = length(vci_dcm2bids_config.descriptions);
	curr_idx = curr_length + 1;

	vci_dcm2bids_config.descriptions(curr_idx).id = "id_cvr_pepolar_fmap_pa";
	vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
	vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP cvr";
	vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
	vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-PAforCVR_dir-PA";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
	% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(1) = "id_cvr_rest";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(2) = "id_cvr_co2";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier(1) = "pepolar_cvr_rest";
	vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier(2) = "pepolar_cvr_co2";


	% TO-DO's
	%

	% SWI
	%
	% Reference: https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	% MP2RAGE
	% 
	% Reference: https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html


	if nargin == 1

		additional_mods = varargin{1};

		for i = 1 : length(additional_mods)

			switch additional_mods{i}

			case "MEMPRAGE_echoes"

				vci_dcm2bids_config = conv_additional_MEMPRAGEechoes (vci_dcm2bids_config);

			case "DWI_pepolar"

				vci_dcm2bids_config = conv_additional_DWIpepolar (vci_dcm2bids_config);

			case "rsfMRI"

				vci_dcm2bids_config = conv_additional_rsfMRI (vci_dcm2bids_config);

			case "all"

				vci_dcm2bids_config = conv_additional_MEMPRAGEechoes (vci_dcm2bids_config);
				vci_dcm2bids_config = conv_additional_DWIpepolar (vci_dcm2bids_config);
				vci_dcm2bids_config = conv_additional_rsfMRI (vci_dcm2bids_config);

			end

		end

	end

	% write to file
	bmp_path = getenv ('BMP_PATH');
	fid = fopen(fullfile(bmp_path, 'BIDS', 'config_files', 'VCI_config.json'), 'w');
	fprintf(fid,'%s', jsonencode(vci_dcm2bids_config,PrettyPrint=true));
	fclose(fid);

	% fprintf ('Note that any empty fields in VCI_config.json needs to be removed.\n');


	function vci_dcm2bids_config = conv_additional_MEMPRAGEechoes (vci_dcm2bids_config)

		% MEMPRAGE echo 1
		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 1;
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00181;
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-1";

		% MEMPRAGE echo 2
		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 2;
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.0036;
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-2";

		% MEMPRAGE echo 3
		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 3;
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00539;
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-3";

		% MEMPRAGE echo 4
		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "anat";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "T1w";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoNumber = 4;
		vci_dcm2bids_config.descriptions(curr_idx).criteria.EchoTime = 0.00718;
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "echo-4";

	end

	function vci_dcm2bids_config = conv_additional_DWIpepolar (vci_dcm2bids_config)

		% Reference: https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#case-4-multiple-phase-encoded-directions-pepolar

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP_for DIFFUSION";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForDwi_dir-AP";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
		% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051; 	% EffectiveEchoSpacing * (ReconMatrixPE - 1)
																								% Original JSON file has this field correctly calculated.
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(1) = "id_dwi_ap1";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(2) = "id_dwi_ap2";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(3) = "id_dwi_pa1";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(4) = "id_dwi_pa2";

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP_for DIFFUSION";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForDwi_dir-PA";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
		% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051; % EffectiveEchoSpacing * (ReconMatrixPE - 1)
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(1) = "id_dwi_ap1";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(2) = "id_dwi_ap2";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(3) = "id_dwi_pa1";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor(4) = "id_dwi_pa2";

	end

	function vci_dcm2bids_config = conv_additional_rsfMRI (vci_dcm2bids_config)

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		% rsfMRI - Note that VCI doesn't have rsfMRI, however AusCADASIL has, therefore borrow MAS2 rsfMRI
		vci_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri";
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "func";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "bold";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "fMRI _RESTING STATE_MB6_PA normalise OFF";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "task-rest";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TaskName = "rest";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldSource = "pepolar_rsfmri";

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri_pepolar_fmap_ap";
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP_for resting state fMRI normalise OFF";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForRsfmri_dir-AP";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
		% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_rsfmri";

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).id = "id_rsfmri_pepolar_fmap_pa";
		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP_for resting state fMRI normalise OFF";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "acq-pepolarForRsfmri_dir-PA";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
		% vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.B0FieldIdentifier = "pepolar_rsfmri";

	end

end