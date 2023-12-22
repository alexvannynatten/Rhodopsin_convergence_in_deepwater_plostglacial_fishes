#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Generates command line input to measure distances in UCSF Chimera
# Figure 2c
#####################################################################
# Some commands to be carried out in UCSF Chimera

print("1. In UCSF Chimera, open reply log and command line")
print("2. Clear reply log")
print("3. Select first set of atoms you want distances measured to")
print("4. In command line, enter 'list selection' and press enter")
print("5. Save reply log as a text file called distance_to.txt")
print("6. Clear previous selection and the text in reply log")
print("7. Select set of atoms you want distances measured from")
print("8. In command line, enter 'list selection' and press enter")
print("9. Save reply log as a text file called distance_from.txt")

#####################################################################

# Lists of atoms for pairwise distance measurements
to_list = open('distance_to.txt','r').read().split('\n')
to_list = list(filter(None, to_list))
to_list = [line.split()[2] for line in to_list]

from_list = open('distance_from.txt','r').read().split('\n')
from_list = list(filter(None, from_list))
from_list = [line.split()[2] for line in from_list]

# Generates list of all possible combinations of atoms in both lists
import itertools
for combo in itertools.product(to_list, from_list): 
	print('distance ' + combo[0] + ' ' + combo[1])

#####################################################################
# Some more commands to be carried out in UCSF Chimera

print("10. Clear previous selection and text in reply log")
print("11. Paste output into the command line and press enter")
print("12. Save reply log as a text file ... ")

#####################################################################
# Summarizes the results from UCSF Chimera output reporting closest distance

dist_list = open(input("Filename: "),'r').read().split('\n')
dist_list = list(filter(None, dist_list))
dist_list = [line.split() for line in dist_list]

# Sorts the distances from shortest to longest
dist_list = sorted(dist_list, key=lambda x: float(x[-1]))

# Exports a list of the shortest distance between each pair of atoms
aa_sites = list(set([x[-3] for x in dist_list]))
short_dist = [dist_list[[x[-3] for x in dist_list].index(i)] for i in aa_sites]

import csv
with open('distance_out.csv', 'w', newline='') as myfile:
    writer = csv.writer(myfile)
    writer.writerows(short_dist)

#####################################################################