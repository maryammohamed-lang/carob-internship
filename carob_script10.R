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
  
  r$year <- trimws(as.character(r$year))
  r$clone <- trimws(as.character(r$clone))
  r$locality <- trimws(as.character(r$locality))
  r$population <- trimws(as.character(r$population))
  
  # SG = Specific Gravity
  r$sg <- suppressWarnings(as.numeric(r$sg))
  
  # FF and CH remain character because the source contains
  # values such as 1*, 1**, 1*** and 1.5*.
  r$ff <- trimws(as.character(r$ff))
  r$ch <- trimws(as.character(r$ch))
  
  # Remove only exact duplicate rows.
  r <- dplyr::distinct(r)
  
  # ------------------------------------------------------------
  # Create standardized Carob data
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
    
    longitude = NA_real_,
    latitude = NA_real_,
    
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
  # Keep the original source measurements
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
    
    data_type = "experiment",
    
    treatment_vars = "variety",
    
    response_vars = "sg",
    
    notes = paste(
      "Potato processing-quality dataset.",
      "SG is specific gravity.",
      "FF is the French fries quality/color score.",
      "CH is the chip color score.",
      "SG, FF, and CH are retained from the source dataset.",
      "FF and CH are kept as character variables because",
      "the source contains values with asterisks.",
      "The source dataset does not contain yield.",
      "Missing source measurements are retained as NA.",
      "No measurements are averaged or otherwise modified."
    ),
    
    carob_contributor = "Maryam",
    carob_effort = 1,
    carob_completion = 80,
    carob_date = "2026-08-13"
  )

  
  # ------------------------------------------------------------
  # Write standardized files
  # ------------------------------------------------------------
  
  carobiner::write_files(
    path = path,
    metadata = meta,
    wide = d
  )
  
  # ------------------------------------------------------------
  # Return data
  # ------------------------------------------------------------
  
  return(d)
}

