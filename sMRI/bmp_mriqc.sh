#!/bin/bash

usage() {

cat << EOF

$(basename $0)

DESCRIPTION

  This script runs MRIQC using docker or singularity, first on participant
  level and then on group level.


USAGE

  $(basename $0) {-b|--bids_directory} <BIDS_directory> [{-s|--singularity}|{-d|--docker}] [{-p|--participant}|{-g|--group}]


COMPULSORY

  -b, --bids_directory        <BIDS_directory>       Path to BIDS directory.

  -s, --singularity           <MRIQC_version>        Use singularity image with version
                                                     <MRIQC_version>. Either 
                                                     {-s|--singularity} or
                                                     {-d|--docker} needs to be set.

  -d, --docker                <MRIQC_version>        Use docker image with version
                                                     <MRIQC_version>. Either 
                                                     {-s|--singularity} or
                                                     {-d|--docker} needs to be set.


OPTIONAL

  -a, --addtional_options     <addition_options>     Addtional options for MRIQC. Default
                                                     is ...

  -h, --help                                         Display this message.


EOF

}


use_singularity=0
use_docker=0

num_cpu=$(grep -c ^processor /proc/cpuinfo) # num of CPU

additionalOptoins="-vvv --species human --nprocs $num_cpu"


for $arg in $@
do

	case $arg in

		-b|--bids_directory)

			BIDS_directory=$2
			shift 2
			;;

		-s|--singularity)

			use_singularity=1
			MRIQC_version=$2
			shift 2
			;;

		-d|--docker)

			use_docker=1
			MRIQC_version=$2
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


if [ "$use_docker" == "1" ]; then

	echo "[$(date)] : $(basename $0) : Running MRIQC at participant level using docker."

	docker run -it --rm -v $BIDS_directory:/data:ro \
							-v $BIDS_directory/derivatives/mriqc/sub-$subjID:/out \
							nipreps/mriqc \
							/data \
							/out \
							participant \
							$additionalOptoins

fi



