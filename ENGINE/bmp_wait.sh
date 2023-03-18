#!/bin/bash

# check operating system, and use the largest
# number of cpu cores.
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
		machine=Linux
		# at most number of CPU cores
		[ $(jobs | wc -l) -ge $(python -c "print(int($(nproc)/2))") ] && wait
		;;

    Darwin*)
		machine=Mac
		# at most number of CPU cores
		[ $(jobs | wc -l) -ge $(python -c "print(int($(sysctl -n hw.physicalcpu)/2))") ] && wait
		;;

    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
# echo ${machine}