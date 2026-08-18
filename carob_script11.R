library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/RKTBNX"
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
  ## Identify source files
  ## =========================================================
  
  f1 <- ff[basename(ff) ==
             "01_Potato Baked Processing Results Huancayo 2019-2020.xlsx"]
  
  f2 <- ff[basename(ff) ==
             "01_Potato Baked Processing Results Majes 2019-2020.xlsx"]
  
  f3 <- ff[basename(ff) ==
             "03_Potato Baked Processing Results Huamachuco Licame 2019-2020.xlsx"]
  
  f4 <- ff[basename(ff) ==
             "04_Potato Baked Processing Results  Cajamarca 2019-2020.xlsx"]
  
  f5 <- ff[basename(ff) ==
             "05_Potato Baked Processing Results Huanuco 2019-2020.xlsx"]
  
  files <- c(f1, f2, f3, f4, f5)
  
  if (length(files) != 5 || any(is.na(files))) {
    stop("One or more expected Excel files were not found.")
  }
  
  ## =========================================================
  ## Read all source files
  ## =========================================================
  
  r1 <- carobiner::read.excel(f1)
  r2 <- carobiner::read.excel(f2)
  r3 <- carobiner::read.excel(f3)
  r4 <- carobiner::read.excel(f4)
  r5 <- carobiner::read.excel(f5)
  
  ## =========================================================
  ## Add source location
  ## =========================================================
  
  r1$Site <- "Huancayo"
  r2$Site <- "Majes"
  r3$Site <- "Huamachuco_Licame"
  r4$Site <- "Cajamarca"
  r5$Site <- "Huanuco"
  
  ## =========================================================
  ## Combine source data
  ## =========================================================
  
  dat_list <- list(
    r1,
    r2,
    r3,
    r4,
    r5
  )
  
  r <- do.call(rbind, dat_list)
  
  ## =========================================================
  ## Standardize source data types
  ## =========================================================
  
  r$Plot <- as.character(r$Plot)
  r$Clone <- as.character(r$Clone)
  
  r$Repetition <- as.integer(r$Repetition)
  r$Evaluator <- as.integer(r$Evaluator)
  
  r$Flavor <- r$Flavor
  r$Texture <- r$Texture
  
  r$Site <- as.character(r$Site)
  
  ## =========================================================
  ## CAROB standardized variables
  ## =========================================================
  
  d <- data.frame(
    
    trial_id = paste(
      "RKTBNX",
      r$Site,
      sep = "_"
    ),
    
    plot_id = r$Plot,
    
    crop = "potato",
    
    variety = r$Clone,
    
    rep = r$Repetition,
    
    country = "Peru",
    
    location = r$Site,
    
    ## Important source variables.
    ## Retained even though they are not currently
    ## in the standard CAROB vocabulary.
    flavor = r$Flavor,
    
    texture = r$Texture,
    
    evaluator = r$Evaluator,
    
    ## No yield measurement is present in the source.
    yield = NA_real_,
    
    yield_moisture = NA_real_,
    
    yield_part = NA_character_,
    
    yield_isfresh = NA,
    
    ## Coordinates are not present in the source files.
    latitude = NA_real_,
    
    longitude = NA_real_,
    
    irrigated = NA,
    
    N_fertilizer = NA_real_,
    
    P_fertilizer = NA_real_,
    
    K_fertilizer = NA_real_,
    
    planting_date = NA_character_,
    
    harvest_date = NA_character_,
    
    is_survey = FALSE,
    
    on_farm = FALSE,
    
    geo_from_source = FALSE,
    
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
    
    minor = 1,
    
    data_organization = "CIP",
    
    publication = NA,
    
    project = NA,
    
    design = NA,
    
    data_type = "experiment",
    
    treatment_vars = "variety",
    
    response_vars = "flavor;texture",
    
    notes = paste(
      "Sensory evaluation of baked potato.",
      "Source variables Flavor, Texture, and Evaluator",
      "are retained because they are important variables",
      "in the original dataset."
    ),
    
    carob_contributor = "Maryam",
    
    carob_date = "2026-08-18",
    
    carob_completion = 100,
    
    carob_effort = 1
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