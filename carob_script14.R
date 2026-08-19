library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/FF5CZT"
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
             "01_Potato French Fries Processing Results Quilcas 2019-2020.xlsx"]
  
  f2 <- ff[basename(ff) ==
             "02_Potato French Fries Processing Results Majes 2019-2020.xlsx"]
  
  f3 <- ff[basename(ff) ==
             "03_Potato French Fries Processing Results Huanuco 2019-2020.xlsx"]
  
  f4 <- ff[basename(ff) ==
             "04_Potato French Fries Processing Results Huamachuco 2019-2020.xlsx"]
  
  f5 <- ff[basename(ff) ==
             "05_Potato French Fries Processing Results Chota 2019-2020.xlsx"]
  
  files <- c(f1, f2, f3, f4, f5)
  if (length(files) != 5 || any(is.na(files))) {
    stop("One or more expected Excel files were not found.")
  }
  r1 <- carobiner::read.excel(f1)
  r2 <- carobiner::read.excel(f2)
  r3 <- carobiner::read.excel(f3)
  r4 <- carobiner::read.excel(f4)
  r5 <- carobiner::read.excel(f5)
  
  r <- do.call(rbind, list(r1, r2, r3, r4, r5))
  
  ## Check combined data
  dim(r)
  table(r$Locality)
  table(r$Repetition)
  
  ## =========================================================
  ## Standardize source data types
  ## =========================================================
  
  r$`#` <- as.character(r$`#`)
  r$Clone <- as.character(r$Clone)
  r$Locality <- as.character(r$Locality)
  r$Repetition <- as.integer(r$Repetition)
  
  r$`Color sample1` <- as.numeric(r$`Color sample1`)
  r$`Texture sample1` <- as.numeric(r$`Texture sample1`)
  
  r$`Color sample2` <- as.numeric(
    ifelse(r$`Color sample2` == "-", NA, r$`Color sample2`)
  )
  
  r$`Texture sample2` <- as.numeric(
    ifelse(r$`Texture sample2` == "-", NA, r$`Texture sample2`)
  )
  
  r$`Observation sample1` <- as.character(r$`Observation sample1`)
  r$`Observation sample2` <- as.character(r$`Observation sample2`)
  ## =========================================================
  ## Create CAROB standardized data
  ## =========================================================
  
  d <- data.frame(
    trial_id = paste("FF5CZT", r$Locality, sep = "_"),
    plot_id = r$`#`,
    crop = "potato",
    variety = r$Clone,
    rep = r$Repetition,
    country = "Peru",
    location = r$Locality,
    
    color_sample1 = r$`Color sample1`,
    texture_sample1 = r$`Texture sample1`,
    color_sample2 = as.numeric(r$`Color sample2`),
    texture_sample2 = as.numeric(r$`Texture sample2`),
    
    observation_sample1 = r$`Observation sample1`,
    observation_sample2 = r$`Observation sample2`,
    
    yield = NA_real_,
    yield_moisture = NA_real_,
    yield_part = NA_character_,
    yield_isfresh = NA,
    
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
    minor = 3,
    
    data_organization = "CIP",
    
    publication = NA,
    project = NA,
    design = NA,
    
    data_type = "experiment",
    
    treatment_vars = "variety",
    
    response_vars = paste(
      "color_sample1",
      "texture_sample1",
      "color_sample2",
      "texture_sample2",
      sep = ";"
    ),
    
    notes = paste(
      "Assessment of French fries quality traits",
      "during 2019-2020 at five locations in Peru.",
      "The dataset contains color and texture measurements",
      "for two samples, together with qualitative observations."
    ),
    
    carob_contributor = "Maryam",
    carob_date = "2026-08-19",
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
