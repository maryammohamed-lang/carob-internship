library(carobiner)
library(readxl)
library(dplyr)

carob_script <- function(path){
  
  uri <- "doi:10.21223/P3/RVCHKV"
  group <- "varieties_potato"
  
  # Get data
  ff <- carobiner::get_data(uri, path, group)
  
  # -----------------------------
  # Read the three experiments
  # -----------------------------
  
  sjuan <- read_excel(
    ff[basename(ff) == "PTPV201210_SJUAN_Exp1.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  lsole <- read_excel(
    ff[basename(ff) == "PTPV201211_LSOLE.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  macull <- read_excel(
    ff[basename(ff) == "PTPV201211_MACULL_Exp1.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  # -----------------------------
  # Add site information
  # -----------------------------
  
  sjuan <- sjuan %>%
    mutate(
      Site = "San Juan Bajo"
    )
  
  lsole <- lsole %>%
    mutate(
      Site = "La Soledad"
    )
  
  macull <- macull %>%
    mutate(
      Site = "Macullida"
    )
  
  # -----------------------------
  # Combine datasets
  # -----------------------------
  
  dat <- bind_rows(
    sjuan,
    lsole,
    macull
  )
  
  # -----------------------------
  # Remove rows without yield
  # -----------------------------
  
  dat <- dat %>%
    filter(
      !(is.na(TTYNA) &
          is.na(TTYA))
    )
  
  # -----------------------------
  # Create CAROB variables
  # -----------------------------
  
  d <- dat %>%
    mutate(
      trial_id = paste0(
        "RVCHKV_",
        gsub("[ ,]+", "_", Site)
      ),
      
      plot_id = as.character(PLOT),
      
      crop = "potato",
      
      variety = as.character(INSTN),
      
      rep = as.integer(REP),
      
      # CAROB yield: t/ha -> kg/ha
      yield = ifelse(
        is.na(TTYNA),
        as.numeric(TTYA) * 1000,
        as.numeric(TTYNA) * 1000
      ),
      
      # Marketable yield: t/ha -> kg/ha
      yield_marketable = ifelse(
        is.na(MTYNA),
        as.numeric(MTYA) * 1000,
        as.numeric(MTYNA) * 1000
      ),
      
      yield_part = "tubers",
      
      country = "Peru",
      location = Site,
      
      on_farm = TRUE,
      is_survey = FALSE,
      
      irrigated = NA,
      
      planting_date = as.Date(NA),
      harvest_date = as.Date(NA),
      
      latitude = NA_real_,
      longitude = NA_real_,
      elevation = NA_real_,
      geo_from_source = FALSE,
      
      N_fertilizer = NA_real_,
      P_fertilizer = NA_real_,
      K_fertilizer = NA_real_,
      
      yield_isfresh = TRUE,
      yield_moisture = NA_real_,
      
      # Original agronomic variables
      NTP = as.numeric(NTP),
      NNoMTP = as.numeric(NNoMTP),
      TNTP = as.numeric(TNTP),
      NoMTWP = as.numeric(NoMTWP),
      TTWP = as.numeric(TTWP),
      TTYNA = as.numeric(TTYNA),
      MTWP = as.numeric(MTWP),
      MTYNA = as.numeric(MTYNA),
      ATW = as.numeric(ATW)
    )
  # -----------------------------
  # Keep CAROB variables
  # -----------------------------
  d <- d %>%
    select(
      trial_id,
      plot_id,
      crop,
      variety,
      rep,
      yield,
      yield_marketable,
      yield_part,
      country,
      location,
      on_farm,
      is_survey,
      irrigated,
      planting_date,
      harvest_date,
      latitude,
      longitude,
      elevation,
      geo_from_source,
      N_fertilizer,
      P_fertilizer,
      K_fertilizer,
      yield_isfresh,
      yield_moisture
    )
  
  d$trial_id <- as.character(d$trial_id)
  d$plot_id <- as.character(d$plot_id)
  d$variety <- as.character(d$variety)
  # -----------------------------
  # Metadata
  # -----------------------------
  
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
  
  # -----------------------------
  # Check data
  # -----------------------------
  
  print(dim(d))
  print(names(d))
  print(unique(d$location))
  print(unique(d$variety))
  
  # -----------------------------
  # Write CAROB files
  # -----------------------------
  
  carobiner::write_files(
    path = path,
    metadata = meta,
    wide = d
  )
  
  return(d)
}