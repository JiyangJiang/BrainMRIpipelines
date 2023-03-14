#!/bin/bash

studyFolder=/g/data/ey6/Jiyang/myTmp

cd $studyFolder
for i in sub-*
do
cat << EOT > $i/eddy/eddy.pbs
#!/bin/bash
#PBS -P ey6
#PBS -q gpuvolta
#PBS -l ngpus=1
#PBS -l ncpus=12
#PBS -l mem=96GB
#PBS -l walltime=01:00:00
#PBS -l jobfs=50GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -e $studyFolder/$i/eddy/eddy.pbs.err
#PBS -o $studyFolder/$i/eddy/eddy.pbs.out

cd $studyFolder

eddy_cuda10.2 	--imain=$i/dwi_denUnr \
				--mask=$i/synB0discoOutput/b0_all_topup_Tmean_brain_mask \
				--acqp=acqparams.txt \
				--index=index.txt \
				--slm=linear \
				--bvecs=$i/bvec \
				--bvals=$i/bval \
				--repol \
				--out=$i/eddy/eddy \
				--niter=8 \
				--fwhm=10,8,4,2,0,0,0,0 \
				--ol_type=sw \
				--mporder=8 \
				--s2v_niter=8 \
				--topup=$i/synB0discoOutput/topup \
				--data_is_shelled \
				--verbose
EOT

# qsub eddy job
qsub $i/eddy/eddy.pbs

done

# no need to consider multiple B0's for eddy
# ref : https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind0808&L=FSL&P=R859