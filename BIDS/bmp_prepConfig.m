function bmp_prepConfig (varargin)
%
% DESCRIPTION
%   
%   This script aims to output unique values for fields in
%   DICOM header.
%
% USAGE
%
%   bmp_prepConfig ([<DICOM_directory>], Name, Value)
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
%             {'SeriesDescription'}.
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
	defaultKeyFields             = {'SeriesDescription'};

	p = inputParser;

	addOptional  (p, 'DICOM_directory',     defaultDICOMdirectory,      @isfolder);
	addParameter (p, 'KeyFields',           defaultKeyFields,           @iscell);

	parse (p, varargin{:});


	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));


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
