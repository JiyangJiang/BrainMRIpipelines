#!/bin/bash

# HISTORY
#
# 25 Nov 2022 : First version created by Jiyang Jiang.
#

usage() {

cat << EOF

$(basename $0)


DESCRIPTION :

  Initialisation for BrainMRIpipelines.


USAGE :

  $(basename $0) [{-b|--bmp_directory} <BMP_directory> {-t|-third_directory} <third_directory>]


COMPULSORY :

  None


OPTIONAL :

  -b, --bmp_directory        <BMP_directory>        Path to BrainMRIpipelines directory. This
                                                    will overwrite BMP_PATH. If not specified, 
                                                    BMP_PATH set in ~/.bashrc will be used.

  -t, --third_directory      <third_directory>      Path to install third party software. This
                                                    will overwrite BMP_3RD_PATH. If not specified,
                                                    parent folder of BMP directory will be used.

  -e, --temp_directory       <BMP_temp_directory>   Path to BMP temporary directory. This will
                                                    overwrite BMP_TMP_PATH. If not specified,
                                                    'mktemp -d -t bmp.XXX' will be called to create
                                                    one (not recommended).

  -h, --help                                        Display this message.


DEPENDENCIES :

  None

EOF

}


echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Started.$(bmp_shellColour.sh --reset)"

for arg in $@
do
	case "$arg" in

		-b|--bmp_directory)

			bmp_directory=$2
			export BMP_PATH=$bmp_directory # overwrite BMP_PATH if bmp_directory is specified.
			shift 2
			;;

		-t|--third_directory)

			third_directory=$2
			export BMP_3RD_PATH=$third_directory
			shift 2
			;;

		-e|--temp_directory)

			temp_directory=$2
			export BMP_TMP_PATH=$temp_directory
			shift 2
			;;

		-h|--help)

			usage
			exit 0
			;;

		-*|--*)

			echo "[$(date)] : $(basename $0) : Unknown flag $arg"
			echo "[$(date)] : $(basename $0) : "
			usage
			exit 1
			;;

	esac
done

[ -z ${BMP_PATH:+x} ]     && echo -e "$(bmp_convention.sh --text_error)[$(date)] : $(basename $0) : BMP_PATH is not set.$(bmp_shellColour.sh --reset)"     && exit 1
[ -z ${BMP_3RD_PATH:+x} ] && echo -e "$(bmp_convention.sh --text_error)[$(date)] : $(basename $0) : BMP_3RD_PATH is not set.$(bmp_shellColour.sh --reset)" && exit 1

if [ -z ${BMP_TMP_PATH:+x} ]; then
	BMP_TMP_PATH=`mktemp -d -t bmp.XXX`
	export $BMP_TMP_PATH
	echo -e "$(bmp_convention.sh --text_warning)[$(date)] : $(basename $0) : BMP_TMP_PATH is not set. Created one at $BMP_TMP_PATH.$(bmp_shellColour.sh --reset)"
fi

# print BMP_PATH and BMP_3RD_PATH
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : BMP directory is set to $BMP_PATH.$(bmp_shellColour.sh --reset)"
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : BMP 3rd party software directory is set to $BMP_3RD_PATH.$(bmp_shellColour.sh --reset)"
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : BMP temporary directory is set to $BMP_TMP_PATH.$(bmp_shellColour.sh --reset)"

# add relevant path to PATH
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Setting PATH.$(bmp_shellColour.sh --reset)"

[ "${PATH#*$BMP_PATH/init:}" == "$PATH" ] && export PATH="$BMP_PATH/init:$PATH"      # init
[ "${PATH#*$BMP_PATH/BIDS:}" == "$PATH" ] && export PATH="$BMP_PATH/BIDS:$PATH"      # BIDS
[ "${PATH#*$BMP_PATH/sMRI:}" == "$PATH" ] && export PATH="$BMP_PATH/sMRI:$PATH"      # sMRI

echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : Finished ($?)."
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : $(basename $0) : If you haven't install required third party software, you can call bmp_install.sh to install.$(bmp_shellColour.sh --reset)"