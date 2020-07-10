#!/bin/bash

# *_desc-confounds_regressors.tsv contains the following columns:
#
#      csf
#      white_matter
#      global_signal
#      std_dvars
#      dvars
#      framewise_displacement
#      t_comp_cor_00
#      t_comp_cor_01
#      t_comp_cor_02
#      t_comp_cor_03
#      t_comp_cor_04
#      t_comp_cor_05
#      a_comp_cor_00
#      a_comp_cor_01
#      a_comp_cor_02
#      a_comp_cor_03
#      a_comp_cor_04
#      a_comp_cor_05
#      non_steady_state_outlier00
#      trans_x
#      trans_y
#      trans_z
#      rot_x
#      rot_y
#      rot_z
#      aroma_motion_02
#      aroma_motion_04

nuiReg(){

	nuisanceRegressorTSV=$1
}

nuiReg $1