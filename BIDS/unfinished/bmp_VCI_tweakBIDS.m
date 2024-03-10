function bmp_VCI_tweakBIDS (BMP_VCI)

	% LOOP THROUGH JSONS TO BE CHANGED FOR THIS SUBJECT

		% Read JSON file
		% Ref : https://au.mathworks.com/matlabcentral/answers/474980-extract-info-from-json-file-by-matlab
		fid = fopen (json_to_modify);
		raw = fread (fid, inf);
		str = char (raw');
		fclose(fid);
		json = jsondecode (str);

		% IF IT IS "FIELDMAP FOR DIFFUSION" JSON TO MODIFY, THEN :
			json = fieldmapJsonIntendedForDiffusion (BMP_VCI, json);
		% ELSE IF "FIELDMAP FOR CVR" JSON TO MODIFY, THEN :
			json = fieldmapJsonIntendedForCvr		(BMP_VCI, json);
		% END IF

	% END LOOP

	% CREATE ASLCONTEXT.TSV FOR ASL FOR THE SUBJECT
	createAslContextTsv (BMP_VCI)


end

function dmri_fmap_json = fieldmapJsonIntendedForDiffusion (BMP_VCI, dmri_fmap_json)

	% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data

	
	%% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	%% NOT FINISHED YET
	%% BMP_VCI SHOULD HAVE BIDS FILE PATHS FOR THE 'INTENDEDFOR'
	%% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	% IDENTIFY AP/PA PE DIR

	% IF AP PE DIR, THEN :
		dmri_fmap_json.B0FieldIdentifier = 'b0_AP'; 
		dmri_fmap_json.IntendedFor		= {fullfile(['bids::sub-' subject_ID], 'dwi', ['sub-' subject_ID])};'
	% ELSEIF PA PE DIR, THEN :
		dmri_fmap_json.B0FieldIdentifier = 'b0_PA';
		dmri_fmap_json.IntendedFor
	% ENDIF

end

function cvr_fmap_json = fieldmapJsonIntendedForCvr (BMP_VCI, cvr_fmap_json)

	cvr_fmap_json.B0FieldIdentifier = 'pepolar_fmap'; 	% unsure
														% https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#case-4-multiple-phase-encoded-directions-pepolar
	cvr_fmap_json.IntendedFor       = 'PATH TO CVR'"

end

function createAslContextTsv (BMP_VCI)

end