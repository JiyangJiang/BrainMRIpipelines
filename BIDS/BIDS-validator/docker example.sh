docker run --rm -it -v /data2/jiyang/SCS+MW24_allFMRI_and_corresponding_T1DWI_BIDS:/data:ro \
					bids/validator:latest /data \
					--verbose