# Miscellaneous tricks

## Multi-thread computing

### Local computer/workstation
If you are using local computer/workstation, I found the most effective way to run multi-thread computation is through using [MRtrix's *for_each* command](https://mrtrix.readthedocs.io/en/latest/tips_and_tricks/batch_processing_with_foreach.html).

### Katana at UNSW

### Gadi from NCI

To submit a job:

```
#!/bin/bash 
#PBS -P ey6 
#PBS -q normal 
#PBS -l ncpus=2 
#PBS -l mem=8GB 
#PBS -l walltime=02:00:00 
#PBS -l jobfs=2GB 
#PBS -l wd 
#PBS -V 
#PBS -l storage=gdata/ey6 
#PBS -e /path/to/standard_error 
#PBS -o /path/to/standard_output 

# The actual command below 

sleep 10
```

To start interactive job
```
qsub -I -P ey6 -q copyq -l ncpus=1,mem=4GB,walltime=10:00:00,wd,storage=gdata/ey6,jobfs=10GB 
```

To upload to MDSS

To download from MDSS

```
qsub -V -P ey6 -q copyq -l ncpus=1,mem=4GB,walltime=10:00:00,wd,storage=gdata/ey6,jobfs=50GB -- mdss get Jiyang/MAS/mrtrix.tar /g/data/ey6/Jiyang
```

### Building singularity images

```
singularity build ./smriprep.simg docker://nipreps/smriprep  # build sMRIPrep singularity image from latest
singularity run --cleanenv ./smriprep.simg --version  # check sMRIPrep version

```