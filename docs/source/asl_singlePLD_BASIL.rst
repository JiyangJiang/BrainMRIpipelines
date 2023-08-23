Processing single PLD ASL data from OATS 4 Sydney and SCS using BASIL GUI
=========================================================================

Older Australian Twins Study (OATS) and Sydney Centenarians Study (SCS) have acquired pulsed and pseudo-continuous ASL data. This section details the settings on BASIL GUI for processing these data.

Refer to `BASIL website <https://asl-docs.readthedocs.io/en/latest/>`_ for full content.

Before we go to BASIL GUI
~~~~~~~~~~~~~~~~~~~~~~~~~
- **Run fsl_anat on T1 images**: For example, ``for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : fsl_anat -i IN/t1 -o IN/t1``. *for_each* is `a MRtrix command for parallel computing <https://mrtrix.readthedocs.io/en/latest/tips_and_tricks/batch_processing_with_foreach.html>`_. It is useful to run commands parallelly on local computer/workstation.
- For OATS Wave 3 Melbourne and Brisbane data (i.e., pulsed ASL from Siemens), the first of the 101 PASL volumes should be extracted and used as M0 image, and the rest should be considered as tag/control pairs. *fslroi* can be used for this.
- **Segment lateral ventricles**: Run <code>/path/to/BrainMRIpipelines/misc/bmp_misc_getLatVent.m</code> to extract lateral ventricular mask for calibration. For example 

..  code-block::

    # Create 'ventricle' folder to keep intermediate files
    for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : mkdir -p IN/ventricle

    # Extract lateral ventricles
    for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : matlab -nodesktop -nodisplay -r \"addpath\(fullfile\(getenv\(\'BMP_PATH\'\),\'misc\'\)\)\;bmp_misc_getLatVent\(\'IN/m0.nii\',\'IN/t1.nii\',\'IN/ventricle\'\)\;exit\"

    # Copy ventricular mask to the same folder as asl/m0/t1
    for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : cp IN/ventricle/rventricular_mask.nii IN/vent.nii

    # Erode ventricular masks - ventricular reference masks should be conservative
    for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : fslmaths IN/vent -kernel boxv 2 -ero IN/vent_ero

"Input Data" tab
~~~~~~~~~~~~~~~~~

"Data contents" section
+++++++++++++++++++++++
- **Input Image** is the image containing tag-control pairs, or subtracted images between each tag-control pair, in the 4th dimension.
- **Number of PLDs**: set to 1, because OATS and SCS acquired single-PLD ASL data.
- **Repeats**: leave as Fixed.

"Data order" section
++++++++++++++++++++
- **Volumes grouped by** option is to specify how data were acquired in *multi-PLD* data. For single-PLD data, select Repeats.
- **Label/Control Pairing** specifies the order of label/control (i.e., label then control, or control then label). See `ASL parameter table`_.

"Acquisition parameters" section
++++++++++++++++++++++++++++++++
- **Labelling**: choose corresponding ASL flavour according to `ASL parameter table`_.
- **Bolus duration (s)**: use the numbers in the `ASL parameter table`_.
- **PLDs**: use the numbers in the `ASL parameter table`_. PLD = TI - bolus duration.
- **Readout**: OATS and SCS used 2D readouts. Therefore, select *2D multi-slice (eg EPI)*.
- **Time per slice (ms)**: Use numbers in the `ASL parameter table`_.
- **Multi-band**: Untick as OATS and SCS didn't use multiband.

"Structure" tab
~~~~~~~~~~~~~~~

"Structure" section
+++++++++++++++++++
- **Structural data from**: Choose *Existing FSL_ANAT output*.
- **Existing FSL_ANAT directory**: Use *Browse* to specify */path/to/fsl_anat/output*.

"Registration" section
++++++++++++++++++++++
- **Transform to standard space**: Tick, and select *Use FSL_ANAT*. This can be useful for applying templates and extracting regional CBF.

"Calibration" tab
~~~~~~~~~~~~~~~~~

