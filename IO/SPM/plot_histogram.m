nii = '11085pn_flair.nii';

% read nii
vol = spm_vol (nii);
data = spm_read_vols (vol);

% plot histogram
histogram (data (data > 0), 100)