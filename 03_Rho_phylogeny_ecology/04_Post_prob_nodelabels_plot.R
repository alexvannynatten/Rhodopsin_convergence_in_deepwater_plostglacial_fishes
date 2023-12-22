#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the probability of F/Y 261 across the phylogenies
# Figure 3
#####################################################################
## Imports files and loads libraries

library(phytools)
library(ggtree)
library(dplyr)
library(Biostrings)

#####################################################################
# Loads and cleans data
Tree_df <- read.tree('rst_out_tree_nodelabels.tre')
Seq_data <- read.csv('rst_out_seqs.csv', header=FALSE)
	seq <- Seq_data[[2]]
	names(seq) <- Seq_data[[1]]

Seq_df <- AAStringSet(seq)
Anc_df <- read.table('rst_out_pp.txt', header = TRUE)
Seq_df <- Seq_df[names(Seq_df) %in% Tree_df$tip.label]

#####################################################################
# Makes a dataset of the tips with the amino acid at site 261 indicated by a 1 (F) or 0 (Y)
# 204 -> 261 - 57 (the shift in start position of the fasta)

Tip_data <- data.frame(Species = names(Seq_df), 
	F261 = ifelse(as.character(subseq(Seq_df, 204, 204)) == 'F', 0, 1))

# Adds the ancestral data to a new dataframe in the same order as the tips in the tree
Post_prod_df <- data.frame(node = 1:length(Tree_df$tip.label), 
	F261 = NA)

# Makes a dataframe of the posterior probabilities or each amino acid at site 261
Anc_data261 <- Anc_df[Anc_df$Site == '204', ]
Anc_data261$Node <- as.integer(sub("Node", "", Anc_data261$Node))
Anc_data261 <- Anc_data261[Anc_data261$Node %in% Tree_df$node.label, ]
Post_prod_df <- rbind(Post_prod_df, 
	data.frame(node = length(Tree_df$tip.label) + 1:nrow(Anc_data261), F261 = Anc_data261$F))
Post_prod_df$Y261 <- 1-Post_prod_df$F261

# Loads a tree with branch lengths based on species tree
BL_tree <-read.tree('sp_tree_bl.tre')

#####################################################################
# Plots the posterior probablity of F at ancestral nodes with pies
p <- ggtree(BL_tree) + 
 geom_tiplab(align=TRUE, linetype='dashed', linesize=.3)
p <- revts(p)
#p <- flip(p, 69, 53)
p <- flip(p, 34, 22)
pies <- nodepie(Post_prod_df, cols=2:3)

anc_p <- p + geom_inset(pies, width = .03, height = .03) + 
	theme_tree2(legend.position='right')

anc_p <- anc_p %<+% Tip_data
anc_p + geom_tippoint(aes(color = factor(`F261`)))

ggsave('PP_node_labelled_tree.pdf')

#####################################################################
