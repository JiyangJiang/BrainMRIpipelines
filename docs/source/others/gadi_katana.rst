Using GADI and KATANA
+++++++++++++++++++++

# KATANA - jobs
---------------

..  code-block::

	#!/bin/bash
	#PBS -l select=1:ncpus=2:mem=8gb
	#PBS -l walltime=02:00:00
	#PBS -j oe
	#PBS -N prep
	#PBS -o /srv/scratch/cheba/NiL/UKB/wmh/training_2021SEP06_trainFrom20k/1003977.oe


# KATANA - interactive job
--------------------------

..  code-block::

	qsub -I -l ncpus=2,mem=16gb,walltime=12:00:00


GADI - Download from MDSS to GADI
---------------------------------

..  code-block::

	cd /g/data/ey6/Jiyang/migration
	mdss -P ey6 get Jiyang/MAS/nifti.tar MAS/.

GADI - Upload from GADI to MDSS
-------------------------------

..  code-block::

	#!/bin/bash

	#PBS -l ncpus=1
	#PBS -l mem=2GB
	#PBS -l jobfs=2GB
	#PBS -q copyq
	#PBS -P a00
	#PBS -l walltime=02:00:00
	#PBS -l storage=gdata/a00+massdata/a00
	#PBS -l wd

	tar -cvf my_archive.tar /g/data/a00/aaa777/work1
	mdss -P a00 mkdir -p aaa777/test/
	mdss -P a00 put my_archive.tar aaa777/test/work1.tar
