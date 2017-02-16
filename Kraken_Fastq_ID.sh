#!/bin/bash -l

for k in *.fastq
do
	echo
	kraken --db $kraken_db --fastq-input $k > ${k:0: -6}.kraken
	kraken-translate --db $kraken_db ${k:0: -6}.kraken > ${k:0: -6}.labels
done

python Kraken_Multi_Maker.py
