#!/bin/bash

#
# HISTORY
#
# 25 Nov 2022 - First version written by Jiyang Jiang.

usage () {

cat << EOF

$(basename $0)


DESCRIPTION :
  
  Run BMP structural MRI workflow.


USAGE :

  $(basename $0) {-b|--bids_directory} <BIDS_directory> [{-s|--singularity}] [{-d|--docker}]


COMPULSORY :

  -b, --bids_directory    <BIDS_directory>                Path to BIDS directory.

  -s, --singularity       <BIDS_Validator_version>        Use singularity image. Either 
                                                          {-s|--singularity} or
                                                          {-d|--docker} needs to be set.

  -d, --docker            <BIDS_Validator_version>        Use docker image. Either 
                                                          {-s|--singularity} or
                                                          {-d|--docker} needs to be set.


OPTIONAL :

  -h, --help                                  Display this message.


DEPENDENCIES :

  - BIDS Validator (docker)


EOF

}

use_singularity=0
use_docker=0

for arg in $@
do
	case $arg in

		-b|--bids_directory)

			BIDS_directory=$2
			shift 2
			;;

		-s|--singularity)

			use_singularity=1
			BIDS_Validator_version=$2
			shift
			;;

		-d|--docker)

			use_docker=1
			BIDS_Validator_version=$2
			shift
			;;

		-h|--help)

			usage
			exit 0
			;;

		-*)
			
			echo "[$(date)] : $(basename $0) : Unknown flag $arg."
			usage
			exit 1
			;;
	esac
done


if [ "${use_docker}" == "1" ]; then

	bmp_bids-validator.sh --bids_directory $BIDS_directory --docker      $BIDS_Validator_version    # BIDS Validator

elif [ "${use_singularity}" == "1" ]; then

	bmp_bids-validator.sh --bids_directory $BIDS_directory --singularity $BIDS_Validator_version

fi