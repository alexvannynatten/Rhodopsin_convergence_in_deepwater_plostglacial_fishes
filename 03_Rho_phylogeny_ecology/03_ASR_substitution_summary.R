#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Converts RST output files to a list of aa substitutions by branch

#####################################################################
## Imports files and loads libraries

library(tidyverse)
library(phytools)

tree <- read.tree("rst_out_tree.tre")
aa_seq <- read.csv("rst_out_seqs.csv",header=FALSE)

#####################################################################
## Converts PAML output tree file to dataframe of nodes bracketing every branch

tree <- makeNodeLabel(tree, method = "number", prefix = "")
tree$node.label <- as.character(as.numeric(tree$node.label) + length(tree$tip.label))
write.tree(tree, file = "rst_out_tree_nodelabels.tre")

branches <- data.frame(node_i = as.character(tree$edge[ ,1]), node_f = as.character(tree$edge[ ,2]))
tree_data <- data.frame(Node = 1:length(c(tree$tip.label, tree$node.label)), 
	Name = c(tree$tip.label, tree$node.label))
branches$node_f <- tree_data$Name[match(branches$node_f, tree_data$Node)]

#####################################################################
## Assigns amino acid substitutions to each branch in the tree

aa_node_i <- aa_seq[match(branches$node_i, aa_seq$V1), ]
aa_node_i_df <- data.frame(strsplit(as.character(aa_node_i$V2), split=NULL))
names(aa_node_i_df) <- as.character(1:length(aa_node_i$V1))
aa_node_i_df$Site <- as.numeric(1:nrow(aa_node_i_df))
aa_node_i_tidy <- gather(aa_node_i_df, "Node_i", "State_i", -Site)
aa_node_i_tidy$Node_i <- aa_node_i$V1[as.numeric(aa_node_i_tidy$Node_i)]
aa_node_i_tidy$Site <- aa_node_i_tidy$Site + 57

aa_node_f <- aa_seq[match(branches$node_f, aa_seq$V1), ]
aa_node_f_df <- data.frame(strsplit(as.character(aa_node_f$V2), split=NULL))
names(aa_node_f_df) <- aa_node_f$V1
aa_node_f_df$Site <- as.numeric(1:nrow(aa_node_f_df))
aa_node_f_tidy <- gather(aa_node_f_df, "Node_f", "State_f", -Site)
aa_node_f_tidy$Site <- aa_node_f_tidy$Site + 57

#####################################################################
## Makes the dataset a tidy dataframe

aa_sub_tidy <- cbind(aa_node_i_tidy, aa_node_f_tidy[2:3])
aa_sub_tidy <- aa_sub_tidy[!aa_sub_tidy$State_i == aa_sub_tidy$State_f, ]
aa_sub_tidy <- aa_sub_tidy[!aa_sub_tidy$State_f %in% c("-", "?"), ]
aa_sub_tidy$Sub <- paste0(aa_sub_tidy$State_i, aa_sub_tidy$Site, aa_sub_tidy$State_f)

write.table(aa_sub_tidy, file = 'rst_out_subs.csv', row.names=FALSE,col.names=TRUE, sep=",")

#####################################################################