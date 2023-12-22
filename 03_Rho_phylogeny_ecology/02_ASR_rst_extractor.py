#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Python script for extracting information from PAML rst file output
#####################################################################

import csv
import string
import re

# Opens RST file into a list called rst_list
filename = "rst"
with open(filename) as f:
	rst_list = [line.strip() for line in f]

# Exports tree from RST file with branchlengths scaled by number of substitutions
tree_aabl = rst_list[7]

# Extracts the extant sequences and the ancestral sequences with highest poterior probability
aa_begin = [line for line in range(len(rst_list)) if "List of extant and reconstructed sequences" in rst_list[line]][0]
aa_end = [line for line in range(len(rst_list)) if "Overall accuracy of the" in rst_list[line]][0]

rst_list_2 = rst_list[aa_begin+4:aa_end-2]
nodes, seq = zip(*(i.split("  ", 1) for i in rst_list_2))
nodes = [i.replace('node #', "") for i in nodes]
seq = [i.replace(' ', "") for i in seq]

with open("../../03_output/rst_out_tree.tre", "w") as f:
	f.write(tree_aabl)
	f.close()

rows = zip(nodes, seq)
with open('../../03_output/rst_out_seqs.csv', "w") as f:
    writer = csv.writer(f)
    for row in rows:
        writer.writerow(row)


# Collects marginal posterior probability of every amino acid at each site in each ancestral node
# Requires verbose = 2 in PAML ctl file
pp_begin = [line for line in range(len(rst_list)) if "Prob distribs at nodes, those with p < 0.001 not listed" in rst_list[line]][0]
pp_end = [line for line in range(len(rst_list)) if "Prob of best state at each node, listed by site" in rst_list[line]][0]

rst_list_3 = rst_list[pp_begin+1:pp_end]

# Subsets the important data from the strings of posterior probabilities
node_support = []
node_num = []
for i in rst_list_3:
	if len(i) > 50:
		a,b = i.split(': ')
		node_support.append(re.sub(r'[A-Za-z,(,)]', '',b))
	if 'Prob ' in i:
		c,d = i.split(', ')
		node_num.append(''.join(c.split(' ')[-1:]))

num_sites = int(len(node_support) / len(node_num))
prob_of = re.sub(r'[0-9,(,),.]', '',b)
[j for j in node_num for i in range(num_sites)]
node_num_out = [j for j in node_num for i in range(num_sites)]
num_sites_out = list(range(1, num_sites+1))*len(node_num)



# Combines the data into a datatable for export (tab seperated)
out_list = []
out_list.append("Node " + "Site " + prob_of)

for i in range(len(node_support)):
	out_list.append(str(node_num_out[i]) + " " + str(num_sites_out[i]) + " " + str(node_support[i]))

with open('../../03_output/rst_out_pp.txt', 'w') as f:
    for line in out_list:
        f.write("%s\n" % re.sub(' ', '\t', line))

#####################################################################