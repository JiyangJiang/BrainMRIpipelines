#!/bin/bash

usage() {

cat << EOF

$(basename $0)

DESCRIPTION

  This script converts DICOM downloaded from Flywheel to BIDS format. It is customised
  for MAS2 and VCI study run at CHeBA.


USAGE

  $(basename $0) {-d|--dicom_zip} <DICOM zip archive from Flywheel> 
                 {-b|--bids_dir} <output BIDS directory>
                 [{-j|--json} <path to JSON file>]


COMPULSORY

  -s, --study                 <MAS2 or VCI>          'MAS2' or 'VCI' study.

  -d, --dicom_zip             <DICOM zip archive>    Path to DICOM zip file downloaded
                                                     from Flywheel.

  -b, --bids_dir              <BIDS directory>       Path to output BIDS directory.


OPTIONAL

  -j, --json                  <path to JSON file>    Path to config JSON file, if not
                                                     using default MAS2_config.json
                                                     and VCI_config.json.

  -h, --help                                         Display this message.


EOF

}



for $arg in $@
do
  case $arg in
    -s|--study)
        study=$2
        json=$BMP_PATH/BIDS/config_files/${2}_config.json
        shift 2
        ;;
    -d|--dicom_zip)
        DICOM_zip=$2
        shift 2
        ;;
    -b|--bids_directory)
        BIDS_dir=$2
        shift 2
        ;;
    -j|--json)
        json=$2
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    -*)
        echo "[$(date)] : $(basename) : Unknown flag $arg."
        usage
        exit 1
        ;;
  esac
done


bmp_BIDS_CHeBA_init.sh $DICOM_zip $BIDS_dir



bmp_BIDS_CHeBA_dcm2bids.sh