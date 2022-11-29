function bmp_BIDSconverter (varargin)
%
% DESCRIPTION
%   
%   This script aims to convert DICOM into BIDS format.
%   The first aim is to convert ASL data.
%
% USAGE
%
%   bmp_BIDSconverter ([<DICOM_directory>], Name, Value, ...)
%
%
% ARGUMENTS
%
%   DICOM_directory = Path to DICOM directory. Default is
%                     pwd.
%
%   Name-Value pairs
%
%     Name  : 'KeyFields'.
%     Value : A cell arry to specify fields in DICOM info to distinguish
%             different imaging modality. Current default is 
%             {'ProtocolName'; 'SeriesDescription'}.
%
%     Name  : 'Preset'
%     value : A string to specify if preset will be used. Currently supported
%             presets include 'ADNI3'. If no preset is to be used, use
%             'general'.
%
%
% DEPENDENCIES
% 
%   Image Processing Toolbox
%
%
% HISTORY
%
%   29 Nov 2022 - Jiyang Jiang wrote the first version.
%
%
% FUTURE DEV
%   
%   - 

	defaultDICOMdirectory        = pwd;
	defaultKeyFields             = {'ProtocolName'; 'SeriesDescription'};
	defaultPreset                = 'general';
	expectedPreset               = {'general', 'ADNI3'};

	p = inputParser;

	addOptional  (p, 'DICOM_directory',     defaultDICOMdirectory,      @isfolder);
	addParameter (p, 'KeyFields',           defaultKeyFields,           @iscell);
	addParameter (p, 'Preset',              defaultPreset,              @(x) any(validatestring(x, expectedPreset)));

	parse (p, varargin{:});


	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));

	if ~ strcmp (p.Results.Preset, 'general')
		[p, descriptions] = preset (p, p.Results.Preset);
	end

	% Get paths to all DICOM files
	all_dir = dir (fullfile (p.Results.DICOM_directory, '**'));
	all_DICOM = all_dir (~[all_dir.isdir]); % exclude folders
	clear all_dir;

	fprintf ('%s : %s has %d DICOM files.\n', mfilename, p.Results.DICOM_directory, size (all_DICOM,1));
	fprintf ('%s : Below key fileds will be used to distinguish different modalities.\n', mfilename);
	for i = 1 : size (p.Results.KeyFields, 1)
		fprintf ('  - %s\n', p.Results.KeyFields{i,1});
	end

	keyFields = cell (size (all_DICOM, 1), size (p.Results.KeyFields, 1));

	fprintf ('%s : Reading DICOM files ...', mfilename);
	for i = 1 : size (p.Results.KeyFields, 1)
		for j = 1 : size (all_DICOM, 1)
			dcm = dicominfo (fullfile (all_DICOM(j).folder, all_DICOM(j).name));
			keyFields {j,i} = dcm.(p.Results.KeyFields{i,1});
		end
	end
	fprintf (' DONE.\n');

	for i = 1 : size (p.Results.KeyFields,1)
		uniq_val = unique (keyFields (:,i));
		fprintf ('%s : Key field ''%s'' has %d different value(s):\n', mfilename, p.Results.KeyFields{i}, size(uniq_val,1));
		for j = 1 : size (uniq_val, 1)
			fprintf ('  - %s\n', uniq_val{j,1});
		end
	end




	fprintf ('%s : Finished (%s).\n', mfilename, string(datetime));
end



% preset
% ==================================================================
% currently ASL only.
%
% Refs : 
%
%    1) https://www.nature.com/articles/s41597-022-01615-9
%
% Notes :
%
%    1) There is a scaling difference between ASL and M0. It is not
%       included in BIDS fields, but expected to take into account
%       when converting to NIFTI (see Ref 1, and 
%       https://bids-standard.github.io/bids-starter-kit/tutorials/asl.html#)
function [p, descriptions] = preset (p, coh)

	switch coh

		case 'ADNI3'

			p.Results.KeyFields = {'SeriesDescription'};

			mapping = struct ("descriptions", 	struct ("data_type",       	"perf", ...
														"M0Type",			"absent", ... % seems no M0 acquired.
											  			"modalityLabel",  ""));
	end

end