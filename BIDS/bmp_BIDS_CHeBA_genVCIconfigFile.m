function vci_dcm2bids_config = bmp_BIDS_CHeBA_genVCIconfigFile (varargin)
%
% DESCRIPTION :
%
%   This script generates dcm2bids configuration file for VCI study carried
%   out at RINSW.
%
% USAGE :
%
%   varargin{1} = "MEMPRAGE_echoes"; % additionally convert MEMPRAGE individual
%                                    % echoes.
%
%   varargin{1} = "DWI_pepolar"; % additionally convert individually acquired
%                                % everse PE B0's.
%
%   varargin{1} = "rsfMRI"; % additionally convert rsfMRI and reverse PE EPI's.
%                           % Note that rsfMRI is not acquired in VCI.
%                           % Borrowed MAS2 rsfMRI to prepare for AusCADASIL,
%                           % which will have rsfMRI acquired.
%
%   varargin{1} = "all"; % additionally convert all mentioned above.
%
% FUTURE WORK :
%
%   - For those that can be converted to BIDS, but may confuse BIDS pipelines,
%     can choose either not to convert them, or add them to .bidsignore.
%
% HISTORY :
%
%   20231031 - Dr. Jiyang Jiang created the 1st version.
%

	% MEMPRAGE RMS
	vci_dcm2bids_config.descriptions(1).datatype = "anat";
	vci_dcm2bids_config.descriptions(1).suffix = "T1w";
	vci_dcm2bids_config.descriptions(1).criteria.SeriesDescription = "ABCD_T1w_MPR_vNav_BW740 RMS";
	vci_dcm2bids_config.descriptions(1).criteria.ProtocolName = "ABCD_T1w_MPR_vNav_BW740";
	vci_dcm2bids_config.descriptions(1).custom_entities = "rec-RMS";

	% FLAIR
	vci_dcm2bids_config.descriptions(2).datatype = "anat";
	vci_dcm2bids_config.descriptions(2).suffix = "FLAIR";
	vci_dcm2bids_config.descriptions(2).criteria.SeriesDescription = "t2_space_DF_BW651";

	% T2w
	vci_dcm2bids_config.descriptions(3).datatype = "anat";
	vci_dcm2bids_config.descriptions(3).suffix = "T2w";
	vci_dcm2bids_config.descriptions(3).criteria.SeriesDescription = "ABCD_T2w_SPC_ vNav Iso0.8mm BW744";

	% Diffusion-weighted imaging
	% =====================================================
	% BIDS specification for multi-part DWI scheme:
	%
	%   https://bids-specification.readthedocs.io/en/latest/modality-specific-files/magnetic-resonance-imaging-data.html#multipart-split-dwi-schemes
	%

	% DWI - AP 1
	vci_dcm2bids_config.descriptions(4).id = "id_dwi_ap1";
	vci_dcm2bids_config.descriptions(4).datatype = "dwi";
	vci_dcm2bids_config.descriptions(4).suffix = "dwi";
	vci_dcm2bids_config.descriptions(4).criteria.SeriesDescription = "AP_BLOCK_1_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(4).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(4).custom_entities = "dir-AP_run-1";

	% DWI - AP 2
	vci_dcm2bids_config.descriptions(5).id = "id_dwi_ap2";
	vci_dcm2bids_config.descriptions(5).datatype = "dwi";
	vci_dcm2bids_config.descriptions(5).suffix = "dwi";
	vci_dcm2bids_config.descriptions(5).criteria.SeriesDescription = "AP_BLOCK_2_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(5).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(5).custom_entities = "dir-AP_run-2";

	% DWI - PA 1
	vci_dcm2bids_config.descriptions(6).id = "id_dwi_pa1";
	vci_dcm2bids_config.descriptions(6).datatype = "dwi";
	vci_dcm2bids_config.descriptions(6).suffix = "dwi";
	vci_dcm2bids_config.descriptions(6).criteria.SeriesDescription = "PA_BLOCK_1_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(6).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(6).custom_entities = "dir-PA_run-1";

	% DWI - PA 2
	vci_dcm2bids_config.descriptions(7).id = "id_dwi_pa2";
	vci_dcm2bids_config.descriptions(7).datatype = "dwi";
	vci_dcm2bids_config.descriptions(7).suffix = "dwi";
	vci_dcm2bids_config.descriptions(7).criteria.SeriesDescription = "PA_BLOCK_2_DIFFUSION_30DIR";
	vci_dcm2bids_config.descriptions(7).sidecar_changes.MultipartID = "dwi_1";
	vci_dcm2bids_config.descriptions(7).custom_entities = "dir-PA_run-2";



	% SWI
	%
	% Reference: https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	% MP2RAGE
	% 
	% Reference: https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html

	if nargin == 1

		switch varargin{1}

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

	% write to file
	bmp_path = getenv ('BMP_PATH');
	fid = fopen(fullfile(bmp_path, 'BIDS', 'config_files', 'VCI_config.json'), 'w');
	fprintf(fid,'%s', jsonencode(vci_dcm2bids_config,PrettyPrint=true));
	fclose(fid);

	fprintf ('Note that any empty fields in VCI_config.json needs to be removed.\n');


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
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051; % EffectiveEchoSpacing * (ReconMatrixPE - 1)
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
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = ["dir-PA_run-" num2str(i)];
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051; % EffectiveEchoSpacing * (ReconMatrixPE - 1)
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

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "AP_FMAP_for resting state fMRI normalise OFF";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j-";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-AP";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j-";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";

		curr_length = length(vci_dcm2bids_config.descriptions);
		curr_idx = curr_length + 1;

		vci_dcm2bids_config.descriptions(curr_idx).datatype = "fmap";
		vci_dcm2bids_config.descriptions(curr_idx).suffix = "epi";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.SeriesDescription = "PA_FMAP_for resting state fMRI normalise OFF";
		vci_dcm2bids_config.descriptions(curr_idx).criteria.PhaseEncodingDirection = "j";
		vci_dcm2bids_config.descriptions(curr_idx).custom_entities = "dir-PA";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.PhaseEncodingDirection = "j";
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.TotalReadoutTime = 0.051;
		vci_dcm2bids_config.descriptions(curr_idx).sidecar_changes.IntendedFor = "id_rsfmri";

	end

end