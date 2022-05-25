#!/bin/bash

# ---=== GROUP LEVEL ===---


# 17. Compute the fibre cross-section (FC) metric

# However, for group statistical analysis of FC we recommend calculating the log(FC) 
# to ensure data are centred around zero and normally distributed. Here, we create a 
# separate fixel directory to store the log(FC) data and copy the fixel index and 
# directions file across:

mkdir -p template/log_fc
cp template/fc/index.mif template/fc/directions.mif template/log_fc
for i in [0-9]*;do mrcalc -force template/fc/${i}.mif -log template/log_fc/${i}.mif;done


# 18. Compute a combined measure of fibre density and cross-section (FDC)

# The total capacity of a fibre bundle to carry information, is modulated both by the 
# local fibre density at the voxel (fixel) level, as well as its cross-sectional size. 
# Here we compute a combined metric, which factors in the effects of both FD and FC, 
# resulting in a fibre density and cross-section (FDC) metric:

mkdir -p template/fdc
cp template/fc/index.mif template/fdc
cp template/fc/directions.mif template/fdc
for i in [0-9]*;do mrcalc -force template/fd/${i}.mif template/fc/${i}.mif -mult template/fdc/${i}.mif;done


# 19. Perform whole-brain fibre tractography on the FOD template

# Statistical analysis using connectivity-based fixel enhancement (CFE) [Raffelt2015] 
# exploits local connectivity information derived from probabilistic fibre tractography, 
# which acts as a neighbourhood definition for threshold-free enhancement of locally 
# clustered statistic values. To generate a whole-brain tractogram from the FOD template 
# (note the remaining steps from here on are executed from the template directory):

cd template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image mask_intersection.mif -mask mask_intersection.mif -select  1000000 -cutoff 0.06 tracks_100_thousands.tck
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image mask_intersection.mif -mask mask_intersection.mif -select 20000000 -cutoff 0.06 tracks_20_million.tck

# The appropriate FOD amplitude cutoff for FOD template tractography can vary considerably between different datasets, 
# as well as different versions of MRtrix3 due to historical software bugs. While the value of 0.06 is suggested as a 
# reasonable value for multi-tissue data, it may be beneficial to first generate a smaller number of streamlines 
# (e.g. 100,000) using this value, and visually confirm that the generated streamlines exhibit an appropriate extent 
# of propagation at the ends of white matter pathways, before committing to generation of the dense tractogram.


# 20. Reduce biases in tractogram densities

# Perform SIFT to reduce tractography biases in the whole-brain tractogram:

tcksift tracks_20_million.tck wmfod_template.mif tracks_2_million_sift.tck -term_number 2000000


# 21. Generate fixel-fixel connectivity matrix

# Generation of the fixel-fixel connectivity matrix based on the whole-brain streamlines tractogram is performed as follows:

fixelconnectivity -force fixel_mask/ tracks_2_million_sift.tck matrix/

# The output directory should contain three images: index.mif, fixels.mif and values.mif; 
# these are used to encode the fixel-fixel connectivity that is by its nature sparse.


# 22. Smooth fixel data using fixel-fixel connectivity

# Smoothing of fixel data is performed based on the sparse fixel-fixel connectivity matrix:

fixelfilter -force fd     smooth fd_smooth     -matrix matrix/
fixelfilter -force log_fc smooth log_fc_smooth -matrix matrix/
fixelfilter -force fdc    smooth fdc_smooth    -matrix matrix/


# 23. Perform statistical analysis of FD, FC, and FDC

# Statistical analysis using CFE is performed separately for each metric (FD, log(FC), and FDC) as follows:

for i in CNvsMCI YOvsOO
do
	fixelcfestats -force -nthreads 44 fd_smooth/     files_${i}.txt design_matrix_${i}.txt contrast_matrix_${i}.txt matrix/ stats_fd_${i}/
	fixelcfestats -force -nthreads 44 log_fc_smooth/ files_${i}.txt design_matrix_${i}.txt contrast_matrix_${i}.txt matrix/ stats_log_fc_${i}/
	fixelcfestats -force -nthreads 44 fdc_smooth/    files_${i}.txt design_matrix_${i}.txt contrast_matrix_${i}.txt matrix/ stats_fdc_${i}/
done