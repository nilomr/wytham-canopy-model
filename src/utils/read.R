

# DESCRIPTION ──────────────────────────────────────────────────────────────── #

# Functions and variable definitions related to path management and
# data ingest.

# DEPENDENCIES ─────────────────────────────────────────────────────────────── #

box::use(rprojroot[find_rstudio_root_file])
box::use(sp[coordinates, proj4string, CRS, spTransform])
box::use(terra[ext])
box::use(magrittr[`%>%`])
box::use(dplyr[tibble, mutate, pull])
box::use(purrr[map])
box::use(raster[raster, crop, mosaic])
box::use(rgdal[readGDAL])
box::use(utils[unzip])
box::use(fs[file_move])

# PATH VARIABLES ───────────────────────────────────────────────────────────── #


root_dir <- find_rstudio_root_file()
data_dir <- file.path(root_dir, "data")
raw_data_dir <- file.path(root_dir, "data", "raw")
figs_dir <- file.path(root_dir, "reports", "figures")
DTM_dir <- file.path(raw_data_dir, "DTM")
DSM_dir <- file.path(raw_data_dir, "DSM")
perimeter_dir <- file.path(
  raw_data_dir, "contour_shapefile",
  "perimeter poly with clearings_region.shp"
)

dirlist <- c(DTM_dir, DSM_dir)
for  (dir in dirlist) {
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
}

# FUNCTIONS ────────────────────────────────────────────────────────────────── #


#' Extracts zips containing DTM and DSM data to folders of the same name
#'
#' @param zipfiles List of full paths to zip files.
#' @return none
#' @examples
#' zipfiles <- Sys.glob(file.path(basepath, "*.zip"))
#' extract.zipfiles(zipfiles)
extract_zipfiles <- function(zipfiles) {
  for (zipfile in zipfiles) {
    if (grepl("DTM", zipfile, fixed = TRUE)) {
      sapply(zipfile, unzip, exdir = DTM_dir)
    } else {
      sapply(zipfile, unzip, exdir = DSM_dir)
    }
  }
}

#' Moves Tif data from DEFRA from P_* subfolder - one directory up
#'
#' @param none
#' @return none
move_if_tif <- function() {
  for (dir in dirlist) {
    if (length(list.files(dir, "$P*", full.names = T)) == 1) {
      pdir <- list.files(dir, "$P*", full.names = T)
      files <- list.files(pdir, pattern = "*.tif$")
      lapply(files, function(file) {
        file_move(file.path(pdir, file), dir)
      })
    }
  }
}

#' Reads and combines .asc files found in the provided directory
#'
#' @param path a pathlike string.
#' @param boundbox object of class extent (xmin, xmax, ymin, ymax).
#' @return a raster object.
#' @examples
#' data_path <- "./data/lidar-dsm-1m-wytham/"
#' boundbox <- raster::extent()
#' data <- combine.ascfiles(data_path, boundbox)
combine_ascfiles <- function(path, boundbox) {
  tmp <-
    tibble(file = list.files(path, "*.asc$", full.names = T)) %>%
    mutate(raster = map(file, .f = ~ raster(readGDAL(.)))) %>%
    pull(raster)
  tmp$fun <- mean
  model <- do.call(mosaic, tmp) %>%
    crop(., boundbox)
  return(model)
}


#' Reads and combines .tif files found in the provided directory
#'
#' @param path a pathlike string.
#' @param boundbox object of class extent (xmin, xmax, ymin, ymax).
#' @return a raster object.
#' @examples
#' data_path <- "./data/lidar-dsm-1m-wytham/"
#' boundbox <- raster::extent()
#' data <- combine.ascfiles(data_path, boundbox)
combine_tiffiles <- function(path, boundbox) {
  tmp <-
    tibble(file = list.files(path, "*.tif$", full.names = T)) %>%
    mutate(raster = map(file, .f = ~ raster(readGDAL(.)))) %>%
    pull(raster)
  tmp$fun <- mean
  model <- do.call(mosaic, tmp) %>%
    crop(., boundbox)
  return(model)
}


#' Reproject epsg:4326 lat long to another system
#'
#' @param lat float
#' @param long float
#' @param epsg_code string (e.g.,'epsg:27700')
#' @return numeric, reprojected x, y
latlon_reproj <- function(lat, long, epsg_code) {
  data <- data.frame(long = long, lat = lat)
  sp::coordinates(data) <- ~ long + lat
  sp::proj4string(data) <- sp::CRS("+init=epsg:4326")
  xy <- data.frame(sp::spTransform(data, sp::CRS(paste0("+init=", epsg_code))))
  colnames(xy) <- c("x", "y")
  return(unlist(xy))
}


#' Reproject epsg:4326 lat long to another system
#'
#' @param obj SpatRaster instance
#' @param crop_factor how much to crop
#' @return extension object (bounding box) for SpatRaster instance
make_crop_view <- function(obj, crop_factor) {
  cmh_ext <- ext(obj)
  xmid <- cmh_ext[1] + ((cmh_ext[2] - cmh_ext[1]) / 2)
  ymid <- cmh_ext[3] + ((cmh_ext[4] - cmh_ext[3]) / 2)
  red <- (cmh_ext[2] - cmh_ext[1]) * crop_factor
  cropp_view <- ext(xmid - red, xmid + red, ymid - red, ymid + red)
  return(cropp_view)
}