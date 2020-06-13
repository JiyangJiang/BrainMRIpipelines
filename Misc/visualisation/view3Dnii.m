%
% DESCRIPTION: This script displays 3D NIfTI image
%

function view3Dnii (nii)

	% read nii data
	vol = spm_vol (nii);
	data = spm_read_vols (vol);

	% display with isosurface
	isosurface (data)

	% display options
	axis tight
	camlight
	lighting gouraud
	colormap winter