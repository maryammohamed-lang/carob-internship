library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/ZTPO9T"
  group <- "agronomy"
  
  ## =========================================================
  ## Get data
  ## =========================================================
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  ## =========================================================
  ## Identify source file
  ## =========================================================
  
  f <- ff[
    basename(ff) ==
      "01_Potato French Fries Processing Results 2020-2021.xlsx"
  ]
  
  if (length(f) != 1 || is.na(f)) {
    stop("Expected Excel file was not found.")
  }
  
  ## =========================================================
  ## Read source data
  ## =========================================================
  
  r <- carobiner::read.excel(f)
  
  ## =========================================================
  ## Standardize source data types
  ## =========================================================
  
  r$Numeration <- as.character(r$Numeration)
  r$Clone <- as.character(r$Clone)
  r$Locality <- as.character(r$Locality)
  r$Repetition <- as.integer(r$Repetition)
  
  r$`Color sample1` <- as.numeric(r$`Color sample1`)
  r$`Color sample2` <- as.numeric(r$`Color sample2`)
  r$`Texture sample1` <- as.numeric(r$`Texture sample1`)
  r$`Texture sample2` <- as.numeric(r$`Texture sample2`)
  
  ## =========================================================
  ## Create CAROB standardized data
  ## =========================================================
  
  d <- data.frame(
    
    ## Identification
    trial_id = paste(
      "ZTPO9T",
      r$Locality,
      sep = "_"
    ),
    
    plot_id = r$Numeration,
    
    ## Crop
    crop = "potato",
    variety = r$Clone,
    
    ## Experimental design
    rep = r$Repetition,
    
    ## Location
    country = "Peru",
    location = r$Locality,
    
    ## Flesh color
    flesh_color = NA_character_,
    
    ## Variables not reported in source
    yield = NA_real_,
    yield_moisture = NA_real_,
    yield_part = NA_character_,
    yield_isfresh = NA,
    
    latitude = NA_real_,
    longitude = NA_real_,
    geo_from_source = FALSE,
    
    irrigated = NA,
    
    N_fertilizer = NA_real_,
    P_fertilizer = NA_real_,
    K_fertilizer = NA_real_,
    
    planting_date = NA_character_,
    harvest_date = NA_character_,
    
    is_survey = FALSE,
    on_farm = FALSE,
    
    stringsAsFactors = FALSE
  )
  ## =========================================================
  ## Metadata
  ## =========================================================
  
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    major = 1,
    minor = 2,
    data_organization = "CIP",
    publication = NA,
    project = NA,
    data_type = "experiment",
    treatment_vars = "variety",
    response_vars = "flesh_color",
    carob_contributor = "Maryam",
    carob_effort = 1,
    carob_completion = 100,
    carob_date = "2026-08-18"
  )
  
  ## =========================================================
  ## Write CAROB files
  ## =========================================================
  
  carobiner::write_files(
    path,
    meta,
    d
  )
  
  return(d)
}