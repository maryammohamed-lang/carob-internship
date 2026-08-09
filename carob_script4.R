library(carobiner)
library(readxl)
library(dplyr)

carob_script <- function(path) {
  
  # =========================================================
  # BASIC INFORMATION
  # =========================================================
  
  uri <- "doi:10.21223/P3/QJ10B7"
  group <- "agronomy"
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  # =========================================================
  # READ MOTHER HARVEST DATA
  # =========================================================
  
  allato <- readxl::read_excel(
    ff[basename(ff) == "PTPV201311_ALLATO.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  chacap <- readxl::read_excel(
    ff[basename(ff) == "PTPV201311_CHACAP.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  occo <- readxl::read_excel(
    ff[basename(ff) == "PTPV201311_OCCO.xls"],
    sheet = "F4_ Harvest_Mother"
  )
  
  # =========================================================
  # ADD SITE AND POPULATION
  # =========================================================
  
  allato <- allato %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Allato",
      Population = "Mother"
    )
  
  chacap <- chacap %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Chacapunco",
      Population = "Mother"
    )
  
  occo <- occo %>%
    mutate(
      PLOT = as.numeric(PLOT),
      REP = as.numeric(REP),
      Site = "Occo Centro",
      Population = "Mother"
    )
  
  # =========================================================
  # COMBINE DATA
  # =========================================================
  
  dat <- dplyr::bind_rows(
    allato,
    chacap,
    occo
  )
  
  # =========================================================
  # KEEP OBSERVATIONS WITH YIELD
  # =========================================================
  
  dat <- dat %>%
    filter(!is.na(TTYA))
  
  # =========================================================
  # RENAME ORIGINAL VARIABLES
  # =========================================================
  
  dat <- dat %>%
    rename(
      plot_id = PLOT,
      rep = REP,
      variety = INSTN,
      genotype_code = Code,
      
      number_tubers_planted = NTP,
      number_plants_harvested = NPH,
      percent_plants_harvested = PPH,
      
      number_marketable_tubers = NMTP,
      number_non_marketable_tubers = NNoMTP,
      
      marketable_tuber_number_per_plant = NMTPL,
      marketable_tuber_weight_per_plant = MTWP,
      
      non_marketable_tuber_weight_per_plant = NoMTWP,
      
      total_number_tubers = TNTP,
      total_tuber_number_per_plant = TNTPL,
      
      total_tuber_weight = TTWP,
      total_tuber_weight_per_plant = TTWPL,
      
      total_tuber_yield_non_adjusted = TTYNA,
      total_tuber_yield_adjusted = TTYA,
      
      marketable_tuber_weight_per_land_area = MTWPL,
      
      marketable_tuber_yield_non_adjusted = MTYNA,
      marketable_tuber_yield_adjusted = MTYA,
      
      average_tuber_weight = ATW,
      
      location = Site,
      population = Population
    )
  
  # =========================================================
  # ADD CAROB STANDARD VARIABLES
  # =========================================================
  
  dat <- dat %>%
    mutate(
      
      # Trial identifier
      trial_id = paste(
        location,
        population,
        sep = "_"
      ),
      
      # Dataset information
      dataset_id = uri,
      
      # Basic CAROB variables
      country = "Peru",
      crop = "potato",
      latitude = NA_real_,
      longitude = NA_real_,
      # Experimental information

      # IMPORTANT:
      # TTYA is used directly.
      # Yield is expressed in t/ha.
      # DO NOT multiply or divide by 1000 here.
      yield = as.numeric(total_tuber_yield_adjusted),
      
      yield_part = "tubers",
      yield_isfresh = TRUE,
      yield_moisture = NA_real_,
      
      is_survey = FALSE,
      on_farm = TRUE,
      
      # No coordinates are available in the source data
      geo_from_source = FALSE,
      
      # Dates are not available in the source data
      planting_date = as.Date(NA),
      harvest_date = as.Date(NA),
      
      # Fertilizer information is not available
      N_fertilizer = NA_real_,
      P_fertilizer = NA_real_,
      K_fertilizer = NA_real_,
      
      # Irrigation information is not available
      irrigated = NA
    )
  
  # =========================================================
  # CONVERT BASIC TYPES
  # =========================================================
  
  dat <- dat %>%
    mutate(
      plot_id = as.character(plot_id),
      rep = as.integer(rep),
      variety = as.character(variety),
      country = as.character(country),
      crop = as.character(crop),
      location = as.character(location),
      population = as.character(population),
      trial_id = as.character(trial_id),
      dataset_id = as.character(dataset_id),
      yield = as.numeric(yield)
    )
  
  # =========================================================
  # CREATE RECORD ID
  # =========================================================
  
  dat$record_id <- paste(
    dat$dataset_id,
    dat$trial_id,
    dat$plot_id,
    sep = "_"
  )
  dat$record_id <- seq_len(nrow(dat))
  # =========================================================
  # METADATA
  # =========================================================
  
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
  
  # =========================================================
  # CLEAN METADATA
  # =========================================================
  
  if ("crops" %in% names(meta)) {
    meta$crops <- NULL
  }
  
  if ("countries" %in% names(meta)) {
    meta$countries <- NULL
  }
  
  if ("version" %in% names(meta)) {
    meta$version <- as.character(meta$version)
  }
  
  # =========================================================
  # KEEP VERIFIED CAROB VARIABLES
  # =========================================================
  #
  # Do NOT use:
  # carobiner:::carob_vocabulary()$name
  #
  # In this carobiner version the returned object is not
  # a data frame, which caused:
  #
  # $ operator is invalid for atomic vectors
  #
  # =========================================================
  
  carob_vars <- c(
    "trial_id",
    "plot_id",
    "rep",
    "crop",
    "variety",
    "yield_part",
    "yield",
    "yield_moisture",
    "yield_isfresh",
    "dataset_id",
    "record_id",
    "on_farm",
    "is_survey",
    "country",
    "location",
    "latitude",
    "longitude",
    "geo_from_source",
    "planting_date",
    "harvest_date",
    "N_fertilizer",
    "P_fertilizer",
    "K_fertilizer",
    "irrigated"
  )
  # Keep only variables that exist
  carob_vars <- intersect(
    carob_vars,
    names(dat)
  )
  
  d_carob <- dat[
    ,
    carob_vars,
    drop = FALSE
  ]
  
  # Make sure it is an ordinary data.frame
  d_carob <- as.data.frame(d_carob)
  
  # =========================================================
  # FINAL DATA CHECK
  # =========================================================
  
  cat("\n========================================\n")
  cat("FINAL CAROB DATA CHECK\n")
  cat("========================================\n")
  
  cat("Rows:", nrow(d_carob), "\n")
  cat("Columns:", ncol(d_carob), "\n")
  
  cat("\n===== VARIETIES =====\n")
  print(
    table(
      d_carob$variety,
      useNA = "ifany"
    )
  )
  
  cat("\n===== UNIQUE VARIETIES =====\n")
  print(
    length(
      unique(
        stats::na.omit(d_carob$variety)
      )
    )
  )
  
  cat("\n===== YIELD RANGE (t/ha) =====\n")
  print(
    range(
      d_carob$yield,
      na.rm = TRUE
    )
  )
  
  cat("\n===== YIELD SUMMARY =====\n")
  print(
    summary(d_carob$yield)
  )
  
  cat("\n===== MISSING YIELD =====\n")
  print(
    sum(is.na(d_carob$yield))
  )
  
  cat("\n===== DATASET ID =====\n")
  print(
    table(d_carob$dataset_id)
  )
  
  cat("\n===== RECORD ID CHECK =====\n")
  cat(
    "Unique record IDs:",
    length(unique(d_carob$record_id)),
    "\n"
  )
  
  # =========================================================
  # CHECK CAROB TERMS
  # =========================================================
  
  check_result <- carobiner::check_terms(
    records = d_carob,
    metadata = meta,
    group = group,
    check = "all"
  )
  
  cat("\n===== CAROB CHECK =====\n")
  print(check_result)
  
  # =========================================================
  # WRITE CAROB FILES
  # =========================================================
  
  cat("\n===== WRITING CAROB FILES =====\n")
  
  carobiner::write_files(
    path = path,
    metadata = meta,
    wide = d_carob
  )
  
  cat("\n===== FINISHED =====\n")
  
  return(d_carob)
}
