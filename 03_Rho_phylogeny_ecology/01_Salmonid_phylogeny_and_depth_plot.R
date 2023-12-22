#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the species tree of salmonids showing ecological and depth distribution
# Figure 3
#####################################################################
## Imports files and loads libraries

library(rfishbase)
library(tidyverse)
library(ggtree)
library(ggstance)

sp_tree <- read.tree('01_species_tree/sp_tree_bl_salmonid.tre') # tree data
sp_tree$tip.label <- gsub('_', ' ', sp_tree$tip.label)

#####################################################################

# Collects data from fishbase for depths and if any association with marine habitats
depth_df <- species(sp_tree$tip.label, 
	fields=c("Species", "DepthRangeShallow", "DepthRangeDeep", "Saltwater"))

# Adds data specific to the cisco alleles based on published catch data
Tree_df <- data.frame(Species = sp_tree$tip.label) %>%
	left_join(depth_df) %>%
    mutate(Saltwater = replace_na(Saltwater, 0))

Tree_df$DepthRangeShallow[grepl(c("Coregonus sp 1"),Tree_df$Species)] <- 0
Tree_df$DepthRangeDeep[grepl(c("Coregonus sp 1"),Tree_df$Species)] <- 190

Tree_df$DepthRangeShallow[grepl(c("Coregonus sp 2"),Tree_df$Species)] <- 0
Tree_df$DepthRangeDeep[grepl(c("Coregonus sp 2"),Tree_df$Species)] <- 190

Tree_df$DepthRangeShallow[grepl(c("Coregonus sp 3"),Tree_df$Species)] <- 30
Tree_df$DepthRangeDeep[grepl(c("Coregonus sp 3"),Tree_df$Species)] <- 390

# Transforms the database for plotting with ggtree
Tree_df <- Tree_df %>%
	mutate(Mid_depth = (DepthRangeShallow + DepthRangeDeep)/2) %>%
	select(!c(DepthRangeShallow, DepthRangeDeep)) %>%
	gather(depth_df, Mid_depth, -Species, -Saltwater)	

#####################################################################

# Plots the data
p <- ggtree(sp_tree) + geom_tiplab(align=TRUE, linetype='dashed', linesize=.3)

facet_plot(p, panel="Depth (m)", data=Tree_df, 
	geom=geom_barh, mapping = aes(x=as.numeric(Mid_depth), 
		fill = Saltwater), stat='identity') + 
	theme_tree2(legend.position='right')

ggsave('01_output/Salmonid_tree_depth_plot.pdf')

#####################################################################

