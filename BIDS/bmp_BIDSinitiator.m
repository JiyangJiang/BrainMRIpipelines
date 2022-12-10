function bmp_BIDSinitiator (varargin)

% INPUT ARGUMENTS
%
% bmp_BIDSinitiator ();
%
% bmp_BIDSinitiator ('/path/to/BIDS');
%
% bmp_BIDSinitiator ('ADNI');
%
% bmp_BIDSinitiator ('/path/to/BIDS', 'ADNI');
%

	supported_datasets = 	{
							'ADNI'
							};

	bmp_ver = bmp_version;
	

	if nargin == 1

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = 'other';

		elseif ismember (varargin{1}, supported_datasets)

			BIDS_directory = pwd;

			dataset = varargin{1};

			fprintf ('%s : ''%s'' dataset ''%s''.\n', mfilename, varargin{1}, BIDS_directory);

		else

			fprintf (2, '%s : [ERROR] : BIDS directory ''%s'' does not exist or is not a directory.\n', mfilename, BIDS_directory);

		end

	elseif nargin < 1

		BIDS_directory = pwd;

		dataset = 'other';

	elseif nargin == 2 && ismember(varargin{2}, supported_datasets)

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = varargin{2};

			fprintf ('%s : ''%s'' dataset ''%s''.\n', mfilename, varargin{2}, BIDS_directory);

		else

			fprintf (2, '%s : BIDS directory ''%s'' does not exist or is not a directory.\n', mfilename, BIDS_directory);

		end

	else

		fprintf (2, '%s : Incorrect number of input arguments : \n', mfilename);

		for i = 1 : nargin

			fprintf (2, '     - %s\n', varargin{i});

		end

	end



	switch dataset

		case 'ADNI'

			% dataset_description.json

			dset_desc = struct ('Name',			'ADNI', ...
								'BIDSVersion',	'1.8.0', ...
								'DataType',		'raw', ...
								'GeneratedBy',	struct ('Name',		'BrainMRIpipelines', ...
														'Version',	bmp_ver, ...
														'CodeURL',	'https://github.com/JiyangJiang/BrainMRIpipelines'));

			dset_desc_json = jsonencode(dset_desc,'PrettyPrint',true);

			dset_desc_fnam = fullfile (BIDS_directory, 'dataset_description.json');

			fid = fopen (dset_desc_fnam, 'w');
			fprintf (fid, '%s\n', dset_desc_json);
			fclose (fid);

end




