#!/bin/bash -l
# Requires Kraken and the python script Kraken_Multi_Maker.py to be installed.
# Outputs a text file with the top 5 species matches for each fastq file in the folder.
for k in *.fastq
do
	echo
	kraken --db $kraken_db --fastq-input $k > ${k:0: -6}.kraken
	kraken-translate --db $kraken_db ${k:0: -6}.kraken > ${k:0: -6}.labels
done

python Kraken_Multi_Maker.py
