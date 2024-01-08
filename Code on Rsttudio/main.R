library(dplyr)
library(raster)
library(ncdf4)

color <- 
  
folder_path_Jan <- "D:/GNSS/2022/1_2022"

all_data_Jan <- data.frame()
for (day in 01:31) {  
  nc_file_Jan <- sprintf("ucar_cu_cygnss_sm_v1_2022_%03d.nc", day)
  nc_path_Jan <- file.path(folder_path_Jan, nc_file_Jan)
  
  if (file.exists(nc_path_Jan)) {
    nc_Jan <- nc_open(nc_path_Jan)
    longitude_Jan <- ncvar_get(nc_Jan, "longitude")
    latitude_Jan <- ncvar_get(nc_Jan, "latitude")
    SM_daily_Jan <- ncvar_get(nc_Jan, "SM_daily")
    nc_close(nc_Jan)
    
    daily_data_Jan <- data.frame(
      lon = as.vector(longitude_Jan),
      lat = as.vector(latitude_Jan),
      sm_daily = as.vector(SM_daily_Jan)
    )
    
    daily_data_Jan$day <- day
    all_data_Jan <- bind_rows(all_data_Jan, daily_data_Jan)
  } else {
    warning(paste("File not found:", nc_path_Jan))
  }
}

lon_min <- 68.7
lon_max <- 97.25
lat_min <- 8.4
lat_max <- 37.6

filtered_data_india_Jan <- all_data_Jan %>%
  filter(lon >= lon_min & lon <= lon_max & lat >= lat_min & lat <= lat_max)

daily_data_Jan$sm_daily[is.na(daily_data_Jan$sm_daily)] <- 0
raster_object <- raster(extent(lon_min, lon_max, lat_min, lat_max), resolution = c(0.5, 0.5))
rasterized <- rasterize(filtered_data_india_Jan[, c("lon", "lat")], raster_object, field = filtered_data_india_Jan$sm_daily, fun = mean)
library(viridis)
colors <- viridis(100, direction = -1)
plot(rasterized, main = "India Soil Moisture Map January 2022", col = viridis(100, direction = -1))
title(main = "India Soil Moisture Map January 2022", xlab = "Longitude", ylab = "Latitude")