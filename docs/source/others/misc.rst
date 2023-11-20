Miscellaneous tips
==================

CUDA for FSL
------------
Refer to `this page <https://www.nemotos.net/?p=5359>`_ for how to install and test CUDA 11 with FSL 6.0.6.X on Ubuntu 20.04/22.04. There are instructions on how to install other versions of cuda with other versions of FSL and Ubuntu `here <https://www.nemotos.net/?s=cuda&x=0&y=0>`_.

Katana on-demand
----------------
`Katana on demand <https://kod.restech.unsw.edu.au/pun/sys/dashboard>`_ allows for requesting resources from webpage, and access the desktop graphic interface of your requested resource. It can be useful if there's any issue with graphics via ssh login.

optiBET.sh error - [[: not found
--------------------------------
[[ is a bash-builtin. Add ``#!/bin/bash`` at the top of optiBET.sh file.

Building singularity with image on Docker Hub
---------------------------------------------
`Reference 1 <https://www.nas.nasa.gov/hecc/support/kb/converting-docker-images-to-singularity-for-use-on-pleiades_643.html>`_
`Reference 2 <https://apptainer.org/user-docs/master/build_env.html>`_

.. code-block::

	export SINGULARITY_CACHEDIR=/srv/scratch/cheba/Imaging/my_tmp
	export APPTAINER_CACHEDIR=/srv/scratch/cheba/Imaging/my_tmp
	TEMP=/srv/scratch/cheba/Imaging/my_tmp
	TMPDIR=$TEMP
	TMP=$TEMP
	export TEMP TMP TMPDIR

	singularity pull mriqc.sif docker://nipreps/mriqc

	singularity run mriqc.sif --version    # check image version