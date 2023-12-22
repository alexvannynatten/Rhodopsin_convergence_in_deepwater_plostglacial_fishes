#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the absorbance spectra of different rhodopsin sequences
# Figure 2B
#####################################################################
## Imports files and loads libraries

library(tidyverse)

Lmax_p_df <- read.csv('Lambda_max_points_out.csv')
Lmax_c_df <- read.csv('Lambda_max_curves_out.csv')

#####################################################################
# Tidys and plots the data

Lmax_p_df_tidy <- gather(Lmax_p_df, 'Species', 'Normalized_Absorbance', -Wavelength_nm)
Lmax_c_df_tidy <- gather(Lmax_c_df, 'Species', 'Normalized_Absorbance', -Wavelength_nm)

ggplot() + 
geom_point(data = Lmax_p_df_tidy, 
	aes(x = Wavelength_nm, y = Normalized_Absorbance, colour = Species), shape = 1) + 
xlim(400, 600) + ylim(0,1) + 
geom_line(data = Lmax_c_df_tidy, 
	aes(x = Wavelength_nm, y = Normalized_Absorbance, colour = Species)) + 
xlim(400, 600) + ylim(0,1.2) + 
theme_minimal()

ggsave('output2/Lmax_plot.pdf')

#####################################################################