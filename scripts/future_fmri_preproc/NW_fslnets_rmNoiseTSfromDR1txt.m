

% DESCRIPTION
% --------------------------------------------------------
%
% remove noise time series from DR1 txt files, so that
% they will not be considered in FSLNets analyses. 
%
% !!! This script is optional. You could remove the unwanted
%     timeseries here or in FSLNets by passing to ts.DD
%
%
% USAGE
% --------------------------------------------------------
%
% dr_dir = dual regression output directory.
%
% ts2keep = vector with the indices of timeseries to KEEP.
%
% varargin{1} = 'yesRmWMCSFts' if remove WM and CSF timeseries
%               which are appended to the last two columns
%               in order to control for physiological noise
%               in dual regression. This was done in my
%               meta-ICA code.
%

function NW_fslnets_rmNoiseTSfromDR1txt (dr_dir, ts2keep, varargin)

% dr_dir='/data2/jiyang/grp_cmp_lt80_over90_yesWMCSFregts/groupICA/grp_cmp_adj4sexEdu_dualReg_rand_results_metaICA';

startdir = pwd;

cd (dr_dir);

if exist ('orig_dr1_txt', 'dir') == 7
	
	% generate random string
	symbols = ['a':'z' 'A':'Z' '0':'9'];
	MAX_ST_LENGTH = 50;
	stLength = randi(MAX_ST_LENGTH);
	nums = randi(numel(symbols),[1 stLength]);
	st = symbols (nums);

	% zip current .txt
	zip (['txt_' st '.zip'], '*.txt');

	% delete current .txt
	delete ('*.txt');

	% move original dr1 txt to dr folder
	movefile ('orig_dr1_txt/*.txt', dr_dir);

else
	mkdir ('orig_dr1_txt');
end

dr1txt_list = dir ('*.txt');

for i = 1 : size (dr1txt_list, 1)

	% read timeseries data from dr1 txt
	ts_orig = dlmread (dr1txt_list(i).name);

	% remove WM and CSF timeseries
	if (nargin == 3) && strcmp (varargin{1}, 'yesRmWMCSFts')
		% remove the last two columns (i.e. WM and CSF timeseries)
		ts = ts_orig (:, 1 : (size (ts_orig, 2) - 2));
	else
		ts = ts_orig;
	end


	% remove specified timeseries
	if (size (ts2keep, 2) ~= 0) && (max (ts2keep) <= size (ts, 2))
		ts = ts (:, ts2keep);
	end

	% write the noise-removed timeseries to output
	[~, txt_filename, ~] = fileparts (dr1txt_list(i).name);
	dlmwrite([txt_filename '_noiseRm.txt'], ts, 'delimiter', '\t');

	% move orig dr1 txt to orig_dr1_txt folder
	movefile (dr1txt_list(i).name, 'orig_dr1_txt');
end

cd (startdir)