#!/bin/bash

#
# DESCRIPTION
#
#   This script takes subject ID (with or without 'sub-'),
#   and returns subject ID without 'sub-'.
#
# HISTORY
#
#   - 28 Nov 2022, Written by Jiyang Jiang
#

usage () {

cat << EOF

$(basename $0)

DESCRIPTION

  This script takes subject ID (with or without 'sub-'),
  and returns subject ID without 'sub-'.


USAGE

  $(basename $0) {-s|--subject_ID} <subject_ID>


COMPULSORY

  -s, --subject_ID     <subject_ID>    Subject ID with or without
                                       'sub-'.


OPTIONAL

  -h, --help                           Display this message.


OUTPUT

  Subject ID without 'sub-'.


EOF

}

for arg in $@
do
	case $arg in

		-s|--subject_ID)
			
			subject_ID=$2
			shift 2
			;;

		-h|--help)

			usage
			exit 0
			;;

		-*)

			usage
			exit 1
			;;

	esac
done

if [[ "$subject_ID" == "sub-"* ]]; then
	echo $subject_ID | awk -F 'sub-' '{print $2}'
else
	echo $subject_ID