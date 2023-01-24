function BMP_VCI = bmp_VCI_initialiseBmpVci (DICOM_directory, BIDS_directory)

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

	% The following keywords map all sequences to modalities, regardless of
	% whether they are useful and/or to be converted to NIFTI.
	% They are used in organising DICOM folders.
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



	% The following mappings only include those seq being useful and to be converted to NIFTI.

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.t1 = {'T1_MPRAGE_0.8_iso'}; 	% "T1_MPRAGE_0.8_iso"
																			    % "T1_MPRAGE_0.8_iso_MPR_Cor"
																			    % "T1_MPRAGE_0.8_iso_MPR_Sag"
																			    % "T1_MPRAGE_0.8_iso_MPR_Tra"
																			    % "T1_MPRAGE_0.8_iso_ND"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.t2 = {'T2_spc_sag_0.8mm'};	% "T2_spc_sag_0.8mm"
																			    % "T2_spc_sag_0.8mm_MPR_Cor"
																			    % "T2_spc_sag_0.8mm_MPR_Sag"
																			    % "T2_spc_sag_0.8mm_MPR_Tra"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.flair = {'t2_space_dark-fluid_sag_p2_ns-t2prep'};	% "t2_space_dark-fluid_sag_p2_ns-t2prep"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.swi = 	{
															'greME7_p31_256_Iso1mm_Mag'
														    'greME7_p31_256_Iso1mm_Pha'
														    'greME7_p31_256_Iso1mm_Qsm_Combined'
														    'greME7_p31_256_Iso1mm_SWI_Combined'
														    'greME7_p31_256_Iso1mm_SWI_mIP_Combined'
														    };										% "greME7_p31_256_Iso1mm_Mag"
																								    % "greME7_p31_256_Iso1mm_Pha"
																								    % "greME7_p31_256_Iso1mm_Qsm_Combined"
																								    % "greME7_p31_256_Iso1mm_SWI_Combined"
																								    % "greME7_p31_256_Iso1mm_SWI_mIP_Combined"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.dti =	{
															'AP_BLOCK_1_DIFFUSION_30DIR'
															'AP_BLOCK_2_DIFFUSION_30DIR'
															'AP_FMAP_for DIFFUSION'
															'PA_BLOCK_1_DIFFUSION_30DIR'
															'PA_BLOCK_2_DIFFUSION_30DIR'
															'PA_FMAP_for DIFFUSION'
															};										% "AP_BLOCK_1_DIFFUSION_30DIR"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_ADC"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_ColFA"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_FA"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TENSOR"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TENSOR_B0"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TRACEW"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_ADC"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_ColFA"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_FA"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TENSOR"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TENSOR_B0"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TRACEW"
																								    % "AP_FMAP_for DIFFUSION"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_ADC"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_ColFA"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_FA"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TENSOR"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TENSOR_B0"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TRACEW"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_ADC"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_ColFA"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_FA"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TENSOR"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TENSOR_B0"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TRACEW"
																								    % "PA_FMAP_for DIFFUSION"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.asl = {'asl_3d_tra_p2_iso_3mm_highres'};			% "asl_3d_tra_p2_iso_3mm_highres"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.cvr_fmap = {'gre_field_mapping 3.8mm'};			% "gre_field_mapping 3.8mm"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.cvr = {'CVR_ep2d_bold 3.8mm TR1500 adaptive'};	% "CVR_ep2d_bold 3.8mm TR1500 adaptive"
																								    % "CVR_ep2d_bold 3.8mm TR1500 adaptive_PMU"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.mp2rage = {
																't1_mp2rage_sag_0.8x0.8x2_INV1'
															    't1_mp2rage_sag_0.8x0.8x2_INV2'
															    't1_mp2rage_sag_0.8x0.8x2_T1_Images'
															    't1_mp2rage_sag_0.8x0.8x2_UNI_Images'
															};										% "t1_mp2rage_sag_0.8x0.8x2_INV1"
																								    % "t1_mp2rage_sag_0.8x0.8x2_INV2"
																								    % "t1_mp2rage_sag_0.8x0.8x2_T1_Images"
																								    % "t1_mp2rage_sag_0.8x0.8x2_UNI_Images"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.dce = {'t1_vibe_sag_DCE_2mm XL FOV 40s temporal res'};																							    														% "t1_vibe_sag_DCE_2mm XL FOV 40s temporal res"
																								    % "t1_vibe_sag_DCE_2mm XL FOV 40s temporal res_ND"


	% details for corresponding BIDS folder/file
	BMP_VCI.BIDS.BIDS_info.t1 = struct(	'DataType',								'anat', ...
										'Modality',								'T1w', ...
										'Acquisition',							'MPRAGE0p8iso', ...
										'correspondingSeriesDescription',		'T1_MPRAGE_0.8_iso');

	BMP_VCI.BIDS.BIDS_info.t2 = struct(	'DataType',								'anat', ...
										'Modality',								'T2w', ...
										'Acquisition',							'sagSPACE0p8iso', ...
										'correspondingSeriesDescription',		'T2_spc_sag_0.8mm');

	BMP_VCI.BIDS.BIDS_info.flair = struct(	'DataType',							'anat', ...
											'Modality',							'FLAIR', ...
											'Acquisition',						'sagSPACE', ...
											'correspondingSeriesDescription',	't2_space_dark-fluid_sag_p2_ns-t2prep');

	BMP_VCI.BIDS.BIDS_info.swi_mag = struct('DataType',							'swi', ...
											'Modality',							'GRE', ...
											'Part',								'mag', ...
											'correspondingSeriesDescription',	'greME7_p31_256_Iso1mm_Mag'); 
											% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.BIDS_info.swi_pha = struct('DataType',							'swi', ...
											'Modality',							'GRE', ...
											'Part',								'phase', ...
											'correspondingSeriesDescription',	'greME7_p31_256_Iso1mm_Pha'); 
											% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.BIDS_info.swi_qsm = struct('DataType',							'swi', ...
											'Modality',							'Chimap', ...
											'correspondingSeriesDescription',	'greME7_p31_256_Iso1mm_Qsm_Combined'); 
											% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.Chimap
											% 		https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.BIDS_info.swi_swi = struct('DataType',							'swi', ...
											'Modality',							'swi', ...
											'correspondingSeriesDescription',	'greME7_p31_256_Iso1mm_SWI_Combined');
											% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.BIDS_info.swi_mip = struct('DataType',							'swi', ...
											'Modality',							'minIP', ...
											'correspondingSeriesDescription',	'greME7_p31_256_Iso1mm_SWI_mIP_Combined');
											% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6
											
	BMP_VCI.BIDS.BIDS_info.dti_ap1 = struct('DataType',							'dwi', ...
											'Modality',							'dwi', ...
											'PhaseEncodingDirection',			'AP', ...
											'RunID',							'01', ...
											'correspondingSeriesDescription',	'AP_BLOCK_1_DIFFUSION_30DIR');
											% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.BIDS_info.dti_ap2 = struct('DataType',							'dwi', ...
											'Modality',							'dwi', ...
											'PhaseEncodingDirection',			'AP', ...
											'RunID',							'02', ...
											'correspondingSeriesDescription',	'AP_BLOCK_2_DIFFUSION_30DIR');
											% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.BIDS_info.dti_pa1 = struct('DataType',							'dwi', ...
											'Modality',							'dwi', ...
											'PhaseEncodingDirection',			'PA', ...
											'RunID',							'01', ...
											'correspondingSeriesDescription',	'PA_BLOCK_1_DIFFUSION_30DIR');
											% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.BIDS_info.dti_pa2 = struct('DataType',							'dwi', ...
											'Modality',							'dwi', ...
											'PhaseEncodingDirection',			'PA', ...
											'RunID',							'02', ...
											'correspondingSeriesDescription',	'PA_BLOCK_2_DIFFUSION_30DIR');
											% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.BIDS_info.dti_fmapAP = struct(	'DataType',							'fmap', ...
												'Modality',							'epi', ...
												'PhaseEncodingDirection',			'AP', ...
												'Description',						'forDwi', ...
												'correspondingSeriesDescription',	'AP_FMAP_for DIFFUSION');
											% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.epi
											%		https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data

	BMP_VCI.BIDS.BIDS_info.dti_fmapPA = struct(	'DataType',							'fmap', ...
												'Modality',							'epi', ...
												'PhaseEncodingDirection',			'PA', ...
												'Description',						'forDwi', ...
												'correspondingSeriesDescription',	'PA_FMAP_for DIFFUSION');
											% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.epi
											%		https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data

	BMP_VCI.BIDS.BIDS_info.asl = struct('DataType',								'perf', ...
										'Modality',								'asl', ...
										'correspondingSeriesDescription',		'asl_3d_tra_p2_iso_3mm_highres');


	BMP_VCI.BIDS.BIDS_info.cvr_fmap = struct(	'DataType',							'fmap', ...
												'Modality',							'epi', ...
												'Description',						'forCvr', ...
												'correspondingSeriesDescription',	'gre_field_mapping 3.8mm'); % Unsure about this fmap.
																												% Assuming it is 'pepolar' fieldmap.
																												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#case-4-multiple-phase-encoded-directions-pepolar

	BMP_VCI.BIDS.BIDS_info.cvr = struct('DataType',								'func', ...
										'Modality',								'bold', ...
										'Description',							'co2cvr', ...
										'correspondingSeriesDescription',		'CVR_ep2d_bold 3.8mm TR1500 adaptive');


	BMP_VCI.BIDS.BIDS_info.mp2rage_unit1 = struct(	'DataType',							'anat', ...
													'Modality',							'UNIT1', ...
													'correspondingSeriesDescription',	't1_mp2rage_sag_0.8x0.8x2_UNI_Images'); % Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.UNIT1
	BMP_VCI.BIDS.BIDS_modality.dce

	

	BMP_VCI.BIDS.DICOM_directory = DICOM_directory;
	BMP_VCI.BIDS.BIDS_directory  = BIDS_directory;

	BMP_VCI.BIDS.dicomCollection = dicomCollection (DICOM_directory, "IncludeSubfolders", true); 	% Note that DICOM folder is used
																									% as input, instead of DICOMDIR
																									% file. This is because output
																									% from dicomCollection with DICOMDIR
																									% will miss some series.

end