#!/bin/bash

# LOG:
# 1) clinical version = 0.7.3

conda activate clinicaEnv

DATASET_DIRECTORY=/data3/adni/adni_all/ADNI
CLINICAL_DATA_DIRECTORY=/data3/adni/studyData
BIDS_DIRECTORY=/data3/adni/adni_all/BIDS

clinica convert adni-to-bids $DATASET_DIRECTORY $CLINICAL_DATA_DIRECTORY $BIDS_DIRECTORY