"Enable Calibration" section
++++++++++++++++++++++++++++
- **Enable calibration**: *Tick* to enable calibration.
- **Calibration image**: Select the corresponding M0 map.
- **M0 Type**: *Proton Density (long TR)*. See references_.
- **Sequence TR (s)**: Refer to *TR of M0* in the `ASL parameter table`_.
- **Calibration Gain**: Set to 1. A few FSL email threads suggest calibration gain of 10 is a good number to start with for ASL tag/control pairs acquired with background suppression (see references_). However, this leads to abnormally low CBF (~ 2-3) in examples if OATS Wave 4 Sydney data. After experiments, it seems setting the gain to 1 gives reasonable CBF estimates.
- **Calibration mode**: Choose *Reference Region* (Note this is not compliant with White paper, but in many casese voxelwise and reference mask methods are equivalent).

"Reference tissue" section
++++++++++++++++++++++++++++
- **Type**: Choose *CSF*.
- **Mask**: *Tick*, and select the ventricular mask generated in "Before we go to GUI" section. Try both full and eroded ventricular masks. In theory, reference masks should be conservative. The only concern may be an empty mask after erosion. So it is a good idea to visualise eroded masks.
- **Sequence TE (ms)**: Refer to *TE of both M0 and tag/control* in the `ASL parameter table`_.
- **Reference T1 (s), Reference T2 (ms), and Blood T2 (ms)**: Leave them as default values.
- **Reference image for sensitiviey correction**: untick.

"Distortion Correction" tab
~~~~~~~~~~~~~~~~~~~~~~~~~~~
- *untick* 'Apply distortion correction', as no additional images for distortion correction of ASL/M0 were acquired in OATS or SCS.
- Click *Next* to ignore distortion correction for now. Also see `Future work`_ below.

"Analysis" tab
~~~~~~~~~~~~~~
"Basic analysis options" section
++++++++++++++++++++++++++++++++
- **Output Derectory**: Path to save output.
- **User-specified brain mask**: *Untick* to let BASIL create brain mask. Also see `Future work`_ below.

"Initial parameter values" section
++++++++++++++++++++++++++++++++++
- **Arterial Transit Time (s)**: For pulsed ASL data (OATS Wave 3 Melbourne and Brisbane), set Arterial Transit Time to 0.7 sec. For pseudo-continuous ASL data (OATS Wave 4 Sydney and SCS), set Arterial Transit Time to 1.3 sec. Note that *white paper mode* will reset this Arterial Transit Time to 0.
- **T1 (s)**: T1 for tissue. Use default 1.3 sec. Note that *white paper mode* will set this T1 for tissue to 1.65 sec.
- **T1b (s)**: T1 for blood. Use default 1.65 sec. *white paper mode* will also set this T1 for blood to 1.3 sec.
- **Inversion Efficiency**: 0.85 for pseudo-continuous ASL (OATS Wave 4 Sydney and SCS), and 0.98 for pulsed ASL (OATS Wave 3 Melbourne and Brisbane). These values were taken from white paper.

"Analysis options" section
++++++++++++++++++++++++++
- **Adaptive spatial regularisation on perfusion**: *tick*. This option applies a spatial prior to the perfusion image during estimation, thus making use of neighbourhood information. This is strongly recommended.
- **Incorporate T1 uncertainty**: *untick*. This option permits voxelwise variability in the T1 values, this will primiarly be reflected in the variance images for the estimated parameters, don't expect accurate T1 maps from conventional ASL data.
- **Include macro vascular component**: *untick*. This option corrects for arterial or macrovascular contamination, and it suits where the data have multi-PLD (even where flow suppresion has been applied). Untick because OATS and SCS ASL data are single PLD.
- **Fix label duration**: *tick* for psudo-continuous ASL data (OATS Wave 4 Sydney and SCS). *untick* for pulsed ASL data (OATS Wave 3 Melbourne and Brisbane). This option takes the value for the label duration from the Input Data tab as fixed, turn off to estimate this from the data (the value on the data tab will be used as prior information in that case). You are most likely to want to deselect the option for pASL data, particularly where QUIPSSII/Q2TIPS has not been used to fix the label duration.
- **Partial Volume Correction**: *tick*. This option correct for the different contributions from GM, WM and CSF to the perfusion image. This will produce separate grey and white matter perfusion maps.
- **Motion Correction**: *tick*. This option uses *mcflirt* to perform motion correction of ASL data (and the calibration image).
- **Exchange/Dispersion model**: Leave as default.

