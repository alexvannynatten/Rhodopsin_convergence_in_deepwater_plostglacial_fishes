#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Maps the locations sampled in the study across Canada
# Figure 1a
#####################################################################
## Imports files and loads libraries

library(tidyverse)
library(rgdal)

# Canada
land <- map_data(database = "world", regions = "canada")
land_df <- fortify(land)

# Lakes
lakes <- map_data("lakes")
lakes_df <- fortify(lakes)
lakes_df <- lakes_df[
lakes_df$lat > 15 &
lakes_df$lat < 85 &
lakes_df$long > -130 &
lakes_df$long < -50
, ]

# Last glacial maximum
lgm <- readOGR(dsn= paste0(getwd(),"../raw_data/lgm/"), layer="lgm", verbose=FALSE) # Obtained from http://geonode.crc806db.uni-koeln.de:80/geoserver/ows
lgm.points <- fortify(lgm)
lgm.df <- lgm.points[,c("long","lat","group")]
lgm.df2 <- subset(lgm.df, lgm.df$long < -50 & lgm.df$long > -160)
lgm.df3 <- subset(lgm.df2, lgm.df2$lat > 40 & lgm.df2$lat < 100)

#####################################################################

# Plots map
Can_map <- ggplot() + 
	geom_polygon(data = land_df,
	aes(x = long, y = lat, group = group), fill = 'grey80',  size = 0.25, colour = 'grey30') +
	coord_map('lambert', lat0=49, lat1=77, xlim=c(-145, -55), ylim=c(40, 85)) +
	geom_polygon(data = lakes_df, aes(x = long, y = lat, group = group),
	fill = "steelblue", colour = 'grey30', size = 0.25) +
	geom_polygon(data = lgm.df3, aes(x = long, y = lat, group = group), colour = "black", fill = "white") + 
	geom_hline(yintercept = 66) +
	theme_void() + theme(legend.position="none")

Loc_df <- read.csv('Sample_location_codes.csv')
Loc_df$Class <- ifelse(Loc_df$Code %in% c("SU", "HU", "MI"), "Upper", "Other")

# Plots points on the map
Can_map + 
	geom_point(data=Loc_df, aes(x=as.numeric(as.character(Longitude)),
	y=as.numeric(as.character(Latitude)), fill = Class), size = 5, shape = 21) + 
	geom_text(data=Loc_df, aes(x=as.numeric(as.character(Longitude)),
	y=as.numeric(as.character(Latitude)), label = Code, colour = Class), size = 2) + 
	scale_fill_manual(values = c("White", "Black")) +
	scale_colour_manual(values = c("Black", "White"))


# Saves Map output
ggsave("03_output/Canada_map.pdf")

#####################################################################