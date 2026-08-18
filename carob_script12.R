library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/F6ZZJH"
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
             "01_Potato Baked Processing Results Majes 2020-2021.xlsx"]
  
  f2 <- ff[basename(ff) ==
             "02_Potato Baked Processing Results Huancayo 2020-2021.xlsx"]
  
  f3 <- ff[basename(ff) ==
             "03_Potato Baked Processing Results Huamachuco-Licame 2020-2021.xlsx"]
  
  f4 <- ff[basename(ff) ==
             "04_Potato Baked Processing Results Huamachuco-Yanac 2020-2021.xlsx"]
  
  f5 <- ff[basename(ff) ==
             "05_Potato Baked Processing Results Cajamarca 2020-2021.xlsx"]
  
  f6 <- ff[basename(ff) ==
             "06_Potato Baked Processing Results Huanuco 2020-2021.xlsx"]
  
  files <- c(f1, f2, f3, f4, f5, f6)
  
  if (length(files) != 6 || any(is.na(files))) {
    stop("One or more expected Excel files were not found.")
  }
  
  ## =========================================================
  ## Read source data
  ## =========================================================
  
  r1 <- carobiner::read.excel(f1)
  r2 <- carobiner::read.excel(f2)
  r3 <- carobiner::read.excel(f3)
  r4 <- carobiner::read.excel(f4)
  r5 <- carobiner::read.excel(f5)
  r6 <- carobiner::read.excel(f6)
  
  ## =========================================================
  ## Add source location
  ## =========================================================
  
  r1$Site <- "Majes"
  r2$Site <- "Huancayo"
  r3$Site <- "Huamachuco_Licame"
  r4$Site <- "Huamachuco_Yanac"
  r5$Site <- "Cajamarca"
  r6$Site <- "Huanuco"
  
  ## =========================================================
  ## Combine source data
  ## =========================================================
  
  r <- do.call(
    rbind,
    list(r1, r2, r3, r4, r5, r6)
  )
  
  ## =========================================================
  ## Standardize source data types
  ## =========================================================
  
  r$Plot <- as.character(r$Plot)
  r$Clone <- as.character(r$Clone)
  r$Repetition <- as.integer(r$Repetition)
  r$Evaluator <- as.integer(r$Evaluator)
  r$Flavor <- as.numeric(r$Flavor)
  r$Texture <- as.numeric(r$Texture)
  r$Site <- as.character(r$Site)
  
  ## =========================================================
  ## Create CAROB standardized data
  ## =========================================================
  
  d <- data.frame(
    
    ## Identification
    trial_id = paste(
      "F6ZZJH",
      r$Site,
      sep = "_"
    ),
    
    plot_id = r$Plot,
    
    ## Crop
    crop = "potato",
    
    variety = r$Clone,
    
    ## Experimental design
    rep = r$Repetition,
    
    ## Location
    country = "Peru",
    location = r$Site,
    
    ## Source response variables
    flavor = r$Flavor,
    texture = r$Texture,
    evaluator = r$Evaluator,
    
    ## Yield: not measured in this dataset
    yield = NA_real_,
    yield_moisture = NA_real_,
    yield_part = NA_character_,
    yield_isfresh = NA,
    
    ## Geographic information not available
    latitude = NA_real_,
    longitude = NA_real_,
    geo_from_source = FALSE,
    
    ## Management information not available
    irrigated = NA,
    N_fertilizer = NA_real_,
    P_fertilizer = NA_real_,
    K_fertilizer = NA_real_,
    planting_date = NA_character_,
    harvest_date = NA_character_,
    
    ## Trial characteristics
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
    minor = 1,
    data_organization = "CIP",
    publication = NA,
    project = NA,
    data_type = "experiment",
    treatment_vars = "variety",
    response_vars = "flavor;texture",
    carob_contributor = "Maryam",
    carob_effort = 1,
    carob_completion = 100,
    carob_date = "2026-08-18"
  )
  
  ## =========================================================
  ## Write CAROB files
  ## =========================================================
  
  carobiner::write_files(
    path ,
    meta ,
     d 
  )
  
  return(d)
}