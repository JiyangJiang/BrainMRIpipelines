# Miscellaneous tricks

## Multi-thread computing

### Local computer/workstation
If you are using local computer/workstation, I found the most effective way to run multi-thread computation is through using [MRtrix's *for_each* command](https://mrtrix.readthedocs.io/en/latest/tips_and_tricks/batch_processing_with_foreach.html).

### Katana at UNSW

### Gadi from NCI

### Building singularity images

```
singularity build ./smriprep.simg docker://nipreps/smriprep  # build sMRIPrep singularity image from latest
singularity run --cleanenv ./smriprep.simg --version  # check sMRIPrep version

```