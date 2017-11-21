import sys
import glob
from Bio import SeqIO

def String_Converter(Input_String):
    Counter = 0
    Character = Input_String[0]
    Current_String = ''
    Out_List = []
    while Counter < len(Input_String):
        if Character == '\n':
            Out_List.append(Current_String)
            return Out_List
        elif Character == '\t' or Character == ',':
            Out_List.append(Current_String)
            Current_String = ''
            Counter = Counter + 1
            Character = Input_String[Counter]
        else:
            Current_String = Current_String + Character
            Counter = Counter + 1
            Character = Input_String[Counter]

def Minimum_Contig(input_kraken):
    f = open(input_kraken, 'r')
    String1 = f.readline()
    List1 = String_Converter(String1)
    Minimum = int(List1[3])
    while String1 != '':
        List1 = String_Converter(String1)
        if Minimum > int(List1[3]):
            Minimum = int(List1[3])
            String1 = f.readline()
        else:
            String1 = f.readline()
    f.close()
    return Minimum

def Kraken_Assembly_Converter_2(input_kraken, output_kraken):
    """Reads in a kraken input file and an input fasta and makes a bp weighted kraken file"""
    Min_Length = Minimum_Contig(input_kraken)
    f = open(input_kraken, 'r')
    g = open(output_kraken, 'w')
    String1 = f.readline()
    while String1 != '':
        List1 = String_Converter(String1)
        Count = int(round(float(List1[3]) / Min_Length))
        Out_Line = ''
        for items in List1[0:4]:
            Out_Line = Out_Line + items + '\t'
        Out_Line = Out_Line[0:-1] + '\n'
        for numbers in range(Count):
            g.write(Out_Line)
        String1 = f.readline()
    f.close()
    g.close()

Kraken_Assembly_Converter_2(sys.argv[1], sys.argv[1][0:-7] + '_BP.kraken')
