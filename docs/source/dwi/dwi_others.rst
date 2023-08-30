Troubleshooting
+++++++++++++++

.. _issue with eddy_quad:

* *eddy_quad* for eddy QC will fail in *dwifslpreproc*, and throw a warning of ``dwifslpreproc: [WARNING] Error running automated EddyQC tool 'eddy_quad'; QC data written to "/home/jiyang/Work/temp/AP_eddy_QC" will be files from "eddy" only``. FSL version 6.0.5.2:dc6f4207. 

  * **Debugging:** After adding *-nocleanup* option to *dwifslpreproc* command to keep all intermediate files, and running the command ``eddy_quad dwi_post_eddy -idx eddy_indices.txt -par eddy_config.txt -b bvals -m eddy_mask.nii -f field_map.nii.gz -s slspec.txt`` separately after *dwifslpreproc* finishes. It seems there is an error regarding nibabel version from what FSL wants.

  * **Explain:** FSL installation will create a second conda if you already have a conda installation, e.g., through installing miniconda. If you, for some other software, installed nibabel to 'base' environment (which by itself is a bad idea - try to start a new environment to install a new software), this may be conflicting to the Nibabel FSL wants.

  * **Solution:** I found deactivate 'base' (or any environment) of miniconda installation (leave shell without any conda env) will allow the program to run successfully. Alternatively, activating FSL's conda should get it to work - see how you can do this in 'Further info' below.

  * **Further info:** To activate FSL's conda, run ``$FSLDIR/condabin/conda init bash``, start a new terminal and you will be in FSL's conda. To activate miniconda's conda, run ``/path/to/miniconda3/condabin/conda init bash``, and start a new terminal. You can determine which conda you are in by looking at where the 'base' environment is pointing to (i.e., path to FSL or miniconda3) when running ``conda env list``.

.. _To_dos:

To-do list
++++++++++
* To interpret eddy QC metrics, and determine whether results are good/bad. Probably need to run *eddy_squad* on cohort level.
* Confirm with MRtrix people regarding slice location error of MRtrix.
* SMS factor = 2, but SliceTiming in DICOM header indicates an interleaved acquisition without simultaneous multi-slices.
* Ask why B0's have different spatial dimension as DWI dataset.
* Generating MIF file from NIFTI (including bvec and bval) and JSON automatically converted whene exporting from scanner to Flywheel, and stored in the same folder as DICOM files. This is inspired by the fact that slice timing info is correct in these data, but not in data converted with dcm2niix.

References and further readings
+++++++++++++++++++++++++++++++
- `BATMAN tutorial for MRtrix <https://osf.io/fkyht/>`_ (Further readings in the appendix of BATMAN tutorial document are worth reading.)
- `University of Utah TBICC Neuroimaging Protocols <https://bookdown.org/u0243256/tbicc/preprocessing-diffusion-images.html>`_

Appendices
++++++++++

.. _Generating acqparam:

acqparam.txt and total readout time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

..  note::

	NOTE THAT ACQPARAMS.TXT IS AUTOMATICALLY GENERATED IF YOU RUN DWIFSLPREPRROC. YOU DO NOT NEED TO PREPARE THIS BY YOURSELF. THIS PART IF FOR YOUR REFERENCE IF YOU RUN THE ORIGINAL FSL TOPUP COMMAND.

	To prepare *acqparams.txt* for topup correction, we need to know two things: 1) the order of PE directions in the opposing PE B0 pair, and 2) *BandwidthPerPixelPhaseEncode* field in json file or DICOM header. 
	
	* PE directions.

	  * For a AP PE, the *PhaseEncodingDirection* field in json file or DICOM header should be "j-", and the first 3 digits in acqparam.txt should be "0 -1 0".
	  * For a PA PE, the *PhaseEncodingDirection* field in json file or DICOM header should be "j", and the first 3 digits in acqparam.txt should be "0 1 0".
	  * The lines in acqparam.txt should reflect the order of PE directions in the opposing PE B0 pair.

	* BandwidthPerPixelPhaseEncode

	  * For VCI and MAS2 data, *BandwidthPerPixelPhaseEncode* field in json file of B0 has a value of 19.3799992. The fourth number in acqaram.txt should be 1 / 19.3799992 = 0.052. Note that this is referred to as "total readout time" in MRtrix which is total time required for the EPI readout train (`Reference <https://mrtrix.readthedocs.io/en/dev/concepts/pe_scheme.html?highlight=readout%20time>`_). Specifically the time between the centre of the 1st echo, and centre of the last echo, in the train. This is sometimes referred to as the "FSL definition". It should be defined in seconds. This corresponds to the fourth number in acqparam.txt (see `Variable phase encoding section of this link <https://mrtrix.readthedocs.io/en/dev/concepts/pe_scheme.html?highlight=readout%20time>`_. The calculation of this readout time is detailed in `Effection echo spacing and total readout time section of this website <https://lcni.uoregon.edu/wiki/tags/fmri/>`_. 0.052 seconds is the total readout time for VCI and MAS2 data (see `Generating acqparam`_ for the calculation). Note that the calculation was based on SPM definition which should be very close to FSL definition. `MRConvert <https://idoimaging.com/programs/214>`_ can report values from both definitions.

	Therefore, acqparam.txt file for VCI and MAS2 DWI data should read as:

	| 0 -1 0 0.052
	| 0 1 0 0.052

	for *AP-then-PA_B0_pair.mif*, and

	| 0 1 0 0.052
	| 0 -1 0 0.052

	for *PA-then-AP_B0_pair.mif*.

	Reference: https://bookdown.org/u0243256/tbicc/preprocessing-diffusion-images.html#set-acqparams.txt