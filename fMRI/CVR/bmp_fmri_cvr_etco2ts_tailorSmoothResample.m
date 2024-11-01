% ===============================================================
% DESCRIPTION
% ===============================================================
%
% This script processes end-tidal CO2 (EtCO2) 
% time course from CO2 recording. The manipulations include
% tailoring, smoothing, and resampling. This is the first
% 
%
% ===============================================================
% USAGE
% ===============================================================
%
% etCO2_cw_csv : Path to cw csv file from Nonin monitor.
%
% CO2_sampling_freq is set to 4 in the code. This is the default
% of Nonin monitor
%
% ===============================================================
% REFERENCE
% ===============================================================
%
% - CVR-MRICloud methodology paper :
%	https://doi.org/10.1371/journal.pone.0274220
%
% ===============================================================
% HISTORY
% ===============================================================
%
% - Dr. Jiyang Jiang created the 1st version on 1st Nov 2024.
%

function processed_etCO2_ts = bmp_fmri_cvr_etco2ts_tailorSmoothResample (etCO2_cw_csv)

	% etCO2_cw_csv = "C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\BrainMRIpipelines\fMRI\CVR\CVR_example\0004_2023_08_24_15_57_02_cw.csv";

	% Defaults for Nonin monitor
	CO2_sampling_freq = 4; 	% Nonin monitor has a sampling rate of 4Hz, 
							% i.e., 250 ms per sampling point

	% Read EtCO2 timeseries CSV file
	% +++++++++++++++++++++++++++++++++
	% etCO2_cw_csv_opts = detectImportOptions (etCO2_cw_csv);
	% preview (etCO2_cw_csv, etCO2_cw_csv_opts);
	etCO2_cw_table = readtable (etCO2_cw_csv);
	etCO2_ts = etCO2_cw_table.CO2_mmHg_;
	etCO2_timeinstants = datetime(strcat(string(etCO2_cw_table.Date), string(etCO2_cw_table.Time)),'InputFormat','yyy-MM-ddHH:mm:ss.SS');

	% plot (etCO2_ts)
	%
	% Visualise EtCO2 timeseries : According to Liu et al.
	% 2019 technical review :
	% 
	% Room-air : ~0 mmHg - 40 mmHg
	% Hypercapnia : 38 mmHg - (38+8 - 38+12) mmHg
	useful_range = 3700:5500; % after visualisation, tailored to 
							% period corresponding to CO2 experiment.
	etCO2_ts_tailored = etCO2_ts(useful_range); 
	etCO2_timeinstants_tailored = etCO2_timeinstants(useful_range);
	% plot (etCO2_ts_tailored)


	% Calculating sliding/moving window size
	% +++++++++++++++++++++++++++++++++++++++++++
	% - CVR-MRICloud methodology paper used
	%   a moving window size of 100 ms. However,
	%   Nonin monitor has a sampling frequency of
	%   4 Hz (250 ms). 100 ms sliding window seems
	%   to be too narrow in the Nonin case. Therefore,
	%   this was changed to 1000 ms sliding window in
	%   this script.

	% slide_window_size = 100 / (1/CO2_sampling_freq * 1000) 	% using 100-ms sliding
	% 															% window

	slide_window_size = 1000 / (1/CO2_sampling_freq * 1000); % sliding window of 1000 ms size.
	slide_window_size = 1200 / (1/CO2_sampling_freq * 1000); % sliding window of 1200 ms size.

	% Smoothing etCO2 timeseries
	etCO2_ts_tailored_smoothed = smoothdata (etCO2_ts_tailored, "movmean", slide_window_size);

	% Resampling to 10Hz
	% Signal processing toolbox is needed for function "resample"
	etCO2_ts_tailored_smoothed_resampled10Hz = resample (etCO2_ts_tailored_smoothed, etCO2_timeinstants_tailored, 10); % resample on tailored and smoothed timeseries
	etCO2_ts_tailored_resampled10Hz = resample (etCO2_ts_tailored, etCO2_timeinstants_tailored, 10); % resample directly on tailored timeseries (no smoothing)

	processed_etCO2_ts = etCO2_ts_tailored_resampled10Hz;

	figure (1)

	subplot (2, 3, 1)
	plot (etCO2_ts);
	title ('Raw EtCO2 timeseries');
	xlabel ('Timepoints');

	subplot (2, 3, 2)
	plot (etCO2_ts_tailored);
	title ('Tailored EtCO2 timeseries');
	xlabel ('Timepoints');

	subplot (2, 3, 3)
	plot (etCO2_ts_tailored_smoothed);
	title ('Tailored and smoothed EtCO2 timeseries');
	xlabel ('Timepoints');

	subplot (2, 3, 4)
	plot (etCO2_ts_tailored_smoothed_resampled10Hz);
	title ('Tailored, smoothed, and resampled to 10Hz');
	xlabel ('Timepoints');

	subplot (2, 3, 5)
	plot (etCO2_ts_tailored_resampled10Hz);
	title ('Tailored and resampled to 10Hz');
	xlabel ('Timepoints');

end