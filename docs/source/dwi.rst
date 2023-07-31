Diffusion-weighted imaging
--------------------------

Multi-shell diffusion-weighted imaging data with MRtrix3 and FSL
================================================================
This section records steps for processing multi-shell dMRI data using MRtrix3 and FSL. The VCI and MAS2 study data will suit the methods described here.

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

The acquisition was separated into 4 blocks so that if volumes in a certain block are of poor quality, only the gradient table in that particular block needs to be repeated, saving scanning time. This is particularly favourable for participants with cognitive decline or dementia. The sequence also sample higher b-value shells with a good number of directions. It also integrated many good acpects of HCP diffusion protocols. The sequnce takes 10 minutes to run, with each block taking 2.5 minutes. Voxel size = 2.23 * 2.23 * 2.0 mm^3, in-plane = 122 * 122, 74 slices.

Brief overview of MRtrix method
+++++++++++++++++++++++++++++++
* *Issue with the traditional tensor model of diffusion data*: In brain regions containing crossing or kissing (i.e., tangentially touching) fibers, diffusion tensor model does not perform well. This is because tensor model approaches fiber orientatin with an ellipsoid shape. In crossing-fiber regions, the orientation estimation of the tensor model will approach a sphere and thus cannot capture the orientation of two separate fibers. This is a severe problem as up to 90% of all brain image voxels contain crossing fibers.
* *The way MRtrix approach crossing-fiber issue*: Constrained Spherical Deconvolution (CSD) is proposed by MRtrix, which outperforms tensor model and other alternatives for crossing fibers.
* *Further development of MRtrix after CSD*: Following the success of CSD, MRtrix developers developed more algorithms to improve biological plausibility of fiber tracking:

  * *Anatomically Constrained Tractography (ACT)*: Rejects streamlines that end in biologically implausible tissue (e.g., CSF).
  * *Spherical-deconvolution informed filtering of tractograms (SIFT)*: Corrects for the fact that longer streamlines tend to be overestimated in tractography.
  * *multi-shell multi-tissue CSD (MSMT)*: Improves tractography in voxels containing partial volumes by exploiting the differences in b-value sensitivity of different tissue types.

High-level processing strategy
++++++++++++++++++++++++++++++


Detailed processing steps
+++++++++++++++++++++++++

Convert DICOM data
~~~~~~~~~~~~~~~~~~

..  note::
	
	Note that it seems DWI data transferred from scanner to Flywheel will lose some info, and are not compatible with MRtrix. Some observed issues include: 1) error of "slice position information missing from DICOM header!" when using mrconvert/mrinfo/mrcat to convert/view DICOM data downloaded from Flywheel, and 2) mif converted from data downloaded from Flywheel has more than 4 dimentions, and gives error of "contains more than 4 dimensions" when concatenate with other mif. By using mrinfo to view the header, dimension is 122 x 122 x 1 x 74 x 9, while 122 x 122 x 74 x 31 is expected.

	These errors led me to work around it using the following methods.

Use *3D Slicer* to extract series with the following series description to a specific folder, e.g., *3DslicerExtractedDWI*.

* PA_FMAP_for DIFFUSION
* AP_FMAP_for DIFFUSION
* AP_BLOCK_1_DIFFUSION_30DIR
* AP_BLOCK_2_DIFFUSION_30DIR
* PA_BLOCK_1_DIFFUSION_30DIR
* PA_BLOCK_2_DIFFUSION_30DIR

Use the following commands to convert DICOM to MIF:

..  code-block::

	mrconvert /path/to/3DslicerExtractedDWI PA_B0.mif
	mrconvert /path/to/3DslicerExtractedDWI AP_B0.mif
	mrconvert /path/to/3DslicerExtractedDWI AP_1.mif
	mrconvert /path/to/3DslicerExtractedDWI AP_2.mif
	mrconvert /path/to/3DslicerExtractedDWI PA_1.mif
	mrconvert /path/to/3DslicerExtractedDWI PA_2.mif

Each *mrconvert* command will generate the following output in the shell:

..  code-block::

	mrconvert: [.   ] scanning DICOM folder "/srv/scrat...2pilot/3DslicerExtractedDWI"...
	mrconvert: [WARNING] mismatched series number and UID - this may cause problems with series grouping
	mrconvert: [done] scanning DICOM folder "/srv/scrat...2pilot/3DslicerExtractedDWI"
	Select series ('q' to abort):
	   0 -  240 MR images 15:50:05 PA_FMAP_for DIFFUSION (*epse2d1_86) [25001] ORIGINAL PRIMARY M ND NORM MFSPLIT
	   1 -  240 MR images 15:50:42 AP_FMAP_for DIFFUSION (*epse2d1_86) [26001] ORIGINAL PRIMARY M ND NORM MFSPLIT
	   2 - 2294 MR images 15:51:51 AP_BLOCK_1_DIFFUSION_30DIR (*ep_b0) [27001] ORIGINAL PRIMARY DIFFUSION NONE ND NORM MFSPLIT
	   3 - 2294 MR images 15:54:44 AP_BLOCK_2_DIFFUSION_30DIR (*ep_b0) [35001] ORIGINAL PRIMARY DIFFUSION NONE ND NORM MFSPLIT
	   4 - 2294 MR images 15:57:37 PA_BLOCK_1_DIFFUSION_30DIR (*ep_b0) [43001] ORIGINAL PRIMARY DIFFUSION NONE ND NORM MFSPLIT
	   5 - 2294 MR images 16:00:29 PA_BLOCK_2_DIFFUSION_30DIR (*ep_b0) [51001] ORIGINAL PRIMARY DIFFUSION NONE ND NORM MFSPLIT
	?

Select corresponding series number for the mrconvert call. For example, when converting PA_B0.mif, select 0. When converting AP_B0, select 1, and so on.

Concatenate all DWI data acquired in the same PE direction:

..  code-block::

	dwicat AP_1.mif AP_2.mif AP.mif
	dwicat PA_1.mif PA_2.mif PA.mif

`dwicat <https://mrtrix.readthedocs.io/en/dev/reference/commands/dwicat.html>`_ is used to automatically adjust for differences in intensity scaling.

Denoising
~~~~~~~~~

References and further readings
+++++++++++++++++++++++++++++++
- `BATMAN tutorial for MRtrix <https://osf.io/fkyht/>`_ (Further readings in the appendix of BATMAN tutorial document are worth reading.)
- `University of Utah TBICC Neuroimaging Protocols <https://bookdown.org/u0243256/tbicc/preprocessing-diffusion-images.html>`_