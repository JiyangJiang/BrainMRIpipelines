#!/bin/bash

# HISTORY
#
# 25 Nov 2022 : First version created by Jiyang Jiang.
#

usage() {

cat << EOF

bmp_init.sh


DESCRIPTION :

  Initialisation for BrainMRIpipelines.


USAGE :

  bmp_init.sh [{-b|--bmp_directory} <BMP_directory> {-s|--spm_directory} <SPM12_directory> {-t|-third_directory} <third_directory>]


COMPULSORY :

  None


OPTIONAL :

  -b, --bmp_directory        <BMP_directory>        Path to BrainMRIpipelines directory. This
                                                    will overwrite BMP_PATH. If not specified, 
                                                    BMP_PATH set in ~/.bashrc will be used.

  -s, --spm_directory        <SPM12_directory>      Path to SPM12. This will overwrite BMP_SPM12_PATH.
                                                    If not specified, BMP_SPM12_PATH set in
                                                    ~/.bashrc will be used.

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

[ "${PATH#*$BMP_PATH/ENGINE:}" == "$PATH" ] && export PATH="$BMP_PATH/ENGINE:$PATH"


echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : Started.$(bmp_shellColour.sh --reset)"

for arg in $@
do
	case "$arg" in

		-b|--bmp_directory)

			bmp_directory=$2
			export BMP_PATH=$bmp_directory # overwrite BMP_PATH if bmp_directory is specified.
			shift 2
			;;

		-s|--spm_directory)

			spm_directory=$2
			export BMP_SPM_PATH=$spm_directory
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

			echo "[$(date)] : bmp_init.sh : Unknown flag $arg"
			echo "[$(date)] : bmp_init.sh : "
			usage
			exit 1
			;;

	esac
done

[ -z ${BMP_PATH:+x} ]     && echo -e "$(bmp_convention.sh --text_error)[$(date)] : bmp_init.sh : BMP_PATH is not set.$(bmp_shellColour.sh --reset)"     && exit 1
[ -z ${BMP_SPM_PATH:+x} ] && echo -e "$(bmp_convention.sh --text_error)[$(date)] : bmp_init.sh : BMP_SPM_PATH is not set.$(bmp_shellColour.sh --reset)"     && exit 1
[ -z ${BMP_3RD_PATH:+x} ] && echo -e "$(bmp_convention.sh --text_error)[$(date)] : bmp_init.sh : BMP_3RD_PATH is not set.$(bmp_shellColour.sh --reset)" && exit 1

if [ -z ${BMP_TMP_PATH:+x} ]; then
	BMP_TMP_PATH=`mktemp -d -t bmp.XXX`
	export $BMP_TMP_PATH
	echo -e "$(bmp_convention.sh --text_warning)[$(date)] : bmp_init.sh : BMP_TMP_PATH is not set. Created one at $BMP_TMP_PATH.$(bmp_shellColour.sh --reset)"
fi

# print BMP_PATH and BMP_3RD_PATH
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : BMP directory is set to $BMP_PATH.$(bmp_shellColour.sh --reset)"
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : BMP SPM directory is set to $BMP_SPM_PATH.$(bmp_shellColour.sh --reset)"
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : BMP 3rd party software directory is set to $BMP_3RD_PATH.$(bmp_shellColour.sh --reset)"
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : BMP temporary directory is set to $BMP_TMP_PATH.$(bmp_shellColour.sh --reset)"

# add relevant path to PATH
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : Setting PATH.$(bmp_shellColour.sh --reset)"

[ "${PATH#*$BMP_PATH/ENGINE:}" == "$PATH" ] && export PATH="$BMP_PATH/ENGINE:$PATH"  # ENGINE
[ "${PATH#*$BMP_PATH/BIDS:}" == "$PATH" ] && export PATH="$BMP_PATH/BIDS:$PATH"      # BIDS
[ "${PATH#*$BMP_PATH/sMRI:}" == "$PATH" ] && export PATH="$BMP_PATH/sMRI:$PATH"      # sMRI
[ "${PATH#*$BMP_PATH/fMRI:}" == "$PATH" ] && export PATH="$BMP_PATH/fMRI:$PATH"      # fMRI


echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : Finished ($?)."
echo -e "$(bmp_convention.sh --text_normal)[$(date)] : bmp_init.sh : If you haven't installed required third party software, you can call bmp_install.sh to install.$(bmp_shellColour.sh --reset)"