#!/bin/bash

# GROUP LEVEL !!


# ---=== Finally note that, for quantitative group studies, a single unique set of 3-tissue response functions should be used for all subjects. 
# ---=== This can for example be achieved by averaging response functions (per tissue type) across all subjects in the study.
# Ref: https://mrtrix.readthedocs.io/en/3.0_rc2/fixel_based_analysis/ss_fibre_density_cross-section.html
# responsemean */response.txt ../group_responsemean.txt
work_dir=/home/jiyang/Work/dwi_test
cd ${work_dir}
responsemean */response_wm.txt grp_avg_response_wm.txt
responsemean */response_gm.txt grp_avg_response_gm.txt
responsemean */response_csf.txt grp_avg_response_csf.txt
