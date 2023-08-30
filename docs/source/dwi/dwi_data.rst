DWI data in VCI and MAS2 study
==============================

Description of dMRI data acquired for VCI and MAS2
++++++++++++++++++++++++++++++++++++++++++++++++++
VCI and MAS2 dMRI data were acquired in 4 blocks, together with B0 images acquired in reverse phase encoding directions for distortion correction:

* 4 B0 images in posterior-anterior (PA) PE direction
  
  * Series description = PA_FMAP_for_DIFFUSION

* 4 B0 images in anterior-posterior (AP) PE direction

  * Series description = AP_FMAP_for_DIFFUSION

* AP block 1 has 31 volumes including:
  
  * 3 B0's (Volume #1, #2, #20)
  * 28 B1 directions in AP PE direction including:

    * 5  * B1=1000
    * 1  * B1=1950
    * 7  * B1=2000
    * 1  * B1=2950
    * 14 * B1=3000

  * Series description = AP_BLOCK_1_DIFFUSION_30DIR

* AP block 2 has 31 volumes including:

  * 3 B0's (Volume #1, #2, #20)
  * 28 B1 directions in AP PE direction including:

    * 5  * B1=1000
    * 8  * B1=2000
    * 1  * B1=2950
    * 14 * B1=3000

  * Series description = AP_BLOCK_2_DIFFUSION_30DIR

* PA block 1 has 31 volumes including:

  * 3 B0's (Volume #1, #2, #20)
  * 28 B1 directions in PA PE direction including:

    * 5 *  B1=1000
    * 8 *  B1=2000
    * 15 * B1=3000

  * Series description = PA_BLOCK_1_DIFFUSION_30DIR

* PA block 2 has 31 volumes including:

  * 3 B0's (Volume #1, #2, #20)
  * 28 B1 directions in PA PE direction including:

    * 5 *  B1=1000
    * 8 *  B1=2000
    * 1 *  B1=2950
    * 14 * B1=3000

  * Series description = PA_BLOCK_2_DIFFUSION_30DIR

The acquisition was separated into 4 blocks so that if volumes in a certain block are of poor quality, only the gradient table in that particular block needs to be repeated, saving scanning time. This is particularly favourable for participants with cognitive decline or dementia. The sequence also sample higher b-value shells with a good number of directions. It also integrated many good acpects of HCP diffusion protocols. The sequnce takes 10 minutes to run, with each block taking 2.5 minutes. DWI data has voxel size = 2.23 * 2.23 * 2.0 mm^3, in-plane = 122 * 122, 74 slices.

..  note::

	Why some volumes have b-values slightly different from what they should be? - Refer to `this <https://mrtrix.readthedocs.io/en/dev/concepts/dw_scheme.html#b-value-shells>`_ for explanation.

Brief overview of MRtrix method
+++++++++++++++++++++++++++++++
* *Issue with the traditional tensor model of diffusion data*: In brain regions containing crossing or kissing (i.e., tangentially touching) fibers, diffusion tensor model does not perform well. This is because tensor model approaches fiber orientatin with an ellipsoid shape. In crossing-fiber regions, the orientation estimation of the tensor model will approach a sphere and thus cannot capture the orientation of two separate fibers. This is a severe problem as up to 90% of all brain image voxels contain crossing fibers.
* *The way MRtrix approach crossing-fiber issue*: Constrained Spherical Deconvolution (CSD) is proposed by MRtrix, which outperforms tensor model and other alternatives for crossing fibers.
* *Further development of MRtrix after CSD*: Following the success of CSD, MRtrix developers developed more algorithms to improve biological plausibility of fiber tracking:

  * *Anatomically Constrained Tractography (ACT)*: Rejects streamlines that end in biologically implausible tissue (e.g., CSF).
  * *Spherical-deconvolution informed filtering of tractograms (SIFT)*: Corrects for the fact that longer streamlines tend to be overestimated in tractography.
  * *multi-shell multi-tissue CSD (MSMT)*: Improves tractography in voxels containing partial volumes by exploiting the differences in b-value sensitivity of different tissue types.