import sys
import Bio
import glob
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet.IUPAC import unambiguous_dna
from Bio.Seq import MutableSeq
from Bio.Alphabet import IUPAC
from Bio import SeqIO

Contig_Fasta = sys.argv[1]
output_handle = open(Contig_Fasta[0:-6] + '_trimmed.fasta', 'w')
Contig_List = list(SeqIO.parse(Contig_Fasta, 'fasta'))
for contigs in Contig_List:
    if len(str(contigs.seq)) > 500:
        SeqIO.write(contigs, output_handle, 'fasta')
    else:
        continue
output_handle.close()
