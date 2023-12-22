#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots the downwelling light spectra underwater in Lake Huron
# Figure 2A
#####################################################################
## Imports files and loads libraries

library(tidyverse)

# Dataframe for surface irradiance (digitized from Jerome 1983 Fig1)
	# Median W/m2/s converted to Photons/m2/s using Eq1 in Harrington et al. 2015
	# Point estimates smoothed across 410-690 nm range using Loess approach
surface_irr <- data.frame(Wavelength = 410:690) %>%
	left_join(read.csv('Io_Jerome1983.csv')) %>%
	  	mutate(I0 = Percent * 500 * 1015 * Wavelength) %>%
	mutate(I0_Loess = predict(loess(I0 ~ Wavelength, span=0.5),
  	data.frame(Wavelength = Wavelength))) %>%
  	select(Wavelength, I0_Loess)

# Dataframe for attenuation coefficient (digitized from Jerome 1983 Fig3b and Fig 4b)
	# Point estimates smoothed across 410-690 nm range using Loess approach and span of 0.5
light_att <- data.frame(Wavelength = 410:690) %>%
	left_join(read.csv('Kd_Jerome1983.csv')) %>%
	gather('Water_type', 'Kd', -Wavelength) %>%
	group_by(Water_type) %>% 
	mutate(Kd_Loess = predict(loess(Kd ~ Wavelength, span=0.5),
	data.frame(Wavelength = Wavelength))) %>%
  	select(Wavelength, Water_type, Kd_Loess)

#####################################################################

# One percent of the median surface irradiance
one_perc_surf <- median(surface_irr$I0_Loess) / 100

# Depth where each wavelength is equal to the median of 1% of total surface irradiance
Spectrum_depth <- light_att %>%
	left_join(surface_irr) %>%
	mutate(Depth_plot = log(I0_Loess/one_perc_surf) / Kd_Loess)

# Calculates the wavelength with the maximum number of photons at each depth
Spectrum_peak <- light_att %>%
	left_join(Spectrum_depth) %>%
	group_by(Water_type) %>%
	expand_grid(Depth_bin = seq(0, 75, by = 1)) %>%
	# filter(Depth_bin < (Depth_plot-4)) %>%
	mutate(Photons = I0_Loess*exp((Kd_Loess*(Depth_bin))*-1)) %>%
	group_by(Water_type, Depth_bin) %>%
	filter(Photons == max(Photons)) %>%
	mutate(Depth_plot = Depth_bin)

#####################################################################

# Plots the data
ggplot() + 
	geom_smooth(data = Spectrum_depth, 
		aes(Wavelength, Depth_plot * -1, color = as.character(Water_type)), 
		method = 'loess', span = 0.5, se=FALSE) + 
	geom_smooth(data = Spectrum_peak %>%
		filter(Water_type == 'Huron_01'), 
		aes(Wavelength, Depth_plot * -1, color = as.character(Water_type)), 
		method = 'loess', se=FALSE, orientation = "y", span = 0.75) +
	geom_smooth(data = Spectrum_peak %>%
		filter(!Water_type == 'Huron_01'), 
		aes(Wavelength, Depth_plot * -1, color = as.character(Water_type)), 
		method = 'loess', se=FALSE, orientation = "y", span = 0.75) +
	theme_test()

ggsave('01_output/Downwelling_light.pdf')

#####################################################################