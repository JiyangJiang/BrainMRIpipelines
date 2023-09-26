Terminologies in Siemens imaging data
=====================================

MPR
---

*Multiplanar Reconstruction/Reformation*. Refers to the process of converting data from an imaging modality acquired in a certain plane, usually axial, into another plane (`Reference <https://www.siemens-healthineers.com/it/computed-tomography/options-upgrades/clinical-applications/syngo-3d-basic; https://radiopaedia.org/articles/multiplanar-reformation-mpr>`_).

Cor/Sag/Tra
-----------
Cor = Coronal; Sag = Saggital; Tra = Transverse (aka. Axial) (`Reference <https://www.researchgate.net/figure/Sagittal-SAG-transverse-TRA-and-coronal-COR-views-depicting-the-contrasts-of_fig2_280866288>`_).

ND
-----
*Non-Distortion corrected data*. What it means is that the gradient coils in modern scanners are optimised and not completely linear. The non-linearities are deterministic and known and can therefore be corrected. The distortion-corrected primary image has the correct geometry, but peripheral voxel may be non-square and have non-white noise, whereas the non-distortion corrected image has the raw image energy but may have geometric aberrations (think of it like aberrations in macro- or fisheye- lenses).

ns-t2prep in FLAIR
------------------
*t2prep* means T2 preparation (or magnetization preparation), a strategy for improving imaigng signal-to-noise ratio and contrast and reducing T1 weighting at high field strengths (`Reference <https://www.science.gov/topicpages/r/recovery+flair+mri>`_). *ns-t2prep* means non-selective T2 preparation.

ColFA in DWI
------------
*Colored FA map*.

TRACEW
------
*Diffusion trace-weighted imaging*.

	The trace of the diffusion tensor (Dtrace) equals (Dxx + Dyy + Dzz). Using the average value of the trace, (Dxx + Dyy + Dzz)/3, reduces the multi-directional diffusivity at each point into a single number that can be considered a consolidated apparent diffusion coefficient (ADC)…... The signal intensity of each voxel in a Trace DW image is inversely related to its ADC value. Lesions that restrict diffusion (strokes, abscesses, etc.) lower the ADC and appear bright. Conversely, substances with unrestricted diffusion and high ADC's (like cerebrospinal fluid) appear dark.” (`Reference <https://mriquestions.com/trace-vs-adc-map.html>`_).

PMU
----
*Patient monitoring unit*.