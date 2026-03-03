# Reproducible script reproducing notebook code for redlistr demo
# Generates a small sample reef raster, converts between terra and raster packages,
# and runs the main redlistr functions with safe error handling.

# Install only if missing
needed <- c("redlistr", "terra", "raster", "ggplot2")
for (p in needed) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(redlistr)
library(terra)
library(raster)
library(ggplot2)

# Safe key loader for teaching/shared notebooks.
# Read key from environment first.
api_key <- Sys.getenv("IUCN_REDLIST_KEY", unset = "")

# Fallback: read local .env in project root.
if (!nzchar(api_key) && file.exists(".env")) {
  env_lines <- trimws(readLines(".env", warn = FALSE))
  env_lines <- env_lines[nzchar(env_lines) & !grepl("^#", env_lines)]
  key_line <- grep("^IUCN_REDLIST_KEY=", env_lines, value = TRUE)
  if (length(key_line) > 0) {
    api_key <- sub("^IUCN_REDLIST_KEY=", "", key_line[[1]])
    Sys.setenv(IUCN_REDLIST_KEY = api_key)
  }
}
#  API connectivity check
if (nzchar(api_key)) {
  rredlist::rl_api_version()
} else {
  message("No API key found. Add IUCN_REDLIST_KEY in .env or .Renviron.")
}

# Reproducible seed
set.seed(42)

# Output data path
dir.create("data", showWarnings = FALSE)
reef_sample_path <- file.path("data", "reef_sample.tif")

# If the user did not supply a custom reef_sample_url, populate the file with a
# small public example raster that comes with the `raster` package.  This gives
# us a "real" dataset without needing external downloads.
if (!file.exists(reef_sample_path)) {
  try({
    sample_r <- raster::raster(system.file("external/test.grd", package = "raster"))
    raster::writeRaster(sample_r, reef_sample_path, overwrite = TRUE)
    message("Wrote example raster from raster::test.grd to ", reef_sample_path)
  }, silent = TRUE)
}

# Load 2000 raster (either downloaded or example)
reef_2000_spat <- try(terra::rast(reef_sample_path), silent = TRUE)
if (inherits(reef_2000_spat, "try-error")) {
  message("Failed to read sample raster; falling back to synthetic data.")
  reef_2000_spat <- NULL
}

# If we don't have a valid 2000 raster, create synthetic data
if (is.null(reef_2000_spat)) {
  # Create a small synthetic occupancy raster (30 x 20 cells)
  reef_crs <- "EPSG:32755"
  reef_mat <- matrix(sample(c(NA, 1), 600, replace = TRUE, prob = c(0.55, 0.45)), nrow = 30, ncol = 20)
  reef_2000_spat <- terra::rast(reef_mat, crs = reef_crs)
  terra::ext(reef_2000_spat) <- c(0, 6000, 0, 9000)
  message("Generated synthetic reef_2000 raster.")
}

# For 2020, if we loaded a sample file for 2000 we create a modified version to
# simulate change; otherwise just copy the synthetic raster.
if (file.exists(reef_sample_path)) {
  # perturb the 2000 raster: randomly flip ~10% of occupied cells to NA
  reef_2020_spat <- reef_2000_spat
  vals <- terra::values(reef_2020_spat)
  idx <- which(vals == 1)
  nflip <- floor(length(idx) * 0.1)
  if (nflip > 0) vals[sample(idx, nflip)] <- NA
  terra::values(reef_2020_spat) <- vals
  # optionally save modified 2020 file
  try(terra::writeRaster(reef_2020_spat, sub("\\.tif$", "_2020.tif", reef_sample_path), overwrite = TRUE), silent = TRUE)
  message("Created modified 2020 raster by perturbing sample.")
} else {
  reef_2020_spat <- reef_2000_spat
}

# Save small GeoTIFF sample (overwrites to keep reproducible)
try(terra::writeRaster(reef_2000_spat, reef_sample_path, overwrite = TRUE), silent = TRUE)

