Generating B1 map using Siemens product TFL sequence with hMRI
==============================================================

Installing hMRI toolbox
-----------------------
hMRI is written in MATLAB as a SPM toolbox. Follow instructions `here <https://hmri-group.github.io/hMRI-toolbox-docs/docs/getStarted/#install-the-hmri-toolbox>`_ for installation and redirecting scripts.

Creating B1 map
---------------
* In MATLAB, start SPM fMRI user interface: ``spm fmri``. Note that ``spm`` needs to be in MATLAB path.

* ``SPM Menu`` >> ``Batch`` to open *Batch Editor*.

* In *Batch Editor*, ``SPM`` >> ``Tools`` >> ``hMRI Tools`` >> ``Create B1 map``.

* **Input directory**: Specify input directory. By default, output will be written to *Results* folder in the specified input directory.

* **B1 bias correction**: Choose *tfl b1 map*, which is the sequence we used to acquire B1 map in VCI study.

* **B1 input**: Specify *anatomical* and *flip angle* maps (Note the order matters - has to be *anatomical* followed by *flip angle*). *Anatomical* and *flip angle* maps can be distinguished by looking at the *ImageComments* field in the JSON files corresponding to the ``B1map_for_T1_mapping_*.nii``. Alternatively, by visualising the maps with fsleyes - *anatomical* map looks more like a brain image.

* Click green triangle to run the module, or save batch and script.

Output files
------------
* Main results will be saved in *Results* folder within the input directory by default.

* Supplementary files are in *Results/Supplementary* sub-directory.

* ``*_B1map.[nii|json]``: Estimated B1 bias field *fT* map in percent units (p.u.).

* ``*_B1ref.[nii|json]``: Anatomical reference for B1 bias field correction.