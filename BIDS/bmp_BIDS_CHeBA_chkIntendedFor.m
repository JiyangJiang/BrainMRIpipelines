function varargout = bmp_BIDS_CHeBA_chkIntendedFor (BIDS_dir, subject_ID)

% DESCRIPTION
%
%   When field map is acquired before the target sequence (e.g., BOLD image),
%   dcm2bids will fail to find the id of target, and therefore be unable 
%   to set the "IntendedFor" field for in the JSON of field map.
%
%   This script aims to check such cases and fix them.
%
% OUTPUT
%
%   varargout{1} = struct of m0scan json.
%   varargout{2} = struct of json of AP fmap for BOLD.
%   varargout{3} = struct of json of PA fmap for BOLD.
%
% HISTORY
%
%   - 23 Feb 2024: Jiyang Jiang created the first version.
%

fmap_dir = fullfile (BIDS_dir, ['sub-' subject_ID], 'fmap');

% Check json file of reversed M0 for "IntendedFor"
fprintf ("Checking json file of reversed M0 for IntendedFor ... ");
m0scan_json = fullfile (fmap_dir, ['sub-' subject_ID '_dir-AP_m0scan.json']); 
m0scan_json_fid = fopen(m0scan_json); 
m0scan_json_raw = fread(m0scan_json_fid,inf); 
m0scan_json_txt = char(m0scan_json_raw'); 
fclose(m0scan_json_fid); 
m0scan_json_struct = jsondecode (m0scan_json_txt);
if isempty (m0scan_json_struct.IntendedFor)
	m0scan_json_struct.IntendedFor = string ([""]);
	m0scan_json_struct.IntendedFor(1,1) = fullfile (['bids::sub-' subject_ID], 'perf', ['sub-' subject_ID '_dir-PA_asl.nii.gz']);
	m0scan_json_fid = fopen(fullfile(fmap_dir, ['sub-' subject_ID '_dir-AP_m0scan.json']), 'w');
	fprintf(m0scan_json_fid, '%s', jsonencode(m0scan_json_struct,PrettyPrint=true));
	fclose(m0scan_json_fid);
end
varargout{1} = m0scan_json_struct;
fprintf ("DONE!\n");

% Check json file of AP fmap for CVR for "IntendedFor"
fprintf ("Checking json file of AP FMAP for CVR for IntendedFor ... ");
cvr_ap_json = fullfile (fmap_dir, ['sub-' subject_ID '_acq-APforCVR_dir-AP_epi.json']);
cvr_ap_json_fid = fopen(cvr_ap_json);
cvr_ap_json_raw = fread(cvr_ap_json_fid, inf);
cvr_ap_json_txt = char(cvr_ap_json_raw');
fclose(cvr_ap_json_fid);
cvr_ap_json_struct = jsondecode(cvr_ap_json_txt);
if isempty (cvr_ap_json_struct.IntendedFor)
	cvr_ap_json_struct.IntendedFor = string (["";""]); % initiate 2*1 string array
	cvr_ap_json_struct.IntendedFor(1,1) = fullfile (['bids::sub-' subject_ID], 'func', ['sub-' subject_ID '_task-rest_dir-PA_bold.nii.gz']);
	cvr_ap_json_struct.IntendedFor(2,1) = fullfile (['bids::sub-' subject_ID], 'func', ['sub-' subject_ID '_task-co2_dir-PA_bold.nii.gz']);
	cvr_ap_json_fid = fopen(fullfile(fmap_dir, ['sub-' subject_ID '_acq-APforCVR_dir-AP_epi.json']), 'w');
	fprintf(cvr_ap_json_fid, '%s', jsonencode(cvr_ap_json_struct, PrettyPrint=true));
	fclose(cvr_ap_json_fid);
end
varargout{2} = cvr_ap_json_struct;
fprintf ("DONE!\n");

% Check json file of PA fmap for CVR for "IntendedFor"
fprintf ("Checking json file of PA FMAP for CVR for IntendedFor ... ");
cvr_pa_json = fullfile (fmap_dir, ['sub-' subject_ID '_acq-PAforCVR_dir-PA_epi.json']);
cvr_pa_json_fid = fopen(cvr_pa_json);
cvr_pa_json_raw = fread(cvr_pa_json_fid, inf);
cvr_pa_json_txt = char(cvr_pa_json_raw');
fclose(cvr_pa_json_fid);
cvr_pa_json_struct = jsondecode(cvr_pa_json_txt);
if isempty (cvr_pa_json_struct.IntendedFor)
	cvr_pa_json_struct.IntendedFor = string (["";""]); % initiate 2*1 string array
	cvr_pa_json_struct.IntendedFor(1,1) = fullfile (['bids::sub-' subject_ID], 'func', ['sub-' subject_ID '_task-rest_dir-PA_bold.nii.gz']);
	cvr_pa_json_struct.IntendedFor(2,1) = fullfile (['bids::sub-' subject_ID], 'func', ['sub-' subject_ID '_task-co2_dir-PA_bold.nii.gz']);
	cvr_pa_json_fid = fopen(fullfile(fmap_dir, ['sub-' subject_ID '_acq-PAforCVR_dir-PA_epi.json']), 'w');
	fprintf(cvr_pa_json_fid, '%s', jsonencode(cvr_pa_json_struct, PrettyPrint=true));
	fclose(cvr_pa_json_fid);
end
varargout{3} = cvr_pa_json_struct;
fprintf("DONE!\n");

fprintf ("**FINISHED!**\n");