# For demo, use same raster as 2020; user can replace files later
reef_2020_spat <- reef_2000_spat

# Convert to raster::RasterLayer for compatibility with some redlistr methods
reef_2000_raster <- try(raster::raster(reef_sample_path), silent = TRUE)
if (inherits(reef_2000_raster, "try-error")) {
  # fallback: coerce from terra
  reef_2000_raster <- try(raster::raster(as(reef_2000_spat, "SpatialGridDataFrame")), silent = TRUE)
}
reef_2020_raster <- reef_2000_raster

# Helper to attempt function and print result or message
safe_run <- function(expr, label) {
  res <- tryCatch(
    {
      val <- eval(expr)
      message("[OK] ", label)
      print(val)
      invisible(val)
    },
    error = function(e) {
      message("[ERROR] ", label, ": ", e$message)
      invisible(NULL)
    }
  )
  res
}

# Convert SpatRaster objects to RasterLayer once and then use raster methods
if (exists("reef_2000_spat") && !exists("reef_2000_raster")) {
  reef_2000_raster <- try(raster::raster(reef_2000_spat), silent = TRUE)
}
if (exists("reef_2020_spat") && !exists("reef_2020_raster")) {
  reef_2020_raster <- try(raster::raster(reef_2020_spat), silent = TRUE)
}

# AOO: compute only using RasterLayer (SpatRaster dispatch unsupported)
reef_aoo_2000 <- safe_run(
  quote(getAOO(reef_2000_raster, grid.size = 1000, min.percent.rule = TRUE, percent = 1)),
  "getAOO (RasterLayer)"
)

# makeAOOGrid (may require RasterLayer dispatch)
reef_aoo_grid <- safe_run(quote(makeAOOGrid(reef_2000_raster, grid.size = 1000, min.percent.rule = TRUE, percent = 1)), "makeAOOGrid (RasterLayer)")

# EOO
reef_eoo_poly <- safe_run(quote(makeEOO(reef_2000_raster)), "makeEOO")
if (!is.null(reef_eoo_poly)) {
  reef_eoo_area <- safe_run(quote(getAreaEOO(reef_eoo_poly)), "getAreaEOO")
} else {
  reef_eoo_area <- NA
}

# Area at time points
reef_area_2000 <- safe_run(quote(getArea(reef_2000_raster)), "getArea 2000")
reef_area_2020 <- safe_run(quote(getArea(reef_2020_raster)), "getArea 2020")

# Area change / loss
# redlistr exports `getAreaLoss` which computes total area lost between rasters
reef_area_change <- safe_run(quote(getAreaLoss(reef_2000_raster, reef_2020_raster)), "getAreaLoss")

# Decline stats (use numeric values)
a_t1 <- as.numeric(reef_area_2000)
a_t2 <- as.numeric(reef_area_2020)
if (!is.na(a_t1) && !is.na(a_t2)) {
  reef_decline <- safe_run(quote(getDeclineStats(A.t1 = a_t1, A.t2 = a_t2, year.t1 = 2000, year.t2 = 2020, methods = c("ARD", "PRD", "ARC"))), "getDeclineStats")
} else {
  message("Skipping decline stats — area values missing.")
}

# Grid uncertainty – use available functions `gridUncertainty` or
# `gridUncertaintyRandom` (the former returns uncertainty metrics,
# the latter performs basic Monte Carlo).
reef_uncertainty <- safe_run(quote(gridUncertainty(input.data = reef_2000_raster, grid.size = 1000, n.AOO.improvement = 10)), "gridUncertainty")

# Small plot of area trend
reef_trend <- data.frame(year = c(2000, 2020), area_km2 = c(as.numeric(reef_area_2000), as.numeric(reef_area_2020)))
try(
  print(ggplot(reef_trend, aes(x = year, y = area_km2)) + geom_line() + geom_point() + theme_minimal()),
  silent = TRUE
)

message("Script completed. Outputs written to:", reef_sample_path)
message("If you want a real reef GeoTIFF, replace data/reef_sample.tif and re-run the script.")
