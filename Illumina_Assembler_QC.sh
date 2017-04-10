#!/bin/bash -l
#script to be run in folder with *.fastq or *.fastq.gz files from Illumina WGS
#Requires bbduk, trimmomatic, SPAdes, and Contig_500_Trimmer to be installed

#make relevant directories
mkdir PhiX_Free
mkdir PhiX_Free_Trimmed_Reads
mkdir Trimmed_Contigs
mkdir Kraken_Info
mkdir Q_Scores
mkdir Contigs
mkdir Quast
mkdir Quast_Reports
mkdir Final_Reports
mkdir Prokka_Proteins
mkdir Prokka_Genes
mkdir Busco_Reports

#unzip any zipped fastq files
gzip -d *.fastq.gz

#basic QC
for k in *001.fastq
do
	echo
	python /path/to/q30.py $k > ${k:0: -10}_q_scores.txt		
	kraken --db /path/to/minikraken_20141208 --fastq-input $k > ${k:0: -10}_sequences.kraken
	kraken-report --db /path/to/minikraken_20141208 ${k:0: -10}_sequences.kraken > ${k:0: -10}_sequence_data.txt
	cut -f2,3 ${k:0: -10}_sequences.kraken > ${k:0: -10}_krona.in
	ktImportTaxonomy ${k:0: -10}_krona.in -o ${k:0: -10}_krona.html
done

#remove PhiX with bbduk, trim adapter sequences with trimmomatic, de novo assembly with SPAdes and plasmid assembly with plasmidSPAdes
for k in *R1_001.fastq
do
	echo
	bbduk.sh -Xmx20g threads=12 in=$k in2=${k:0: -11}2_001.fastq out=${k:0: -18}_PhiX_R1.fastq out2=${k:0: -18}_PhiX_R2.fastq ref=/path/to/Desktop/Reference_Files/phix174.fasta k=31 hdist=1	
	
	java -jar /path/to/Trimmomatic-0.36/trimmomatic-0.36.jar PE -phred33 -threads 12 ${k:0: -18}_PhiX_R1.fastq ${k:0: -18}_PhiX_R2.fastq ${k:0: -18}_R1_paired_trimmed.fastq ${k:0: -18}_R1_single_trimmed.fastq ${k:0: -18}_R2_paired_trimmed.fastq ${k:0: -18}_R2_single_trimmed.fastq ILLUMINACLIP:/path/to/Desktop/Reference_Files/adapters.fasta:2:20:10:8:TRUE SLIDINGWINDOW:20:30 LEADING:20 TRAILING:20 MINLEN:50

	spades.py -t 12 --careful --only-assembler -1 ${k:0: -18}_R1_paired_trimmed.fastq -2 ${k:0: -18}_R2_paired_trimmed.fastq -o ${k:0: -18}_full_assembly
done

#move files to relevant directories
for m in *_q_scores.txt; do mv $m Q_Scores/; done
for n in *.kraken; do mv $n Kraken_Info/; done
for o in *data.txt; do mv $o Kraken_Info/; done
for p in *krona*; do mv $p Kraken_Info/; done
for i in *PhiX*.fastq; do mv $i PhiX_Free/; done
for j in *trimmed.fastq; do mv $j PhiX_Free_Trimmed_Reads/; done
for l in *full_assembly; do cp $l/contigs.fasta Contigs/${l:0: -13}_contigs.fasta; done

#remove contigs shorter than 500 nucleotieds from full assemblies
for n in *full_assembly; do cp $n/contigs.fasta Trimmed_Contigs/${n:0: -13}contigs.fasta; done
cd Trimmed_Contigs/
for q in *contigs.fasta; do python /path/to/Desktop/Python_Scripts/Contig_500_Trimmer.py $q; done
rm *contigs.fasta

#run prokka on assemblies
for t in *.fasta; do prokka --outdir ${t:0: -6}_prokka --prefix ${t:0: -6}_prokka --genus Pseudomonas --species aeruginosa --usegenus $t; done
for u in *_prokka; do cp $u/*.faa ../Prokka_Proteins/${u:0: -7}_proteins.faa; done
for v in *_prokka; do cp $v/*.ffn ../Prokka_Genes/${v:0: -7}_genes.ffn; done

#run Quast on the assemblies
for r in *.fasta; do python /path/to/quast-4.3/quast.py -R /path/to/Desktop/Reference_Genome -G /path/to/Reference_Genbank -o ../Quast/${r:0: -6}_Assembly_Data $r; done
cd ../Quast
for s in *Assembly_Data; do cp $s/report.txt ../Quast_Reports/${s:0: -5}_Report.txt; done

#run Busco on samples
cd ../Prokka_Proteins
for x in *.faa; do python /path/to/busco/BUSCO.py -i $x -o Busco_$x -l /path/to/busco/DB/gammaproteobacteria_odb9 -m prot -c 12; done
for y in run_Busco_*; do cp $y/*.txt ../Busco_Reports/${y:10: -4}.txt; done
