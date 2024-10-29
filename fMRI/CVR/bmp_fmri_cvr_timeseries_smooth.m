% DESCRIPTION
%
% This script generates end-tidal CO2 (EtCO2) 
% time course from CO2 recording.
%
% REFERENCE
%
% - CVR-MRICloud methodology paper :
%	https://doi.org/10.1371/journal.pone.0274220
%

time_series = 

% Defaults for Nonin monitor
CO2_sampling_freq = 4 	% Nonin monitor has a sampling rate of 4Hz, 
						% i.e., 250 ms per sampling point

% Calculating sliding/moving window size
% +++++++++++++++++++++++++++++++++++++++++++
% - CVR-MRICloud methodology paper used
%   a moving window size of 100 ms. However,
%   Nonin monitor has a sampling frequency of
%   4 Hz (250 ms). 100 ms sliding window seems
%   to be too narrow in the Nonin case. Therefore,
%   this was changed to 1000 ms sliding window in
%   this script.

% slide_window_size = 100 / (1/freq * 1000) 	% using 100-ms sliding
% 											% window

slide_window_size = 1000 / (1/freq * 1000) % sliding window of 1000 ms size.

smoothdata (time_series, 1, "movmean"...
			"")