CVR processing using MRICloud
=============================
`MRIcloud <https://braingps.mricloud.org/home>`_ is a cloud-based platform to process MRI data. There is a module to processing CVR data.

Converting Nifti to Analyze
---------------------------
..  code-block::

	mri_convert --out_type analyze4d /path/to/nifti /path/to/*.img   # This requires a valid FreeSurfer installation.

Chopping CO2 trace
------------------
