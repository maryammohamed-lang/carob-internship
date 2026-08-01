library(carobiner)
library(readxl)
library(dplyr)

carob_script <- function(path){
  
  uri <- "doi:10.21223/P3/RWIMFO"
  group <- "agronomy"
  
  ff <- carobiner::get_data(uri, path, group)
  
  # Read Yanamayo
  hm1 <- read_excel(
    ff[basename(ff) == "PTPV200909_YANAM.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  hb1 <- read_excel(
    ff[basename(ff) == "PTPV200909_YANAM.xls"],
    sheet = "F5_harvest_Baby"
  )
  
  sh1 <- read_excel(
    ff[basename(ff) == "PTPV200909_YANAM.xls"],
    sheet = "Summary By Clone M&B"
  )
  
  # Read Patacancha
  hm2 <- read_excel(
    ff[basename(ff) == "PTPV200911_PATACR.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  hb2 <- read_excel(
    ff[basename(ff) == "PTPV200911_PATACR.xls"],
    sheet = "F5_harvest_Baby"
  )
  
  sh2 <- read_excel(
    ff[basename(ff) == "PTPV200911_PATACR.xls"],
    sheet = "Summary By Clone M&B"
  )
  
  # Read data dictionary
  dict <- read_excel(
    ff[basename(ff) == "02_Data_dictionary.xlsx"]
  )
  
  # Clean datasets
  hm1 <- hm1 %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Yanamayo",
      Population = "Mother"
    )
  
  hm2 <- hm2 %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Patacancha",
      Population = "Mother"
    )
  
  hb1 <- hb1 %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Yanamayo",
      Population = "Baby"
    )
  
  hb2 <- hb2 %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Patacancha",
      Population = "Baby"
    )
  
  # Combine datasets
  dat <- bind_rows(hm1, hm2, hb1, hb2)
  
  
  
  # Fill missing Code values
  dat <- dat %>%
    mutate(
      Code = ifelse(is.na(Code) & INSTN == "Huayro", "Huayro", Code)
    )
  
  # Create CAROB dataset
  d <- dat %>%
    mutate(
      
      trial_id = paste0(
        "RWIMFO_",
        Site,
        "_",
        Population
      ),
      
      plot_id = as.character(PLOT),
      
      crop = "potato",
      
      variety = INSTN,
      
      rep = as.integer(REP),
      
      yield = TTYNA * 1000,
      
      yield_marketable = MTYNA * 1000,
      
      yield_part = "tubers",
      
      country = "Peru",
      
      location = Site,
      
      planting_date = ifelse(
        Site == "Yanamayo",
        "2009-09-19",
        "2009-11-10"
      ),
      
      harvest_date = ifelse(
        Site == "Yanamayo",
        "2010-05-13",
        "2010-05-12"
      ),
      
      latitude = ifelse(
        Site == "Yanamayo",
        -13.25588,
        -13.14994
      ),
      
      longitude = ifelse(
        Site == "Yanamayo",
        -72.26289,
        -72.18757
      ),
      
      elevation = ifelse(
        Site == "Yanamayo",
        2906,
        4121
      ),
      
      is_survey = FALSE,
      
      on_farm = TRUE,
      
      irrigated = NA,
      
      geo_from_source = TRUE,
      
      yield_isfresh = TRUE,
      
      yield_moisture = NA,
      
      N_fertilizer = NA,
      
      P_fertilizer = NA,
      
      K_fertilizer = NA
      
    ) %>%
    select(
      trial_id,
      plot_id,
      crop,
      variety,
      rep,
      yield,
      yield_part,
      yield_marketable,
      country,
      location,
      latitude,
      longitude,
      elevation,
      geo_from_source,
      planting_date,
      harvest_date,
      on_farm,
      is_survey,
      N_fertilizer,
      P_fertilizer,
      K_fertilizer,
      irrigated,
      yield_isfresh,
      yield_moisture
    )
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    major = 4,
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
    carob_date = as.character(Sys.Date())
  )
  
  meta$crops <- NULL
  meta$countries <- NULL
  meta$version <- as.character(meta$version)
  
  carobiner::write_files(path, meta, d)
  
  return(d)
}

