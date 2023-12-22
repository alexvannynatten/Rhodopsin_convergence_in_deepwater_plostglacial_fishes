#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Map of sampling sites in Lake Huron
# Figure 1c
#####################################################################
## Imports files and loads libraries

library(tidyverse)
library(sf)
library(raster)

# Loads data and simplifies raster for faster plotting
map <- raster("../raw_data/huron_lld.asc") # obtained from https://www.ngdc.noaa.gov/mgg/greatlakes/huron/data/arc_ascii/huron_lld.asc.tar.gz
ciscoes <- read.csv('LakeHuron_sampling.csv')
map2 <- aggregate(map, fact=5)

#####################################################################

# Converts the raster to a dataframe
map2 <- map2 %>% 
  as.data.frame(xy = TRUE) %>%
  as_tibble() %>% 
  rename(lon = x, lat = y, depth = 3)%>% 
  mutate(depth = as.numeric(depth))

# Subsets the region of intrest
map3 <- map2[map2$lat < 45.75 & map2$lat > 44.25 & 
	map2$lon > -82.25 & map2$lon < -80.75, ]
map3$depth[map3$depth > 0] <- 1

# Plots the bathymetry map
ggplot() +
	geom_contour_filled(data = map3, aes(x = lon, y = lat, z = depth), breaks=c(10,0,-50,-100,-150,-200,-250)) + 
	geom_contour(data = map3, aes(x = lon, y = lat, z = depth), breaks=c(10,0,-50,-100,-150,-200,-250), 
		size = 0.2, colour = 'black') + 
	geom_point(data = ciscoes, aes(Longitude, Latitude), size = 6, , colour = 'black') +
	geom_text(data = ciscoes, aes(Longitude, Latitude, 
		label = Code), colour = 'white', size = 2) +
	coord_fixed(ratio = 1) + 
	scale_x_continuous(limits = c(-82.25,-80.75), expand = c(0, 0)) +
  	scale_y_continuous(limits = c(44.25,45.75), expand = c(0, 0)) + 
	theme(panel.border = element_rect(colour = 'black', fill = NA))

ggsave('04_output/Huron_bathymetry_map.pdf')

#####################################################################