function bmp_ver = bmp_version (varargin)

	curr_ver {1,1} = '0.0.1 (internal testing)';
	curr_ver {2,1} = '20221210';
	curr_ver {3,1} = sprintf (	[ ... 
								'Release note line 1\n'... 
								'Release note line 2\n'... 
								]);

	if nargin == 1 && strcmp(varargin{1},'verbose')

		bmp_ver = sprintf (['%s\n%s\n%s'], curr_ver{1,1}, curr_ver{2,1}, curr_ver{3,1});

	else

		bmp_ver = curr_ver{1,1};

	end

end

