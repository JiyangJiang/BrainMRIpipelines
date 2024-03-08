#!/bin/bash

cd /d/oasis/3/downloadWithOasisScripts/bids-oasis

ls -1 sub-*/ses*/func/*asl*.nii* | awk -F"/func/" '{print $1}' | uniq > hasASL/subjID_sesID_list.txt

while read i
do
	cp -r $i hasASL/$(echo $i | sed 's/\//_/g')
done < hasASL/subjID_sesID_list.txt