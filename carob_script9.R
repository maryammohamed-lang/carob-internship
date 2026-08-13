library(carobiner)
library(dplyr)

carob_script <- function(path) {
  
  # ============================================================
  # 1. Source information
  # ============================================================
  
  uri <- "doi:10.21223/MXKUIK"
  group <- "agronomy"
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  data_file <- ff[
    basename(ff) ==
      "01_Data_Adaptation_and_Efficiency_Trials.xlsx"
  ]
  
  if (length(data_file) != 1) {
    stop("Could not find the expected data Excel file.")
  }
  
  
  # ============================================================
  # 2. Read source Excel
  # ============================================================
  
  r <- carobiner::read.excel(data_file)
  
  names(r) <- c(
    "plot",
    "clone",
    "rep",
    "year",
    "locality",
    "nph",
    "mtwp",
    "nomtwp",
    "ttwp",
    "mtyna",
    "ttyna",
    "mtya",
    "ttya",
    "dm_hydrometer",
    "dm_oven",
    "reducing_sugars",
    "ffr_at_harvest",
    "ffr_blanching",
    "ffr_90_days",
    "flavbp1",
    "flavbp2",
    "flavbp3",
    "texbp1",
    "texbp2",
    "texbp3"
  )
  
  
  # ============================================================
  # 3. Convert types
  # ============================================================
  
  r$plot <- as.character(r$plot)
  r$clone <- as.character(r$clone)
  r$rep <- as.integer(r$rep)
  r$year <- as.character(r$year)
  r$locality <- as.character(r$locality)
  
  numeric_vars <- c(
    "nph",
    "mtwp",
    "nomtwp",
    "ttwp",
    "mtyna",
    "ttyna",
    "mtya",
    "ttya",
    "dm_hydrometer",
    "dm_oven",
    "reducing_sugars",
    "ffr_at_harvest",
    "ffr_blanching",
    "ffr_90_days",
    "flavbp1",
    "flavbp2",
    "flavbp3",
    "texbp1",
    "texbp2",
    "texbp3"
  )
  
  r[numeric_vars] <- lapply(
    r[numeric_vars],
    as.numeric
  )
  
  
  # ============================================================
  # 4. Carob-standardized data
  # ============================================================
  
  d <- data.frame(
    
    # Identification
    trial_id = paste0(
      "MXKUIK_",
      gsub("[ ,]+", "_", r$locality),
      "_",
      gsub("[ ,]+", "_", r$year)
    ),
    
    plot_id = r$plot,
    
    crop = "potato",
    
    variety = r$clone,
    
    rep = r$rep,
    
    
    # ----------------------------------------------------------
    # Yield
    #
    # Source values are tonnes/ha.
    # Carob yield is kg/ha.
    #
    # TTYA = Total tuber yield adjusted
    # MTYA = Marketable tuber yield adjusted
    # ----------------------------------------------------------
    
    yield = r$ttya * 1000,
    
    yield_marketable = r$mtya * 1000,
    
    yield_part = "tubers",
    
    yield_isfresh = TRUE,
    
    yield_moisture = NA,
    
    
    # Location
    country = "Peru",
    
    location = r$locality,
    
    latitude = NA,
    
    longitude = NA,
    
    geo_from_source = FALSE,
    
    
    # Trial information
    is_survey = FALSE,
    
    on_farm = TRUE,
    
    irrigated = NA,
    
    planting_date = NA,
    
    harvest_date = NA,
    
    
    # Fertilizer information not reported
    N_fertilizer = NA,
    
    P_fertilizer = NA,
    
    K_fertilizer = NA,
    
    stringsAsFactors = FALSE
  )
  
  
  # ============================================================
  # 5. Metadata
  # ============================================================
  
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    
    major = 1,
    minor = 1,
    
    data_organization = "CIP",
    
    publication = NA,
    
    project = NA,
    
    data_type = "experiment",
    
    response_vars = "yield",
    
    treatment_vars = "variety",
    
    carob_contributor = "Maryam",
    
    carob_effort = 1,
    
    carob_completion = 100,
    
    carob_date = "2026-08-13"
  )
  
  
  # ============================================================
  # 6. Clean metadata
  # ============================================================
  
  meta$crops <- NULL
  meta$countries <- NULL
  meta$version <- as.character(meta$version)
  
  
  # ============================================================
  # 7. Write files
  # ============================================================
  
  carobiner::write_files(
    path,
    meta,
    d
  )
  
  return(d)
}