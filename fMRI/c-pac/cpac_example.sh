# This script process BIDS data on GRID

bids_dir=/data2/jiyang/test_bids

mdkir -p ${bids_dir}/derivatives/c-pac/working

docker run -i --rm -v ${bids_dir}:/bids_dataset \
				   -v ${bids_dir}/derivatives/c-pac:/outputs \
				   -v ${bids_dir}/derivatives/c-pac/working:/scratch \
				   fcpindi/c-pac:latest \
				   --n_cpus 8 \
				   --mem_gb 64 \
				   /bids_dataset /outputs participant
