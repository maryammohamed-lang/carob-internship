library(carobiner)
library(dplyr)

carob_script <- function(path) {
  
  # ------------------------------------------------------------
  # Source information
  # ------------------------------------------------------------
  
  uri <- "doi:10.21223/WQMMSN"
  group <- "agronomy"
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  data_file <- ff[basename(ff) == "01_Data.xlsx"]
  
  if (length(data_file) != 1) {
    stop("Could not find exactly one file named '01_Data.xlsx'")
  }
  
  # ------------------------------------------------------------
  # Read source data
  # ------------------------------------------------------------
  
  r <- carobiner::read.excel(data_file)
  
  if (ncol(r) != 7) {
    stop(
      "Expected 7 columns in 01_Data.xlsx, found ",
      ncol(r)
    )
  }
  
  names(r) <- c(
    "year",
    "clone",
    "locality",
    "population",
    "sg",
    "ff",
    "ch"
  )
  
  # ------------------------------------------------------------
  # Clean source variables
  # ------------------------------------------------------------
  
  r$year <- as.character(r$year)
  r$clone <- trimws(as.character(r$clone))
  r$locality <- trimws(as.character(r$locality))
  r$population <- trimws(as.character(r$population))
  
  # Specific gravity
  r$sg <- as.numeric(r$sg)
  
  # Keep FF and CH as character because the source contains
  # values such as 1*, 1**, 1*** and 1.5*.
  r$ff <- as.character(r$ff)
  r$ch <- as.character(r$ch)
  
  # Remove exact duplicate rows only.
  # No measurements are averaged or otherwise changed.
  r <- dplyr::distinct(r)
  
  # ------------------------------------------------------------
  # Standardized Carob data
  # ------------------------------------------------------------
  
  d <- data.frame(
    
    trial_id = paste(
      "WQMMSN",
      r$year,
      r$locality,
      r$population,
      sep = "_"
    ),
    
    plot_id = NA_character_,
    
    crop = "potato",
    
    variety = r$clone,
    
    rep = NA_integer_,
    
    country = "Peru",
    
    location = tolower(r$locality),    
    latitude = NA_real_,
    longitude = NA_real_,
    
    geo_from_source = FALSE,
    
    is_survey = FALSE,
    
    on_farm = NA,
    irrigated = NA,
    
    planting_date = NA_character_,
    harvest_date = NA_character_,
    
    N_fertilizer = NA_real_,
    P_fertilizer = NA_real_,
    K_fertilizer = NA_real_,
    
    stringsAsFactors = FALSE
  )
  
  # ------------------------------------------------------------
  # Preserve ALL source measurements
  # ------------------------------------------------------------
  
  d$sg <- r$sg
  d$ff <- r$ff
  d$ch <- r$ch
  
  # ------------------------------------------------------------
  # Metadata
  # ------------------------------------------------------------
  
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    
    major = 1,
    minor = 1,
    
    data_organization = "CIP",
    
    publication = NA,
    project = NA,
    
    # Do not use "other": it is invalid in your carobiner version.
    # We also do not claim that SG/FF/CH are yield.
    data_type = "experiment",
    treatment_vars = "variety",
    
    response_vars = "none",
    
    notes = paste(
      "The source dataset contains SG (Specific gravity),",
      "FF (French fries quality/color score), and",
      "CH (Chip color score). These source variables are",
      "retained with their original names because they are",
      "the main measurements reported in the source dataset.",
      "The source dataset does not contain yield."
    ),
    
    carob_contributor = "Maryam",
    carob_effort = 1,
    carob_completion = 80,
    carob_date = "2026-08-13"
  )
  
  # ------------------------------------------------------------
  # Write Carob files
  # ------------------------------------------------------------
  
  carobiner::write_files(
    path = path,
    metadata = meta,
    wide = d
  )
  
  # ------------------------------------------------------------
  # Return final data
  # ------------------------------------------------------------
  
  return(d)
}