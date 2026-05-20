library(tidyverse)
library(sf)
library(terra)
withwater_fold <- "/hpc/group/dataplus26/AITreeMapping/05grids/withwater"

water_dir <- "~/AITreeMapping/03members/TateCommission/water_dir"
unzip("/hpc/group/dataplus26/AITreeMapping/05grids/HydroLAKES_polys_v10_shp.zip", exdir = water_dir)

sf_use_s2(FALSE)
water_sf <- st_read(file.path(water_dir, "HydroLAKES_polys_v10_shp/HydroLAKES_polys_v10.shp")) %>%
  filter(Lake_area > 10) %>%
  st_simplify(dTolerance = 0.01) %>%
  filter(!st_is_empty(.)) %>%
  st_union()

folders <- list.files(withwater_fold, full.names = TRUE, pattern = "malawi_grid_025deg_\\d+")
for (folder in folders) {
  for (shp in list.files(folder, full.names = TRUE, pattern = "\\.shp$")) {
    tiles <- st_read(shp)
    water_proj <- st_transform(water_sf, st_crs(tiles))
    result <- st_difference(tiles, water_proj)
    out <- file.path("~/AITreeMapping/03members/TateCommission/without_water_tiles", basename(folder), basename(shp))
    dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
    st_write(result, out)
  }
}