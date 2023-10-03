DCE-MRI data in VasMarker study - explained
===========================================

The following data are acquired in VasMarker study for DCE-MRI:

* MP2RAGE for T1 relaxometry. See `this link <https://www.mriquestions.com/mp-rage-v-mr2rage.html>`_ for more info.

  * **t1_mp2rage_sag_0.8x0.8x2_BW240_INV1_*.nii:** Inversion 1. First gradient echo image at TI1.
  * **t1_mp2rage_sag_0.8x0.8x2_BW240_INV2_*.nii:** Inversion 2. Second gradient echo image at TI2.
  * **t1_mp2rage_sag_0.8x0.8x2_BW240_T1_Images_*.nii:** T1 map.
  * **t1_mp2rage_sag_0.8x0.8x2_BW240_UNI_Images_*.nii:** Uniform T1-weighted image (UNIT1). In contrast to conventional MPRAGE sequence, the magnetisation-prepared 2 rapid acquisition gradient echoes (MP2RAGE) sequence can produce more homogeneous T1-weighted image, termed uniform image, by combining two different gradient echo images with two different inversion times (`Reference <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0210803#:~:text=In%20contrast%20to%20the%20MPRAGE,)%20%5B17%E2%80%9319%5D.>`_).

* B1 map

  * **2 * B1Map_for_T1_mapping_*.nii:** The purpose of acquiring a B1 map before DCE dataset is to determine the actual flip angle (in VIF or tissue voxels) used in the DCE dataset, which will be different to the nominal flip angle due to B1+ variation.

..  note::

    The way VCI study used to generate B1+ map is through TFL B1 mapping. Below is cited from (*Karsen Tabelow, et al. Neuroimage 194 (2019) 191-210*).

        TFL B1 mapping (Chung et al., 2010) - For this method, the batch interface requests a pair of images (one anatomical image and one flip angle map, in that order) from a service sequence by Siemens (version available from VE11 on) based on a turbo flash (TFL) sequence with and without a pre-saturation pulse (Chung et al., 2010). The flip angle map used as input contains the measured flip angle multiplied by 10. After rescaling (p.u.) and smoothing, the output fT map is ready to be
        used for B1 transmit bias correction.

* Dynamic T1w images

  * **2 * t1_vibe_sag_DCE_2mm_XL_FOV_40s_temporal_res_*.nii**:
  * **2 * t1_vibe_sag_DCE_2mm_XL_FOV_40s_temporal_res_ND_*.nii:** *ND* means Non-Distortion-corrected. See :ref:`ND` section in Siemens terminologies.

..  note::

	For T1 mapping, any accurate T1 mapping techniques that work in tissue and flowing blood is fine. DESPOT1-HIFI is different to variable flip angles and is more accurate. MP2RAGE may work fine but it's necessary to add a B1 mapping sequence to determine the actual flip angle (in VIF or tissue voxels) used in the DCE dataset, which will be different to the nominal flip angle due to B1+ variation. DESPOT1-HIFI corrects for B1 effects and generates a flip angle map.

..  note::

	Accuracy in flowing blood for the DCE VIF (superior sagittal sinus) needs to be checked - T1 values there need to look reasonable.

CBV/CBF from DCE-MRI
--------------------
Blood plasma volume fraction (vP) can be calculated from DCE-MRI. ``CBV = vP / (1 - Hct)``.

CBF can be measured with some protocol modifications, which adds complexity. In particular, it requires high temporal resolution during the bolus first pass. The faster the injection and the higher the CBF, the faster the sampling. To achieve this, need to, e.g., reduce spatial coverage/number of slices, reduce spatial resolution, increase acceleration factors, use partial fourier/elliptical sampling, etc. There's also a view-sharing technique (it's called TWIST on Siemens scanners) that might be of use. For analysis, there're two possibilities: 1) Larsson (https://pubmed.ncbi.nlm.nih.gov/19780145/) which uses model-free deconvolution to measure CBF and used the Patlak model to measure BBB leakage. 2) another approach is to fit a model that includes CBF, such as the 2-compartment exchange model (achievable with `Michael Thrippleton code <https://github.com/mjt320/SEPAL>`_)

Known issues with data
----------------------

Ringing artefacts of all dynamic T1w volumes
++++++++++++++++++++++++++++++++++++++++++++
The reason for the rings could be because of low resolution. To post-process it, unringing such as `this tool <https://bitbucket.org/reisert/unring/src/master/>`_ can be applied. `Some solutions <https://radiopaedia.org/articles/gibbs-and-truncation-artifacts#:~:text=Gibbs%20artifact%2C%20also%20known%20as,and%20the%20skull%2Dbrain%20interface>`_ such as increasing matrix size, using smoothing filters, or fat suppression, can be applied during data acquisition. However, since this is a dynamic sequence, image should be acquired quickly to reflect status at a time-point.

Moreover, If you look into the supplement of the 2016 Heye paper, you can also see some ringing in the ktrans image. They refer to it as low-level motion artefact. So it seems to be a general problem, from this paper: 

	Finally, the DCE-MRI data in this study has been analysed at the level of ROIs rather than voxels. This approach was selected due to the low contrast-to-noise ratio in single voxels and due to the influence of artefacts (e.g., Gibbs ringing and motion), which, while typically at the level of only a few percent, have a similar magnitude to the small contrast-induced signal changes and therefore have a disproportionate influence on voxel-wise pharmacokinetic parameters (Supplementary Fig. 2). Averaging over an ROI reduces the influence of noise and artefact, enabling more robust measurement of background BBB status, especially in normal-appearing tissue where signal changes are small. However, a limitation of this approach is that it does not allow the detection of local variation in BBB function.