# Processing single-PLD ASL data from OATS and SCS with FSL's BASIL GUI

*Refer to [BASIL website](https://asl-docs.readthedocs.io/en/latest/#) for full content*

## Before we go to GUI
- **Run fsl_anat on T1 images**: For example, <code>for_each -nthreads 8 1* : fsl_anat -i IN/t1.nii.gz -o IN/t1</code>. *for_each* is [a MRtrix command for parallel computing](https://mrtrix.readthedocs.io/en/latest/tips_and_tricks/batch_processing_with_foreach.html). It is useful to run commands parallelly on local computer/workstation.
- For OATS Wave 3 Melbourne and Brisbane data (i.e., pulsed ASL from Siemens), the first of the 101 PASL volumes should be extracted and used as M0 image, and the rest should be considered as tag/control pairs. *fslroi* can be used for this.
- **Segment lateral ventricles**: Run <code>/path/to/BrainMRIpipelines/misc/bmp_misc_getLatVent.m</code> to extract lateral ventricular mask for calibration. For example 
```
for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : mkdir -p IN/ventricle
for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : matlab -nodesktop -nodisplay -r \"addpath\(fullfile\(getenv\(\'BMP_PATH\'\),\'misc\'\)\)\;bmp_misc_getLatVent\(\'IN/m0.nii\',\'IN/t1.nii.gz\',\'IN/ventricle\'\)\;exit\"
for_each -nthreads 8 /srv/scratch/cheba/Imaging/ow4sydAndScsAsl/1* : cp IN/ventricle/rventricular_mask.nii IN/vent.nii
```

## "Input Data" tab

### "Data contents" section
- **Input Image** is the image containing tag-control pairs, or subtracted images between each tag-control pair, in the 4th dimension.
- **Number of PLDs**: set to 1, because this particular example is for single-PLD data acquired in OATS and SCS.
- **Repeats**: leave as Fixed.

### "Data order" section
- **Volumes grouped by** option is to specify how data were acquired in *multi-PLD* data. For single-PLD data, select Repeats.
- **Label/Control Pairing** specifies the order of label/control (i.e., label then control, or control then label). See [table of parameters for processing ASL](#params4procASL).

### "Acquisition parameters" section
- **Labelling**: choose corresponding ASL flavour according to [table of parameters for processing ASL](#params4procASL).
- **Bolus duration (s)**: use the numbers in the [table of parameters for processing ASL](#params4procASL).
- **PLDs**: use the numbers in the [table of parameters for processing ASL](#params4procASL). PLD = TI - bolus duration.
- **Readout**: OATS and SCS used 2D readouts. Therefore, select *2D multi-slice (eg EPI)*.
- **Time per slice (ms)**: Use numbers in the [table of parameters for processing ASL](#params4procASL).
- **Multi-band**: Untick as OATS and SCS didn't use multiband.

## "Structure" tab
- **Structural data from**: Choose *Existing FSL_ANAT output*.
- **Existing FSL_ANAT directory**: Use *Browse* to specify */path/to/fsl_anat/output*.
- **Transform to standard space**: Tick, and select *Use FSL_ANAT*. This can be useful for applying templates and extracting regional CBF.

## "Calibration" tab
- **Enable calibration**: Tick to enable calibration.
- **Calibration image**: Select the corresponding M0 map.
- **M0 Type**: *Proton Density (long TR)*. See references.
- **Sequence TR (s)**: Refer to *TR of M0* in the [table of parameters for processing ASL](#params4procASL).
- **Calibration mode**: Choose *Reference Region* (Note this is not compliant with White paper, but in many casese voxelwise and reference mask methods are equivalent).
- **Type**: Choose *CSF*.
- **Mask**: Tick, and select the ventricular mask generated in "Before we go to GUI" section, e.g. rventricular_mask.nii.
- **Sequence TE (ms)**: Refer to *TE of both M0 and tag/control* in the [table of parameters for processing ASL](#params4procASL).
- **Reference T1 (s), Reference T2 (ms), and Blood T2 (ms)**: Leave them as default values.
- **Reference image for sensitiviey correction**: untick.





## Imaging parameters in OATS and SCS

- <a name="params4procASL">Parameters for processing ASL</a>:

|   |   |   |
|---|---|---|
| **Study**                         | OATS Wave 3 Melbourne & Brisbane | OATS Wave 4 Sydney & SCS |
| **ASL flavour**                   | 2D pulsed ASL                    | 2D pseudo-continuous ASL |
| **TI**                            | 1.8 sec                          | 3.8 sec                  |
| **Bolus duration**                | 0.7 sec                          | 1.8 sec                  |
| **Bolus arrival time**            | 0.7 sec                          | 1.3 sec                  |
| **Time per slice (slicedt)**      | 46.67 msec                       | 35.31 msec               |
| **Multi-band**                    | No                               | No                       |
| **TR of tag/control pairs**       | 2.5 sec                          | 4.5 sec                  |
| **TR of M0**                      | 2.5 sec                          | 6 sec                    |
| **TE of both M0 and tag/control** | 11 msec                          | 12 msec                  |
| **tag/control order**             | tag then control                 | control then tag         |
| **M0 type**                       | Proton Density (long TR)         | Proton Density (long TR) |
| **Calibration gain**              | 1                                | 10                       |



- Other imaging parameters described in [a previous publication](https://www.frontiersin.org/articles/10.3389/fnagi.2019.00169/full). Note that SCS has identical parameters as OATS New South Wales site.

> *New South Wales Site*: PCASL scans were acquired using a Philips 3T Achieva Quasar Dual scanner (Philips Medical Systems, Netherlands). The acquisition parameters were TR/TE = 4,500/12 ms, label duration = 1,800 ms, post label delay = 2,000 ms, flip angle = 90°, imaging matrix = 128 × 128, and FOV = 240 × 240 × 95 mm3. Sixteen slices with slice thickness of 5 mm and 1 mm gap between adjacent slices were acquired. Thirty control-tag pairs (i.e., 60 volumes) were scanned, with background suppression enabled. A separate M0 image without background suppression was also acquired with TR/TE = 6,000/12 ms and the same spatial resolution as the 30 control-tag pairs. T1-weighted scans were also acquired for the postprocessing. The scanning parameters were TR/TE = 6.5/3.0 ms, flip angle = 8°, FOV = 250 × 250 × 190 mm3, spatial resolution = 1 mm isotrophic, and matrix size = 256 × 256.

> *Victoria and Queensland Sites*: Both Victoria and Queensland study centers have used the same scanner model and identical scanning parameters for ASL and T1. At both sites, PASL scans were acquired from 3T Siemens Magnetom Trio scanners, using the PICORE Q2T perfusion mode. The acquisition parameters were TR/TE = 2,500/11 ms, TI1/TI2 = 700/1,800 ms, flip angle = 90°, phase partial Fourier factor = 7/8, bandwidth = 2232 Hz/pix, imaging matrix = 64 × 64, and FOV = 192 mm. Eleven sequential 6-mm thick slices with a distance factor (i.e., gap) of 25% between adjacent slices were acquired for each volume. The first of the 101 PASL volumes was used as the M0 image. T1-weighted images were acquired in Victoria and Queensland sites with TR/TE/TI = 2,300/2.98/900 ms, flip angle = 9°, 208 sagittal slices, within plane FOV = 256 × 240 mm2, voxel size = 1 × 1 × 1 mm3, and bandwidth = 240 Hz/pix.

## Known issues
- To confirm whether OATS Wave 4 Melbourne has the same parameters as OATS Wave 3 Melbourne and Brisbane.
- To confirm calibration gain of 1 for OATS Wave 3 Melbourne and Brisbane (i.e., no background suppression).

## References
* M0 type normally set to long TR:
  * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2002&L=FSL&P=R60377
  * https://asl-docs.readthedocs.io/en/latest/gui_userguide.html#calibration
* Initial calibration gain set to 10:
  * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1905&L=FSL&P=R86460
  * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2004&L=FSL&P=R91652
  * https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1904&L=FSL&P=R57828