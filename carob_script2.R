library(carobiner)

carob_script <- function(path){
  
  uri <- "doi:10.21223/BW8LWJ"
  group <- "agronomy"
  
  ff <- carobiner::get_data(uri, path, group)
  
  d1 <- carobiner::read.excel(
    ff[basename(ff) == "01_Experiments without control LB.xlsx"]
  )
  
  d2 <- carobiner::read.excel(
    ff[basename(ff) == "02_Experiments with LB control.xlsx"]
  )
  
  d3 <- carobiner::read.excel(
    ff[basename(ff) == "03_Experiments Phenotypic Stabilit.xlsx"]
  )
  
  ## Identify experiment
  d1$experiment <- "without_LB_control"
  d2$experiment <- "with_LB_control"
  d3$experiment <- "phenotypic_stability"
  
  ## Combine datasets
  r <- rbind(d1, d2, d3)
  
  ## Fix decimal separator
  r$UMTY_Plot <- as.numeric(gsub(",", ".", r$UMTY_Plot))
  
  ## Rename columns
  names(r) <- c(
    "obs",
    "rep",
    "clone",
    "AUDPC",
    "sAUDPC",
    "MTY_plot",
    "UMTY_plot",
    "TTY_plot",
    "MTY_ha",
    "TTY_ha",
    "site",
    "experiment"
  )
  
  ## Standardize data
  d <- data.frame(
    
    trial_id = paste0(
      "BW8LWJ_",
      gsub("[ ,]+", "_", r$site),
      "_",
      r$experiment
    ),
    
    plot_id = as.character(r$obs),
    
    crop = "potato",
    
    variety = as.character(r$clone),
    
    rep = as.integer(r$rep),
    
    yield = as.numeric(r$TTY_ha) * 1000,
    
    yield_marketable = as.numeric(r$MTY_ha) * 1000,
    
    yield_part = "tubers",
    
    AUDPC = as.numeric(r$AUDPC),
    
    rAUDPC = as.numeric(r$sAUDPC),
    
    country = "Peru",
    
    location = as.character(r$site),
    
    is_survey = FALSE,
    
    on_farm = FALSE,
    
    irrigated = NA,
    
    planting_date = NA,
    
    harvest_date = NA,
    
    latitude = NA,
    
    longitude = NA,
    
    geo_from_source = FALSE,
    
    N_fertilizer = NA,
    
    P_fertilizer = NA,
    
    K_fertilizer = NA,
    
    yield_isfresh = TRUE,
    
    yield_moisture = NA,
    
    stringsAsFactors = FALSE
  )
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    major = 1,
    minor = 0,
    data_organization = "CIP",
    publication = NA,
    project = NA,
    data_type = "experiment",
    response_vars = "yield",
    treatment_vars = "variety",
    carob_contributor = "Maryam",
    carob_effort = 1,
    carob_completion = 100,
    carob_date = "2026-07-29"
  )
  
  meta$crops <- NULL
  meta$countries <- NULL
  meta$version <- as.character(meta$version)
  
  carobiner::write_files(path, meta, d)
  
  return(d)
  
}