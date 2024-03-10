#!/bin/bash

# HISTORY
# =========================================================================
# 25 Nov 2022 - First version written by Jiyang Jiang.

usage () {

cat << EOF

$(basename $0)


DESCRIPTION :
  
  Run BIDS Validator in group level.


USAGE :

  $(basename $0) {-b|--bids_directory} <BIDS_directory> [{-s|--singularity}|{-d|--docker}]


COMPULSORY :

  -b, --bids_directory    <BIDS_directory>                Path to BIDS directory.

  -s, --singularity       <BIDS_Validator_version>        Use singularity image with version
                                                          <BIDS_Validatory_verion>. Either 
                                                          {-s|--singularity} or
                                                          {-d|--docker} needs to be set.

  -d, --docker            <BIDS_Validator_version>        Use docker image with version
                                                          <BIDS_Validatory_verion>. Either 
                                                          {-s|--singularity} or
                                                          {-d|--docker} needs to be set.


OPTIONAL :

  -h, --help                                              Display this message.


DEPENDENCIES :

  - BIDS Validator (docker/singularity)


EOF

}

use_singularity=0
use_docker=0
additionalOptoins=" --verbose"

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

[ "$use_singularity" == 1 ] && [ "$use_docker" == 1 ] && echo "[$(date)] : $(basename $0) : Error - cannot select both singularity and docker." && exit 1
[ "$use_singularity" == 0 ] && [ "$use_docker" == 0 ] && echo "[$(date)] : $(basename $0) : Error - either singularity or docker needs to be selected." && exit 1
[ -z "${BIDS_directory:+x}" ] && echo "[$(date)] : $(basename $0) : Error - BIDS directory is not set." && exit 1


echo "[$(date)] : $(basename $0) : Started running BIDS Validator."

mkdir -p $BIDS_directory/derivatives/bmp/bids-validator

if [ "${use_docker}" == "1" ]; then

	docker run --rm -it -v ${BIDS_directory}:/data:ro bids/validator:${BIDS_Validator_version} /data $additionalOptoins \
			> $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log

	echo "[$(date)] : $(basename $0) : BIDS Validator finished using docker."
	echo "[$(date)] : $(basename $0) : BIDS Validator can be found in the following path:"
	echo "[$(date)] : $(basename $0) : -> $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log"

elif [ "${use_singularity}" == "1" ]; then

	if [ ! -f "$BMP_3RD_PATH/singularity/bids-validator_${BIDS_Validator_version}.simg" ]; then

		bmp_install.sh --bids_validator ${BIDS_Validator_version} --singularity

	fi

	singularity run --cleanenv \
				    --bind ${BIDS_directory}:/data:ro \
				    $BMP_3RD_PATH/singularity/bids-validator_${BIDS_Validator_version}.simg \
				    /data \
				    $additionalOptoins \
				    > $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log

	echo "[$(date)] : $(basename $0) : BIDS Validator finished using singularity."
	echo "[$(date)] : $(basename $0) : BIDS Validator can be found in the following path:"
	echo "[$(date)] : $(basename $0) : -> $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log"

fi

num_err=$(grep -ow '\[ERR\]'  $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log | wc -l)
num_war=$(grep -wo '\[WARN\]' $BIDS_directory/derivatives/bmp/bids-validator/bmp_bids-validator.log | wc -l)
 
echo "[$(date)] : $(basename $0) : There were $num_err error(s) and $num_war warning(s)."

