% varargin{1} = output dir. Default is same dir as gz_file.
% output dir will be created if not existing.

% fd_flag = 'file' or 'dir'
% fd_path = path to file or dir

function gunzipped_files = future_io_gunzip (fd_flag,fd_path,varargin)

curr_cmd = mfilename;

switch fd_flag

	case 'file'

		[folder,fname,ext] = fileparts (fd_path);

		if nargin == 3
			out_dir = varargin{1};
		elseif nargin == 2
			out_dir = folder;
		end


		if strcmp (ext,'.gz')
			gunzipped_files = gunzip (fd_path,out_dir);
		else
			fprintf ('%s : %s is not gzipped.', curr_cmd, fd_path);
		end

	case 'dir'

		d = dir (fullfile(fd_path,'*.gz'));

		if nargin == 3
			out_dir = varargin{1};
		elseif nargin == 2
			out_dir = fd_path;
		end

		all_gz_files = cell (size(d,1), 1);

		for i = 1 : size(d,1)
			all_gz_files{i,1} = fullfile (fd_path,d(i).name);
		end

		gunzipped_files = gunzip (all_gz_files,out_dir);

end