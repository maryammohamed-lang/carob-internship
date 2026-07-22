library(carobiner)

carob_script <- function(path){
  
  uri <- "doi:10.21223/FBZ6JS"
  group <- "agronomy"
  
  ff <- carobiner::get_data(uri, path, group)
  
  files <- c(
    "PTYL200910_BARAKA.xls",
    "PTYL200910_KIBRCH.xls",
    "PTYL200910_KISIMA.xls",
    "PTYL200910_LIMURU.xls",
    "PTYL200910_NAROK.xls"
  )
  
  d <- data.frame()
  
  for(f in files){
    
    r <- carobiner::read.excel(
      ff[basename(ff) == f],
      sheet = "Fieldbook"
    )
    
    minimal <- carobiner::read.excel(
      ff[basename(ff) == f],
      sheet = "Minimal"
    )
    
    country <- minimal$Value[minimal$Factor == "Country"]
    
    location <- tolower(
      minimal$Value[minimal$Factor == "Site short name"]
    )
    
    latitude <- as.numeric(
      minimal$Value[minimal$Factor == "Latitude"]
    )
    
    longitude <- as.numeric(
      minimal$Value[minimal$Factor == "Longitude"]
    )
    
    elevation <- as.numeric(
      minimal$Value[minimal$Factor == "Elevation"]
    )
    
    
    tmp <- data.frame(
      trial_id = "PTYL200910",
      crop = "potato",
      variety = as.character(r$INSTN),
      rep = as.integer(r$REP),
      
      # MTWP is kg/plot, convert to kg/ha
      yield = as.numeric(r$MTWP) / 10.8 * 10000,
      yield_part = "tubers",
      
      country = country,
      location = location,
      
      planting_date = "2009-10-25",
      harvest_date = "2010-02-16",
      
      is_survey = FALSE,
      on_farm = FALSE,
      irrigated = NA,
      
      yield_moisture = NA,
      yield_isfresh = TRUE,
      
      latitude = latitude,
      longitude = longitude,
      elevation = elevation,
      geo_from_source = TRUE,
      
      N_fertilizer = NA,
      P_fertilizer = NA,
      K_fertilizer = NA,
      
      stringsAsFactors = FALSE
    )
    
    d <- rbind(d, tmp)
  }
  
  
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    major = 2,
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
    carob_date = "2026-07-21"
  )
  
  # Fix metadata warnings
  meta$crops <- NULL
  meta$countries <- NULL
  meta$version <- as.character(meta$version)
  
  carobiner::write_files(path, meta, d)
  
  return(d)
}