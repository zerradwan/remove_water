library(tidyverse)
library(sf)
library(terra)
withwater_fold <- "/hpc/group/dataplus26/AITreeMapping/05grids/withwater"
output_folder <- "~/AITreeMapping/03members/TateCommission/without_water_tiles"

water_dir <- "~/AITreeMapping/03members/TateCommission/water_dir"
unzip("/hpc/group/dataplus26/AITreeMapping/05grids/HydroLAKES_polys_v10_shp.zip", exdir = water_dir)

sf_use_s2(FALSE)
water_sf <- st_read(file.path(water_dir, "HydroLAKES_polys_v10_shp/HydroLAKES_polys_v10.shp")) %>%
  filter(Lake_area > 10) %>%
  st_transform(32736) %>%
  st_simplify(dTolerance = 1000) %>%
  st_transform(4326) %>%
  st_union()

folders <- list.files(withwater_fold, full.names = TRUE, pattern = "malawi_grid_025deg_\\d+")

for (folder in folders) {
  for (tif in list.files(folder, full.names = TRUE, pattern = "\\.tif$")) {
    r <- rast(tif)
    water_proj <- water_sf %>% st_transform(crs(r)) %>% vect()
    r_masked <- mask(r, water_proj, inverse = TRUE)
    out <- file.path(output_folder, basename(folder), basename(tif))
    dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
    writeRaster(r_masked, out, overwrite = TRUE)
  }
}