"White paper mode" section
++++++++++++++++++++++++++
- **Check compatibility**: *untick* to run with the options/parameters set above. Can then *tick*, *View issues*, and *Make compatible* to run in white paper mode and compare with previous results.

Command line
~~~~~~~~~~~~
The above settings translate to below command for an OATS Wave 4 Sydney (pseudo-continuous ASL) example. This can be used to prepare scripts for batch processing.

.. code-block::

   oxford_asl -i /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/test/12301/asl.nii --iaf ct --ibf rpt --casl --bolus 1.8 --rpts 30 --slicedt 0.03531 --tis 3.8 --fslanat /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/test/12301/t1.anat -c /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/test/12301/m0.nii --cmethod single --tr 6 --cgain 1 --tissref csf --csf /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/test/12301/vent.nii --t1csf 4.3 --t2csf 750 --t2bl 150 --te 12 -o /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/test/12301/basil_output --bat 1.3 --t1 1.3 --t1b 1.65 --alpha 0.85 --spatial --fixbolus --mc --pvcorr --artoff


Expected outputs
~~~~~~~~~~~~~~~~
- *perfusion.nii.gz*: Perfusion image providing blood flow in relative (scanner) units.
- *perfusion_calib.nii.gz*: Calibrated perfusion image providing blood flow in absolute units (ml/100g/min).
- Results in *native ASL*, *structural*, and *standard space* will appear in the output directory within separate subdirectories.
- Summary measures of perfusion will be available in *native_space* subdirectory.
- *M0.txt* in *calib* subdirectory: The estimated M0 value from arterial blood.
- *refmask.nii.gz* in *calib* subdirectory: Reference tissue mask for calibration.

Quality control
~~~~~~~~~~~~~~~
- In the BASIL GUI, after loading ASL tag/control pairs and clicking *Update* in the data preview, you should see a pattern of higher intensities in GM than WM, corresponding to higher perfusion in GM than WM.
- Whole brain average CBF is normally lower than 60, typically 30-40 (`ref <https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1408&L=FSL&P=R86444>`_).
- Whole brain GM CBF (if you are looking at native_space subdirectory at perfusion_calib_gm_mean.txt) should be in the range of 30-50. If you are looking at partial volume corrected results the equivalent value should be a bit higher, reflecting the correction that has been done. (`ref <https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2004&L=FSL&P=R91652>`_). White paper advises that GM CBF should be anywhere between 40-100 for healthy adult controls (not elderly).
- Whole brain WM CBF (perfusion_calib_wm_mean.txt in native_space subdirectory) should be in the range of 10-20 (`ref <https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2004&L=FSL&P=R91652>`_).
- If you are examining images, then WM CBF should be of clearly lower intensity than GM CBF.
- Refernce tissue mask (*refmask.nii.gz* in *calib* subdirectory) should be a conservative lateral ventricular CSF mask of M0 image.

.. _ASL parameter table:

ASL parameters
~~~~~~~~~~~~~~
+------------------------------------------------+--------------------------------------+------------------------------+
| **Study**                                      | **OATS Wave 3 Melbourne & Brisbane** | **OATS Wave 4 Sydney & SCS** |
+------------------------------------------------+--------------------------------------+------------------------------+
| **ASL flavour**                                | 2D pulsed ASL                        | 2D pseudo-continuous ASL     |
+------------------------------------------------+--------------------------------------+------------------------------+
| **TI**                                         | 1.8 sec                              | 3.8 sec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Bolus duration**                             | 0.7 sec                              | 1.8 sec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Post-labelling delay (TI - bolus duration)** | 1.1 sec                              | 2.0 sec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Bolus arrival time**                         | 0.7 sec                              | 1.3 sec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Time per slice (slicedt)**                   | 46.67 msec                           | 35.31 msec                   |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Multi-band**                                 | No                                   | No                           |
+------------------------------------------------+--------------------------------------+------------------------------+
| **TR of tag/control pairs**                    | 2.5 sec                              | 4.5 sec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **TR of M0**                                   | 2.5 sec                              | 6 sec                        |
+------------------------------------------------+--------------------------------------+------------------------------+
| **TE of both M0 and tag/control**              | 11 msec                              | 12 msec                      |
+------------------------------------------------+--------------------------------------+------------------------------+
| **tag/control order**                          | tag then control                     | control then tag             |
+------------------------------------------------+--------------------------------------+------------------------------+
| **M0 type**                                    | Proton Density (long TR)             | Proton Density (long TR)     |
+------------------------------------------------+--------------------------------------+------------------------------+
| **Calibration gain**                           | 1?                                   | 1                            |
+------------------------------------------------+--------------------------------------+------------------------------+


