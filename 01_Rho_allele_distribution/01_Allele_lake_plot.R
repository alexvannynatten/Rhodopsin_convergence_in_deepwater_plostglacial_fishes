#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the distribution of rhodopsin alleles in both species as a scatter plot
# Figure 1b
# Table S1
#####################################################################
## Imports files and loads libraries

library(tidyverse)

Rho_alleles <- read.csv('Rh1_allele_data.csv')
Loc_codes <- read.csv('Sample_location_codes.csv')

#####################################################################
# Transforms the dataset for plotting in ggplot

Rho_allele_df <- Rho_alleles %>%
	mutate(Code = gsub('\\_.*', '', Location_code)) %>%
	filter(Location_code %in% Loc_codes$Code) %>%
	select(Species, Code, Rh1_allele_1, Rh1_allele_2) %>%	
	pivot_longer(!c(Species, Code), 
		names_to = "Allele_name", values_to = "Allele_type") %>%
	group_by(Allele_type, Code, Species) %>%
	summarize(n = n()) %>% 
	mutate(Code = factor(Code, levels = unique(Loc_codes$Code)))

#####################################################################
# Plots the alleles detected in each species in each lake

# Dataset summarized for plotting Figure 1b
Rho_allele_df_plot <- Rho_allele_df %>%
	mutate(Genus = gsub('\\ .*', '', Species)) %>%
	mutate(Class = ifelse(Code %in% c('HU', 'SU', 'MI'), 'Upper', 'Other'))

# Sculpin plot
ggplot(Rho_allele_df_plot %>%
		filter(Genus == 'Myoxocephalus'), 
		aes(x = Code, y = Allele_type)) +
	geom_point(aes(fill = Class, shape = Species), size = 5) + 
	geom_text(aes(colour = Class, label = Code), size = 2) + 
	scale_colour_manual(values = c("Black", "White")) + 
	scale_fill_manual(values = c("White", "Black")) + 
    scale_shape_manual(values = c(22,21)) +
	theme_void()

ggsave('01_output/rho_alleles_by_lake_Sculpin.pdf')

# Cisco plot
ggplot(Rho_allele_df_plot %>%
		filter(Genus == 'Coregonus') %>%
		distinct(Genus, Code, Class), 
		aes(x = Code, y = Allele_type)) +
	geom_point(aes(fill = Class), size = 5, shape = 21) + 
	geom_text(aes(colour = Class, label = Code), size = 2) + 
	scale_colour_manual(values = c("Black", "White")) + 
	scale_fill_manual(values = c("White", "Black")) + 
	theme_void()

ggsave('01_output/rho_alleles_by_lake_Cisco.pdf')

#####################################################################
# Summarizes the dataset for export to supp table S1

Rho_allele_table <- Rho_allele_df %>%
	select(!Species) %>%
	group_by(Allele_type, Code) %>%
	summarize(n = sum(n)) %>%
	pivot_wider(names_from = Allele_type, values_from = n) %>%
	left_join(Loc_codes) %>%
	arrange(Longitude)

write.csv(Rho_allele_table, '01_output/Rho_allele_table.csv', row.names = FALSE)

#####################################################################

