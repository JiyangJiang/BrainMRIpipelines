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
% bmp_BIDSinitiator ('/path/to/BIDS', 'other');
%

	supported_datasets = 	{
							'ADNI'
							};

	bmp_ver = bmp_version ({'BMP';'ADNI';'BIDS'});
	

	if nargin == 1

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = 'other';

		elseif ismember (varargin{1}, supported_datasets)

			BIDS_directory = pwd;

			dataset = varargin{1};

			bmp_print (bmp_convention_MATLAB ('s'), 	'%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('k'), 	'''%s''', varargin{1});
			bmp_print (bmp_convention_MATLAB ('t'), 	' dataset ');
			bmp_print (bmp_convention_MATLAB ('p'),		' ''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('t'), 	'.\n');

		else

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('e'), 'BIDS directory ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('e'), ' does not exist or is not a directory.\n');

		end

	elseif nargin < 1

		BIDS_directory = pwd;

		dataset = 'other';

	elseif nargin == 2 && ismember(varargin{2}, supported_datasets)

		if isfolder (varargin{1})
		
			BIDS_directory = varargin{1};

			dataset = varargin{2};

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('k'), '''%s''', varargin{2});
			bmp_print (bmp_convention_MATLAB ('t'), ' dataset ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('t'), '.\n');

		else

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
			bmp_print (bmp_convention_MATLAB ('e'), 'BIDS directory ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', BIDS_directory);
			bmp_print (bmp_convention_MATLAB ('e'), ' does not exist or is not a directory.\n');

		end

	else

		bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename);
		bmp_print (bmp_convention_MATLAB ('e'), 'Incorrect number of input arguments : \n');

		for i = 1 : nargin

			bmp_print (bmp_convention_MATLAB ('UnterminatedStrings'), '     - %s\n', varargin{i});

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

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', dset_desc_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (dset_desc_fnam, 'w');
			fprintf (fid, '%s\n', dset_desc_json);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');


			% CHANGES

			changes = sprintf (['1.0.0 (' char(datetime) ')\n' ...
								'  * First version created with BrainMRIpipelines.\n']);

			changes_fnam = fullfile (BIDS_directory, 'CHANGES');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', changes_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (changes_fnam, 'w');
			fprintf (fid, '%s\n', changes);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');

			

			% README

			readme = sprintf (['This is an Alzheimer''s Disease Neuroimaging Initiative (ADNI) dataset. The BIDS directory is constructed by using BrainMRIpipelines. More details about the ADNI cohort can be found at the official website (https://adni.loni.usc.edu/).\n']);

			readme_fnam = fullfile (BIDS_directory, 'README');

			bmp_print (bmp_convention_MATLAB ('s'), '%s : ', mfilename)
			bmp_print (bmp_convention_MATLAB ('t'), 'Writing out ');
			bmp_print (bmp_convention_MATLAB ('p'), '''%s''', readme_fnam);
			bmp_print (bmp_convention_MATLAB ('t'), ' ...');

			fid = fopen (readme_fnam, 'w');
			fprintf (fid, '%s\n', readme);
			fclose (fid);

			bmp_print (bmp_convention_MATLAB ('t'), ' DONE!\n');

	end

end




