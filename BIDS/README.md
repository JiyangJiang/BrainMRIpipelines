# BIDS workflow

This workflow contains a few scripts and preset configuration files to convert DICOM data to BIDS format, and validatate BIDS structure. Some manual interations are needed in this workflow.

## The way BMP construct and interpret DICOM-to-BIDS mappings

   The DICOM-to-BIDS mapping is through constructing a MATLAB structure (DICOM2BIDS). 

   
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                          Individual-level mapping                               +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
   +  DICOM2BIDS ----- subject                                                       +
   +             \                                                                   +
   +              \                                                                  +
   +               session -- datatype -- modality -- run -- DICOM -- keys = values  +
   +                                                      \                          +
   +                                                       \                         +
   +                                                        BIDS ---- keys = values  +
   +                                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
   + An example of individual-level DICOM-to-BIDS mapping:                           +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
	+   DICOM2BIDS(1).subject = 'sub-128S0272';                                       +
   +                                                                                 +
	+   DICOM2BIDS(1).m12.anat.T1w.run01.DICOM.SeriesDescription = 'SAG MPRAGE';      +
	+   DICOM2BIDS(1).m12.anat.FLAIR.run01.DICOM.SeriesDescription = '3D FLAIR';      +
   +                                                                                 +
	+   DICOM2BIDS(1).m12.anat.T1w.run01.BIDS.acquisition = 'sagMPRAGE';              +
	+   DICOM2BIDS(1).m12.anat.FLAIR.run01.BIDS.acquisition = 'sag3DFLAIR';           +
   +                                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                      Dataset/Subgroup-level mapping                             +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
   + DICOM2BIDS -- session -- datatype -- modality -- run -- DICOM -- keys = values  +
   +                                                      \                          +
   +                                                       \                         +
   +                                                        BIDS ---- keys = values  +
   +                                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
   + An example of dataset/subgroup-level mapping:                                   +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +                                                                                 +
   +   DICOM2BIDS.ses01.anat.T1w.run01.DICOM.ProtocolName = '3D MPRAGE';             +
   +   DICOM2BIDS.ses01
   +                                                                                 +
   +                                                                                 +
   + NOTE that 'session' and 'run' entities are necessary when defining DICOM2BIDS   +
   + mapping, in case different sessions and/or runs have different criteria. If     +
   + only one session label or one run index exists in the final DICOM2BIDS,         +
   + bmp_BIDSgenerator will ignore them in the converted images and folder structure.+


   DICOM2BIDS can be derived from calling bmp_DICOMenquirer and bmp_DICOMtoBIDSmapper.

## Required third-party software

- [BIDS-Validator (docker/singularity)](https://github.com/bids-standard/bids-validator)
- MATLAB (Image Processing Toolbox)
- BIDS-MATLAB

## Optional third-party software

- [Dcm2Bids](https://unfmontreal.github.io/Dcm2Bids/) (if Dcm2Bids is preferred for DICOM-to-BIDS conversion).

## BMP's strategies for DICOM-to-BIDS mapping

## Enquiring DICOM information

## Creating DICOM-to-BIDS mapping

## Generating BIDS directory

## Validating BIDS directory

## Parsing BIDS directory

## Presets for public datasets