Other imaging parameters described in `a previous publication <https://www.frontiersin.org/articles/10.3389/fnagi.2019.00169/full>`_. Note that SCS has identical parameters as OATS New South Wales site.

   *New South Wales Site*: PCASL scans were acquired using a Philips 3T Achieva Quasar Dual scanner (Philips Medical Systems, Netherlands). The acquisition parameters were TR/TE = 4,500/12 ms, label duration = 1,800 ms, post label delay = 2,000 ms, flip angle = 90°, imaging matrix = 128 × 128, and FOV = 240 × 240 × 95 mm3. Sixteen slices with slice thickness of 5 mm and 1 mm gap between adjacent slices were acquired. Thirty control-tag pairs (i.e., 60 volumes) were scanned, with background suppression enabled. A separate M0 image without background suppression was also acquired with TR/TE = 6,000/12 ms and the same spatial resolution as the 30 control-tag pairs. T1-weighted scans were also acquired for the postprocessing. The scanning parameters were TR/TE = 6.5/3.0 ms, flip angle = 8°, FOV = 250 × 250 × 190 mm3, spatial resolution = 1 mm isotrophic, and matrix size = 256 × 256.

   *Victoria and Queensland Sites*: Both Victoria and Queensland study centers have used the same scanner model and identical scanning parameters for ASL and T1. At both sites, PASL scans were acquired from 3T Siemens Magnetom Trio scanners, using the PICORE Q2T perfusion mode. The acquisition parameters were TR/TE = 2,500/11 ms, TI1/TI2 = 700/1,800 ms, flip angle = 90°, phase partial Fourier factor = 7/8, bandwidth = 2232 Hz/pix, imaging matrix = 64 × 64, and FOV = 192 mm. Eleven sequential 6-mm thick slices with a distance factor (i.e., gap) of 25% between adjacent slices were acquired for each volume. The first of the 101 PASL volumes was used as the M0 image. T1-weighted images were acquired in Victoria and Queensland sites with TR/TE/TI = 2,300/2.98/900 ms, flip angle = 9°, 208 sagittal slices, within plane FOV = 256 × 240 mm2, voxel size = 1 × 1 × 1 mm3, and bandwidth = 240 Hz/pix.

.. _future work:

Future work
~~~~~~~~~~~
- To confirm whether OATS Wave 4 Melbourne has the same parameters as OATS Wave 3 Melbourne and Brisbane.
- To confirm calibration gain of 1 for OATS Wave 3 Melbourne and Brisbane (i.e., no background suppression).
- "Distortion correction" tab: Can Synb0-DISCO be used to correct for distortion?
- "Analysis" tab: Compare BASIL-generated brain mask with MRtrix's dwi2mask and T1 brain mask from fsl_anat.

Known issues
~~~~~~~~~~~~
- It seems when running *asl_calib* to calibrate with CSF as reference, a warning of "*WARNING:: Inconsistent orientations for individual images in pipeline. Will use voxel-based orientation which is probably incorrect - \*PLEASE CHECK\*!*" will appear. Have had a look at ventricular mask superimposed on M0 map, and found no issue.
- Notice that since automated cropping was conducted in *fsl_anat*, all BASIL results in structural space are not in the original T1 space, but cropped T1 space. If, for ROI analyses, ROIs are defined in original T1 space, *flirt* registration may be needed, or see if the same cropping can be applied to the ROI template in original T1 space. fsl_anat cropping can be avoided by including *--nocrop* flag.


.. _references:

References
~~~~~~~~~~
+ M0 type normally set to long TR:
   * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2002&L=FSL&P=R60377
   * https://asl-docs.readthedocs.io/en/latest/gui_userguide.html#calibration
+ Initial calibration gain set to 10:
   * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1905&L=FSL&P=R86460
   * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2004&L=FSL&P=R91652
   * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1904&L=FSL&P=R57828


