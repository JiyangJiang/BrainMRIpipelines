# Processing single-PLD ASL data from OATS and SCS with FSL's BASIL GUI

*Refer to [BASIL website](https://asl-docs.readthedocs.io/en/latest/#) for full content*

## "Input Data" tab

### "Data contents" section
- **Input Image** is the image containing tag-control pairs, or subtracted images between each tag-control pair, in the 4th dimension.
- **Number of PLDs**: set to 1, because this particular example is for single-PLD data acquired in OATS and SCS.
- **Repeats**: leave as Fixed.

### "Data order" section
- **Volumes grouped by** option is to specify how data were acquired in *multi-PLD* data. For single-PLD data, select Repeats.
- **Label/Control Pairing** specifies the order of label/control (i.e., label then control, or control or label). See [table of parameters for processing ASL](#params4procASL).

### "Acquisition parameters" section
- **Labelling**: choose corresponding ASL flavour according to [table of parameters for processing ASL](#params4procASL).
- **Bolus duration (s)**: use the numbers in the [table of parameters for processing ASL](#params4procASL).
- **PLDs**: use the numbers in the [table of parameters for processing ASL](#params4procASL). PLD = TI - bolus duration.
- **Readout**: OATS and SCS used 2D readouts. Therefore, select *2D multi-slice (eg EPI)*.
- **Time per slice (ms)**: Use numbers in the [table of parameters for processing ASL](#params4procASL). Remember to convert the numbers in the unit of seconds to milliseconds.
- **Multi-band**: Untick as multi-band was not used in OATS and SCS data.







## Imaging parameters in OATS and SCS

- <a name="params4procASL">Parameters for processing ASL</a>:

|   |   |   |
|---|---|---|
| **Study**                    | OATS Wave 3 Melbourne & Brisbane  | OATS Wave 4 Sydney & SCS |
| **ASL flavour**              | Pulsed ASL                        | Pseudo-continuous ASL |
| **TI**                       | 1.8 sec                           | 3.8 sec |
| **Bolus duration**           | 0.7 sec                           | 1.8 sec |
| **Bolus arrival time**       | 0.7 sec                           | 1.3 sec |
| **Time per slice (slicedt)** | 0.046666666 sec                   | 0.0353125 sec |
| **TR**                       | 2.5 sec                           | 6 sec |
| **TE**                       | 11 msec                           | 12 msec |
| **tag/control order**        | tag then control (tc)             | control then tag (ct) |

- Other imaging parameters described in [a previous publication](https://www.frontiersin.org/articles/10.3389/fnagi.2019.00169/full). Note that SCS has identical parameters as OATS New South Wales site.

> *New South Wales Site*: PCASL scans were acquired using a Philips 3T Achieva Quasar Dual scanner (Philips Medical Systems, Netherlands). The acquisition parameters were TR/TE = 4,500/12 ms, label duration = 1,800 ms, post label delay = 2,000 ms, flip angle = 90°, imaging matrix = 128 × 128, and FOV = 240 × 240 × 95 mm3. Sixteen slices with slice thickness of 5 mm and 1 mm gap between adjacent slices were acquired. Thirty control-tag pairs (i.e., 60 volumes) were scanned, with background suppression enabled. A separate M0 image without background suppression was also acquired with TR/TE = 6,000/12 ms and the same spatial resolution as the 30 control-tag pairs. T1-weighted scans were also acquired for the postprocessing. The scanning parameters were TR/TE = 6.5/3.0 ms, flip angle = 8°, FOV = 250 × 250 × 190 mm3, spatial resolution = 1 mm isotrophic, and matrix size = 256 × 256.

> *Victoria and Queensland Sites*: Both Victoria and Queensland study centers have used the same scanner model and identical scanning parameters for ASL and T1. At both sites, PASL scans were acquired from 3T Siemens Magnetom Trio scanners, using the PICORE Q2T perfusion mode. The acquisition parameters were TR/TE = 2,500/11 ms, TI1/TI2 = 700/1,800 ms, flip angle = 90°, phase partial Fourier factor = 7/8, bandwidth = 2232 Hz/pix, imaging matrix = 64 × 64, and FOV = 192 mm. Eleven sequential 6-mm thick slices with a distance factor (i.e., gap) of 25% between adjacent slices were acquired for each volume. The first of the 101 PASL volumes was used as the M0 image. T1-weighted images were acquired in Victoria and Queensland sites with TR/TE/TI = 2,300/2.98/900 ms, flip angle = 9°, 208 sagittal slices, within plane FOV = 256 × 240 mm2, voxel size = 1 × 1 × 1 mm3, and bandwidth = 240 Hz/pix.