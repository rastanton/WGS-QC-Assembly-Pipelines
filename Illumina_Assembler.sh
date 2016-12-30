#!/bin/bash -l
#script to be run in folder with *.fastq or *.fastq.gz files from Illumina WGS
#Requires bbduk, trimmomatic, SPAdes, and Contig_500_Trimmer to be installed

#make relevant directories
mkdir PhiX_Free
mkdir PhiX_Free_Trimmed_Reads
mkdir Trimmed_Contigs
mkdir Plasmid_Contigs

#unzip any zipped fastq files
gzip -d *.fastq.gz

#remove PhiX with bbduk, trim adapter sequences with trimmomatic, de novo assembly with SPAdes and plasmid assembly with plasmidSPAdes
for k in *R1_001.fastq
do
	echo
	bbduk.sh -Xmx20g threads=12 in=$k in2=${k:0: -18}2_001.fastq out=${k:0: -18}_PhiX_R1.fastq out2=${k:0: -18}_PhiX_R2.fastq ref=/path/to/phix174.fasta k=31 hdist=1	
	
	trimmomatic PE -phred33 -threads 12 ${k:0: -18}_PhiX_R1.fastq ${k:0: -18}_PhiX_R2.fastq ${k:0: -18}_R1_paired_trimmed.fastq ${k:0: -18}_R1_single_trimmed.fastq ${k:0: -18}_R2_paired_trimmed.fastq ${k:0: -18}_R2_single_trimmed.fastq ILLUMINACLIP:/path/to/adapters.fasta:2:20:10:8:TRUE SLIDINGWINDOW:20:30 LEADING:20 TRAILING:20 MINLEN:50

	spades.py -t 16 --careful --only-assembler -1 ${k:0: -18}_R1_paired_trimmed.fastq -2 ${k:0: -18}_R2_paired_trimmed.fastq -o ${k:0: -18}_full_assembly

	spades.py -t 16 --plasmid --careful --only-assembler -1 ${k:0: -18}_R1_paired_trimmed.fastq -2 ${k:0: -18}_R2_paired_trimmed.fastq -o ${k:0: -18}_plasmid_assembly
done

#move files to relevant directories
for i in *PhiX*.fastq; do mv $i PhiX_Free/; done
for j in *trimmed.fastq; do mv $j PhiX_Free_Trimmed_Reads/; done
for l in *full_assembly; do cp $l/contigs.fasta Assemblies/${l:0: -13}_contigs.fasta; done
for m in *plasmid_assembly; do cp $m/contigs.fasta Plasmid_Contigs/${m:0: -17}_plasmid_contigs.fasta; done

#remove contigs shorter than 500 nucleotieds from full assemblies
for n in *full_assembly; do cp $n/contigs.fasta Trimmed_Contigs/${n:0: -13}_contigs.fasta; done
cd Trimmed_Contigs/
for q in *contigs.fasta; do python path/to/Contig_500_Trimmer.py $q; done
