addpath ('C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\BrainMRIpipelines\fMRI\CVR')

etCO2_cw_csv = "C:\Users\z3402744\OneDrive - UNSW\previously on onedrive\Documents\GitHub\BrainMRIpipelines\fMRI\CVR\CVR_example\0004_2023_08_24_15_57_02_cw.csv";
processed_etCO2_ts = bmp_fmri_cvr_etco2ts_tailorSmoothResample (etCO2_cw_csv);