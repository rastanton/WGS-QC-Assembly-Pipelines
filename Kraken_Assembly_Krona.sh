#!/bin/bash -l
# Makes a basepair waited Kraken output from a .fna file
# Usage: bash Kraken_Assembly_Local_Krona.sh My_File.fna
k=$1
kraken --threads 12 --db /path/to/minikraken_20141208 $k > ${k:0: -4}.kraken
python /path/to/Python_Scripts/Kraken_Assembly_Converter_2_Exe.py ${k:0: -4}.kraken
kraken-translate --db /home/njr5/minikraken_20141208 ${k:0: -4}.kraken > ${k:0: -4}.labels
kraken-report --db /home/njr5/minikraken_20141208 ${k:0: -4}_BP.kraken > ${k:0: -4}_contig_data.txt
python /path/to/Python_Scripts/Kraken_Assembly_Summary_Exe.py ${k:0: -4}.kraken ${k:0: -4}.labels ${k:0: -4}_contig_data.txt ${k:0: -4}_BP_data.txt
cut -f2,3 ${k:0: -4}_BP.kraken > ${k:0: -4}_BP_krona.in
ktImportTaxonomy ${k:0: -4}_BP_krona.in -o ${k:0: -4}_BP_krona.html
rm ${k:0: -4}.kraken
rm ${k:0: -4}.labels
rm ${k:0: -4}_contig_data.txt
rm ${k:0: -4}_BP_krona.in
