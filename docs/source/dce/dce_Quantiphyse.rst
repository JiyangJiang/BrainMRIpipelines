Processing DCE-MRI data using Quantiphyse
=========================================

Bayesian modelling tutorial can be found in `this link <https://quantiphyse.readthedocs.io/en/latest/dce/tutorial_basic.html>`_.
Least-scquires modelling can be found in `this link <https://quantiphyse.readthedocs.io/en/latest/dce/lsq.html>`_.
Details of the required parameters can be found `here <https://quantiphyse.readthedocs.io/en/latest/dce/interface.html#dce-interface>`_.

Parameters used in VCI study:

* **Contrast agent R1 relaxivity (l/mmol s)**

* **Flip angle**: 15 degrees.

* **TR (ms)**: 3.44.

* **Time between volumes (s)**: 40.

* **Bolus injection time (s)**: 80. Three volumes before injection. Time between two volumes is 40 seconds.

* **Not** allowing T1 to vary because a T1 map is given.

* **Allow** bolus arrival time to vary to account for transit times to different voxels.