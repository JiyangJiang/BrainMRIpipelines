# KATANA - jobs
# +++++++++++++
#!/bin/bash
#PBS -l select=1:ncpus=2:mem=8gb
#PBS -l walltime=02:00:00
#PBS -j oe
#PBS -N prep
#PBS -o /srv/scratch/cheba/NiL/UKB/wmh/training_2021SEP06_trainFrom20k/1003977.oe


# KATANA - interactive job
# ++++++++++++++++++++++++
qsub -I -l ncpus=2,mem=16gb,walltime=12:00:00


# --=== KATANA oneDrive ===---
rclone config reconnect myOneDrive:
rclone mount myOneDrive: /srv/scratch/cheba/NiL/jiyang/1drive --daemon --vfs-cache-mode writes


# Gadi - copy/move to mdss
# ========================

# Ref: https://opus.nci.org.au/display/Help/Massdata+User+Guide
netcp -l storage=scratch/ey6+gdata/ey6,mem=16gb -C -t w2_w3.tar w2_w3 Jiyang/OATS/freesurfer/v7.1.0/recon-all_cross-sectional # upload to mdss; copy w/o removing
qsub -P ey6 -q copyq -l ncpus=1,mem=4GB,walltime=10:00:00,wd,storage=gdata/ey6+scratch/ey6+massdata/ey6 -- mdss get Jiyang/UKB/dti2mni_forJing/fa.tar # download from mdss, note no destination is needed


# ++++++++++++++++++ #
# Gadi - interactive #
# ++++++++++++++++++ #
qsub -I -P ey6 -q express -l ncpus=16,mem=64GB,walltime=10:00:00,wd,storage=gdata/ey6,software=matlab_unsw,jobfs=8GB
qsub -I -P ey6 -q gpuvolta -l ngpus=1,ncpus=12,mem=96GB,walltime=10:00:00,wd,storage=gdata/ey6,software=matlab_unsw,jobfs=8GB
qsub -I -P ey6 -q copyq -l ncpus=1,mem=4GB,walltime=10:00:00,wd,storage=gdata/ey6,software=matlab_unsw

# +++++++++++++++++++ #
# Gadi - upload files #
# +++++++++++++++++++ #
rsync -avrPS <local directory> <username>@gadi-dm.nci.org.au:<gdata directory>

# alternatively, start a copyq node job
qsub -I -P ey6 -q copyq -l ncpus=1,mem=8GB,walltime=10:00:00,wd,storage=gdata/ey6
# then scp - NOTE that this needs a password-less connection with public/private key

# +++++++++++++++++++++++++++++++++++++++++++++ #
# Gadi - download with copyq (interactive jobs) #
# +++++++++++++++++++++++++++++++++++++++++++++ #
qsub -I -P ey6 -q copyq -l ncpus=1,mem=4GB,walltime=10:00:00,wd,storage=gdata/ey6,jobfs=10GB

# ++++++++++++++++++++++++++++++++++++++++++ #
# Gadi - git - cannot clone https repository #
# ++++++++++++++++++++++++++++++++++++++++++ #
git config --global http.sslVerify false

# ++++++++++++++++++++++ #
# Gadi - delete all jobs #
# ++++++++++++++++++++++ #
qselect -u $USER -s R | xargs qdel

# +++++++++++++++++++++++++++++++++++++++++++ #
# Gadi - load matlab                          #
# each submitted job needs to load separately #
# +++++++++++++++++++++++++++++++++++++++++++ #
module load matlab/R2019b
module load matlab_license/unsw

# ++++++++++++++++++ #
# Gadi - submit jobs #
# ++++++++++++++++++ #

#!/bin/bash

for i in {1..76};do

cat << EOT > job.$i
#!/bin/bash
#PBS -P ey6
#PBS -q normal
#PBS -l ncpus=2
#PBS -l mem=8GB
#PBS -l walltime=48:00:00
#PBS -l jobfs=4GB
#PBS -l wd
#PBS -V
#PBS -l storage=gdata/ey6
#PBS -e /g/data/ey6/Jiyang/MAS/freesurfer/v7.1.0/cmd/oe/job.${i}.error
#PBS -o /g/data/ey6/Jiyang/MAS/freesurfer/v7.1.0/cmd/oe/job.${i}.out
EOT

cat /g/data/ey6/Jiyang/SCS/freesurfer/FS_recon-all.fsl_sub | awk "NR==$i" >> job.$i
qsub job.$i

done





# interactive SGE job
qrsh -pe smp 2 -l h_vmem=16G -q bigmem.q

# delete all my jobs
# qselect -u $USER | xargs qdel



# ======= #
# suspend #
# ======= #

# If the jobs haven't started you can put them on hold with qhold. Use qrls to restart.

qhold <job ID>
qrls <job ID>

# If they are already running you can use qsig to suspend and resume jobs (you may need 
# extra permissions for that, ask your administrator if that's the case):

qsig -s suspend <job ID>
qsig -s resume <job ID>

# Once you have resumed your job you may have to force it to run with qrun

qrun <job ID>

# Tested on a SLES 11 SP4 system with PBSPro 13.0.2.153173, but I am confident it should 
# work with other POSIX-compliant batch job submission systems.





