# FULL SET  01 02 04 06 09 10 12 15 16 17 18 19 20 21 23 24 26 28 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 47 48 49 51 52 53 54 55 57 58 59 60 61 62 63 64 66 67 68 69 70 71 72 73

for fil in 04 06 09 10 12 15 16 17 18 19 20 21 23 24 26 28 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 47 48 49 51 52 53 54 55 57 58 59 60 61 62 63 64 66 67 68 69 70 71 72 73

#for fil in 01 02

do

fil1=`ls "$fil"_*.merged.non_rRNA.R1.fastq.gz`
fil2=`ls "$fil"_*.merged.non_rRNA.R2.fastq.gz`

nl=`expr ${#fil1} - 28`

filo1=${fil1:0:$nl}.non_rRNA.R1.paired.fastq.gz
filo2=${fil2:0:$nl}.non_rRNA.R2.paired.fastq.gz

filo1u=${fil1:0:$nl}.non_rRNA.R1.unpaired.fastq.gz
filo2u=${fil2:0:$nl}.non_rRNA.R2.unpaired.fastq.gz

ls $fil1 $fil2
echo $filo1 $filo2

#ls $filo1 $filo2

qsub -v "fil1=$fil1,fil2=$fil2,fil1p=$filo1,fil1up=$filo1u,fil2p=$filo2,fil2up=$filo2u" Trim.pbs

done


