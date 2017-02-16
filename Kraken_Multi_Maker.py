import sys
import glob
from decimal import *
getcontext().prec = 3

def String_Converter(Input_String):
    Counter = 0
    Character = Input_String[0]
    Current_String = ''
    Out_List = []
    while Counter < len(Input_String):
        if Character == '\n':
            return Out_List
        elif Character == ';':
            Out_List.append(Current_String)
            Current_String = ''
            Counter = Counter + 1
            Character = Input_String[Counter]
        else:
            Current_String = Current_String + Character
            Counter = Counter + 1
            Character = Input_String[Counter]

def In_List(item, list1):
    """determines if item is in list1"""
    for x in list1:
        if x == item:
            return True
    else: return False

def Repeat_Remover(any_list):
    """Removes repeats for any list"""
    new_list = []
    for items in any_list:
        if In_List(items, new_list) == False:
            new_list.append(items)
    return new_list

def Item_Counter(input_list, item):
    Counter = 0
    for entries in input_list:
        if entries == item:
            Counter = Counter + 1
        else:
            continue
    return Counter

def Species_List_Maker(input_kraken):
    f = open(input_kraken, 'r')
    string1 = f.readline()
    list1 = String_Converter(string1)
    while string1 != '':
        string_list = String_Converter(string1)
        try:
            list1.append(string_list[-1])
            string1 = f.readline()
        except IndexError:
            string1 = f.readline()
    f.close()
    return list1

def List_Counter(input_list):
    Unique_List_unordered = Repeat_Remover(input_list)
    Unique_List = sorted(Unique_List_unordered)
    Output_List = []
    for items in Unique_List:
        Totals = Item_Counter(input_list, items)
        Total_Percent = Decimal(Totals) / Decimal(len(input_list))
        New_Entry = items + '_count_' + str(Total_Percent)
        Output_List.append(New_Entry)
    return Output_List

def Ordered_List_Maker(input_list):
    Unique_List_unordered = Repeat_Remover(input_list)
    Unique_List = sorted(Unique_List_unordered)
    Output_List = []
    for items in Unique_List:
        Totals = Item_Counter(input_list, items)
        Total_Percent = Decimal(Totals) / Decimal(len(input_list))
        New_Entry = str(Total_Percent) + '_' + items
        Output_List.append(New_Entry)
    Output_List.sort(reverse=True)
    return Output_List

def Number_Returner(input_string):
    Temp_string = ''
    for characters in input_string:
        if characters == '_':
            Temp_string = ''
        else:
            Temp_string = Temp_string + characters
    return Temp_string

def Kraken_Kracker_List(input_file):
    Total_List = Species_List_Maker(input_file)
    Species_List = List_Counter(Total_List)
##    Final_List = []
##    for items in Species_List:
##        try:
##            if float(Number_Returner) > 0.01:
##                Final_List.append(items)
##        except TypeError:
##            continue
##        else:
##            continue
    return Species_List

def Kraken_Kracker_List_2(input_file):
    Total_List = Species_List_Maker(input_file)
    Species_List = Ordered_List_Maker(Total_List)
    return Species_List

def Kraken_Info(input_file):
    List1 = Kraken_Kracker_List_2(input_file)
    for items in range(10):
        print(List1[items])

Kraken_List = glob.glob('*.labels')   
f = open('Kraken_Species.txt', 'w')
for files in Kraken_List:
    Species_Totals = Kraken_Kracker_List_2(files)
    for items in range(5):
        f.write(files + '\t' + Species_Totals[items] +'\n')
    f.write('\n')
f.close()
