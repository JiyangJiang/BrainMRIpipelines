# Ref : https://dipy.org/documentation/1.5.0/examples_built/brain_extraction_dwi/#example-brain-extraction-dwi
#
# To call from shell :
#    for_each -nthreads $nthr sub-* : python 	${scriptFolder}/dwi/dipyBrainExtraction.py \
#												IN/synB0discoOutput/b0_all_topup_Tmean.nii.gz \
#												IN/synB0discoOutput b0_all_topup_Tmean

import numpy as np
from dipy.data import get_fnames
from dipy.io.image import load_nifti, save_nifti
from dipy.segment.mask import median_otsu
import sys, os

path2b0     = sys.argv[1]
outDir      = sys.argv[2]
outBaseName = sys.argv[3]

data, affine = load_nifti(path2b0)
data = np.squeeze(data)

b0_mask, mask = median_otsu(data, median_radius=2, numpass=1)

save_nifti(os.path.join(outDir, outBaseName + '_brainmask.nii.gz'), mask.astype(np.float32),    affine)
save_nifti(os.path.join(outDir, outBaseName + '_brain.nii.gz')    , b0_mask.astype(np.float32), affine)