function varargout = bmp_BIDS_CHeBA_fixReversePEm0RepetitionTimePreparation (BIDS_dir, subject_ID, study)
%
% DESCEIPTION :
%   This script resolves the error from BIDS Validator regarding missing "RepetitionTimePreparation"
%   in reverse PE M0. The solution is based on the below reference.
%
% REFERENCE :
%   https://neurostars.org/t/repetitiontime-parameters-what-are-they-and-where-to-find-them/20020/8
%
% HISTORY :
%   Created by Dr. Jiyang Jiang (25th March 2014)

fmap_dir = fullfile (BIDS_dir, ['sub-' subject_ID], 'fmap');

fprintf ("Checking json file of reversed M0 for RepetitionTimePreparation ... ");
m0scan_json = fullfile (fmap_dir, ['sub-' subject_ID '_dir-AP_m0scan.json']); 
m0scan_json_fid = fopen(m0scan_json); 
m0scan_json_raw = fread(m0scan_json_fid,inf); 
m0scan_json_txt = char(m0scan_json_raw'); 
fclose(m0scan_json_fid); 
m0scan_json_struct = jsondecode (m0scan_json_txt);
fprintf ("DONE!\n");

% assign RepetitionTimePreparation field. See reference above.
m0scan_json_struct.RepetitionTimePreparation = m0scan_json_struct.RepetitionTime;

fprintf ("Writing out json file with correct RepetitionTimePreparation field ... ");
m0scan_json_fid = fopen(fullfile(fmap_dir, ['sub-' subject_ID '_dir-AP_m0scan.json']), 'w');
fprintf(m0scan_json_fid, '%s', jsonencode(m0scan_json_struct,PrettyPrint=true));
fclose(m0scan_json_fid);
fprintf ('DONE!\n');

varargout{1} = m0scan_json_struct;
