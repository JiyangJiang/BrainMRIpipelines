
#!/bin/bash

usage() {

cat << EOF

$(basename $0)


DESCRIPTION :

  Install third-party software for BrainMRIpipelines.


USAGE :

  $(basename $0) [{-d|--dcm2bids}, {-v|--bids_validator}, ...]


COMPULSORY :

  None


OPTIONAL :

  -d, --dcm2bids                                      Install Dcm2Bids (conda).

  -v, --bids_validator    <BIDS_Validator_version>    Install BIDS Validator (docker/singularity).

  -b, --bids_matlab                                   Install BIDS-MATLAB.

  -m, --mriqc             <MRIQC_version>             Install MRIQC (docker/singularity).

  -s, --singularity                                   Convert docker to singularity.
                                                      Singularity images can then be
                                                      used on HPC.
conda install -c conda-forge octave
  -h, --help                                          Display this message.


DEPENDENCIES :

  - Miniconda3  (https://docs.conda.io/en/latest/miniconda.html)

  - Docker      (https://docs.docker.com/engine/install/)

  - Singularity (https://docs.sylabs.io/guides/3.0/user-guide/installation.html)
                (https://github.com/sylabs/singularity/releases)
                sudo apt install cryptsetup-bin

  - MATLAB

  - dcm2niix


EOF

}

# defaults
install_dcm2bids=0
install_bidsvalidator=0
install_bidsmatlab=0
install_mriqc=0
singularity=0

# whether BMP_PATH and BMP_3RD_PATH are set
[ -z ${BMP_PATH:+x} ]     && echo "[$(date)] : $(basename $0) : BMP_PATH is not set."     && exit 1
[ -z ${BMP_3RD_PATH:+x} ] && echo "[$(date)] : $(basename $0) : BMP_3RD_PATH is not set." && exit 1

# parsing arguments
for arg in $@
do
	case "$arg" in

		-d|--dcm2bids)
			
			install_dcm2bids=1
			shift
			;;

		-v|--bids_validator)

			BIDS_Validator_version=$2
			install_bidsvalidator=1
			shift
			;;

		-b|--bids_matlab)

			install_bidsmatlab=1
			shift
			;;

		-m|--mriqc)

			MRIQC_version=$2
			install_mriqc=1
			shift
			;;

		-s|--singularity)

			singularity=1
			mkdir -p $BMP_3RD_PATH/singularity
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


# Dcm2Bids
# ----------------------------------------------------------------------
# Ref : https://unfmontreal.github.io/Dcm2Bids/docs/get-started/install/

if [ "$install_dcm2bids" == 1 ]; then

	echo "[$(date)] : $(basename $0) : Installing Dcm2Bids through conda."

	conda env create --file $BMP_PATH/init/env_yml/dcm2bids.yml

	echo "[$(date)] : $(basename $0) : Dcm2Bids has been installed."

fi


# BIDS Validator
# ---------------------------------------------------------------------
# Ref : https://github.com/bids-standard/bids-validator
#       https://hub.docker.com/r/bids/validator

if [ "$install_bidsvalidator" == 1 ]; then

	if [ "$singularity" == 1 ]; then

		echo "[$(date)] : $(basename $0) : Installing BIDS Validator (version = ${BIDS_Validator_version}) through singularity."

		singularity build $BMP_3RD_PATH/singularity/bids-validator_${BIDS_Validator_version}.simg \
                    docker://bids/validator:$BIDS_Validator_version

        echo "[$(date)] : $(basename $0) : BIDS Validator (version = ${BIDS_Validator_version}) singularity image has been created."
        echo "[$(date)] : $(basename $0) : -> $BMP_3RD_PATH/singularity/bids-validator_${BIDS_Validator_version}.simg."

    else

		echo "[$(date)] : $(basename $0) : Installing BIDS Validator (version = ${BIDS_Validator_version}) through docker."

		docker pull bids/validator:${BIDS_Validator_version}

		echo "[$(date)] : $(basename $0) : BIDS Validator (version = ${BIDS_Validator_version}) has been installed through docker."

	fi

fi

# MATLAB-BIDS
# ---------------------------------------------------------------------
# Ref : https://bids-matlab.readthedocs.io/en/latest/general_information.html#installation

if [ "$install_bidsmatlab" == 1 ]; then
	git clone https://github.com/bids-standard/bids-matlab.git $BMP_3RD_PATH/bids-matlab
fi


# MRIQC
# ---------------------------------------------------------------------
# Ref : https://mriqc.readthedocs.io/en/latest/docker.html

if [ "$install_mriqc" == 1 ]; then

	if [ "$singularity" == 1 ]; then

		echo "[$(date)] : $(basename $0) : Installing MRIQC (version = ${MRIQC_version}) through singularity."

		singularity build $BMP_3RD_PATH/singularity/mriqc_${MRIQC_version}.simg \
								docker://nipreps/mriqc:$MRIQC_version

		echo "[$(date)] : $(basename $0) : MRIQC (version = $MRIQC_version) singularity image has been created."
		echo "[$(date)] : $(basename $0) : -> $BMP_3RD_PATH/singularity/mriqc_${MRIQC_version}.simg"

	else

		echo "[$(date)] : $(basename $0) : Installing MRIQC (version = ${MRIQC_version}) through docker. This may take some time."

		docker pull nipreps/mriqc:${MRIQC_version}

		echo "[$(date)] : $(basename $0) : MRIQC (version = ${MRIQC_version}) has been installed."

	fi

fi