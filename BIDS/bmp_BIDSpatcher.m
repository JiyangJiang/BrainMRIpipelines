function bmp_BIDSpatcher (varargin)
%
%
% varargin{1} = BIDS directory (default = pwd)
%
% varargin{2} = is ADNI? (true/false) (default = true)
%
%

	if nargin >= 1 && isfolder(varargin{1})

		BIDS_directory = varargin{1};

	else

		BIDS_directory = pwd;

	end

	if nargin == 2 && islogical(varargin{2})

		isADNI = varargin{2};

	else

		isADNI = true;

	end


	% asl context tsv
	asl_context_tsv (BIDS_directory, isADNI);

	% if exist tsv (clinica) compare with real nii
	% if not create
	% asl context tsv

end



function asl_context_tsv (BIDS_directory, isADNI)

	fprintf ('%s : Creating *_aslcontext.tsv files.\n', mfilename);

	asl_data = bids.query(BIDS_directory,'data','suffix','asl');

	fprintf ('%s : %d ASL scans found.\n', mfilename, size(asl_data,1));

	for i = 1 : size(asl_data,1)

		[curr_dir,curr_fnam,curr_ext] = fileparts(asl_data{i,1});

		fprintf ('%s : Creating aslcontext tsv file for %s ... ', mfilename, [curr_fnam curr_ext]);

		if isADNI

		else

		end

	end

end