#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the distance to the chromophore and site 261 in sites that differ in ciscoes and sculpin
# Figure 2c
#####################################################################
## Imports files and loads libraries

library(tidyverse)

ret_dist_df <- read.csv('03_output/shortest_distance_to_ret_out.csv', header = FALSE)
site261_dist_df <- read.csv('03_output/shortest_distance_to_site261_out.csv', header = FALSE)

#####################################################################
# Some dataframe transformations

plot_df <- rbind(ret_dist_df, site261_dist_df)
plot_df2 <- plot_df[ ,c(3,7:10)]
colnames(plot_df2) <- c('To_AA', 'From_AA', 'Site', 'Atom', 'Distance')

plot_df2$Site <- as.numeric(gsub("[^0-9]", "", plot_df2$Site))

plot_df3 <- plot_df2[c('To_AA', 'Site', 'Distance')] %>% 
  spread(To_AA, Distance)

#####################################################################

ggplot(plot_df3) + 
	geom_point(aes(RET, PHE), size = 10, shape = 21, fill = 'grey70') + 
	geom_text(aes(RET, PHE, label = Site)) +
	scale_x_continuous(expand = c(0, 0), limits = c(0, 30)) +
	scale_y_continuous(expand = c(0, 0), limits = c(0, 30)) +
	theme_classic() + 
	theme(panel.grid.major = element_line(colour = "grey90")) + 
	theme(panel.grid.minor = element_line(colour = "grey90")) + 
	theme(axis.ticks.length=unit(0.30,"cm")) +
	theme(panel.grid.major.x = element_blank()) + 
	theme(panel.grid.minor.x = element_blank())

ggsave('03_output/aa_distances_to_ret_and_261.pdf')

#####################################################################