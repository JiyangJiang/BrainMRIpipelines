CVR processing using MRIcloud
=============================
MRIcloud is a cloud-based platform to process MRI data. There is `a module to processing CVR data <https://braingps.mricloud.org/home>`_.

Converting Nifti to Analyze
---------------------------
..  code-block::

	mri_convert --out_type analyze4d /path/to/nifti /path/to/*.img   # This requires a valid FreeSurfer installation.