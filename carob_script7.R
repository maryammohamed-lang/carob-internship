library(carobiner)
library(readxl)
library(dplyr)

carob_script <- function(path) {
  
  # =========================================================
  # 1. BASIC INFORMATION
  # =========================================================
  
  uri <- "doi:10.21223/B7HWWH"
  group <- "agronomy"
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  cat("\n===== FILES =====\n")
  print(basename(ff))
  
  
  # =========================================================
  # 2. IDENTIFY SOURCE DATA FILES
  # =========================================================
  
  file_huancayo <- ff[
    basename(ff) ==
      "01_LBHTC2-HUANCAYO 2020-2021_data.xlsx"
  ]
  
  file_huanuco <- ff[
    basename(ff) ==
      "02_LBHTC2-HUANCAYO 2020-2021_data.xlsx"
  ]
  
  file_oxapampa <- ff[
    basename(ff) ==
      "03_LBHTC2-OXAPAMPA 2020-2021_data .xlsx"
  ]
  
  if (length(file_huancayo) == 0)
    stop("Huancayo data file not found")
  
  if (length(file_huanuco) == 0)
    stop("Huanuco data file not found")
  
  if (length(file_oxapampa) == 0)
    stop("Oxapampa data file not found")
  
  
  # =========================================================
  # 3. READ SOURCE DATA
  # =========================================================
  
  huancayo <- readxl::read_excel(
    file_huancayo,
    sheet = "Huancayo 20-21"
  )
  
  huanuco <- readxl::read_excel(
    file_huanuco,
    sheet = "HCO21-01"
  )
  
  oxapampa <- readxl::read_excel(
    file_oxapampa,
    sheet = "OXAPAMPA 20-21"
  )
  
  
  # =========================================================
  # 4. STANDARDIZE SOURCE VARIABLE NAMES
  # =========================================================
  
  standardize_source <- function(dat) {
    
    names(dat) <- trimws(names(dat))
    
    names(dat)[names(dat) == "Tube Size"] <-
      "Tuber Size"
    
    names(dat)[names(dat) == "Tuber Size"] <-
      "tuber_size"
    
    names(dat)[names(dat) == "Tuber appareance"] <-
      "tuber_appearance"
    
    names(dat)[names(dat) == "Tuber uniformity"] <-
      "tuber_uniformity"
    
    names(dat)[names(dat) == "NMTP"] <- "nmtp"
    
    names(dat)[names(dat) == "NoNMTP"] <-
      "non_marketable_tubers"
    
    names(dat)[names(dat) == "TNTP"] <- "tntp"
    
    names(dat)[names(dat) == "MTWP"] <-
      "marketable_tuber_weight_plot"
    
    names(dat)[names(dat) == "NoMTWP"] <-
      "non_marketable_tuber_weight_plot"
    
    names(dat)[names(dat) == "TTWP"] <-
      "total_tuber_weight_plot"
    
    names(dat)[names(dat) == "DM %"] <-
      "dm_percent"
    
    names(dat)[names(dat) == "TTWPL"] <-
      "total_tuber_weight_plant"
    
    names(dat)[names(dat) == "𝐌𝐓𝐖𝐏L"] <-
      "marketable_tuber_weight_plant"
    
    names(dat)[names(dat) == "MTYNA"] <-
      "marketable_tuber_yield_na"
    
    names(dat)[names(dat) == "TbYldNAj"] <-
      "total_tuber_yield_na"
    
    names(dat)[names(dat) == "MTYA"] <-
      "marketable_tuber_yield_adjusted"
    
    names(dat)[names(dat) == "TTYA"] <-
      "total_tuber_yield_adjusted"
    
    names(dat)[names(dat) == "NPH"] <- "nph"
    
    names(dat)[names(dat) == "AUDPC"] <- "audpc"
    
    names(dat)[names(dat) == "rAUDPC"] <- "raudpc"
    
    names(dat)[names(dat) == "LB1"] <- "lb1"
    names(dat)[names(dat) == "LB2"] <- "lb2"
    names(dat)[names(dat) == "LB3"] <- "lb3"
    names(dat)[names(dat) == "LB4"] <- "lb4"
    names(dat)[names(dat) == "LB5"] <- "lb5"
    names(dat)[names(dat) == "LB6"] <- "lb6"
    names(dat)[names(dat) == "LB7"] <- "lb7"
    names(dat)[names(dat) == "LB8"] <- "lb8"
    
    # -------------------------------------------------------
    # FORCE COMMON NUMERIC VARIABLES TO NUMERIC
    # -------------------------------------------------------
    
    numeric_vars <- intersect(
      c(
        "ID",
        "Rep",
        "Column",
        "Row",
        "nph",
        "nmtp",
        "non_marketable_tubers",
        "tntp",
        "marketable_tuber_weight_plot",
        "non_marketable_tuber_weight_plot",
        "total_tuber_weight_plot",
        "dm_percent",
        "total_tuber_weight_plant",
        "marketable_tuber_weight_plant",
        "marketable_tuber_yield_na",
        "total_tuber_yield_na",
        "marketable_tuber_yield_adjusted",
        "total_tuber_yield_adjusted",
        "tuber_appearance",
        "tuber_uniformity",
        "tuber_size",
        "lb1",
        "lb2",
        "lb3",
        "lb4",
        "lb5",
        "lb6",
        "lb7",
        "lb8",
        "audpc",
        "raudpc"
      ),
      names(dat)
    )
    
    dat[numeric_vars] <- lapply(
      dat[numeric_vars],
      function(x) {
        suppressWarnings(
          as.numeric(as.character(x))
        )
      }
    )
    
    dat
  }
  
  
  huancayo <- standardize_source(huancayo)
  huanuco <- standardize_source(huanuco)
  oxapampa <- standardize_source(oxapampa)
  
  
  # =========================================================
  # 5. ADD EXPERIMENT INFORMATION
  # =========================================================
  
  huancayo <- huancayo %>%
    mutate(
      experiment_id = "HUANCAYO_01",
      location = "Huancayo",
      country = "Peru",
      year = 2020
    )
  
  huanuco <- huanuco %>%
    mutate(
      experiment_id = "HUANUCO_01",
      location = "Huanuco",
      country = "Peru",
      year = 2020
    )
  
  oxapampa <- oxapampa %>%
    mutate(
      experiment_id = "OXAPAMPA_01",
      location = "Oxapampa",
      country = "Peru",
      year = 2020
    )
  
  
  # =========================================================
  # 6. COMBINE EXPERIMENTS
  # =========================================================
  
  dat <- dplyr::bind_rows(
    huancayo,
    huanuco,
    oxapampa
  )
  
  
  # =========================================================
  # 7. STANDARDIZE EXPERIMENTAL IDENTIFIERS
  # =========================================================
  
  dat <- dat %>%
    mutate(
      plot_id = as.character(ID),
      rep = as.integer(Rep),
      column = as.integer(Column),
      row = as.integer(Row),
      genotype = as.character(Genotype),
      genotype_type = as.character(Type),
      female = as.character(Female),
      male = as.character(Male)
    )
  
  
  # =========================================================
  # 8. CREATE TRIAL ID
  # =========================================================
  
  dat <- dat %>%
    mutate(
      trial_id = paste(
        experiment_id,
        year,
        sep = "_"
      )
    )
  
  
  # =========================================================
  # 9. YIELD
  # =========================================================
  #
  # MTYNA = marketable tuber yield, non-adjusted
  #
  # Source yield is converted from t/ha to kg/ha.
  #
  # =========================================================
  
  dat <- dat %>%
    mutate(
      yield = as.numeric(
        marketable_tuber_yield_na
      ) * 1000,
      
      yield_part = "tubers",
      
      yield_isfresh = TRUE,
      
      yield_moisture = NA_real_
    )
  
  
  # =========================================================
  # 10. CAROB STANDARD VARIABLES
  # =========================================================
  
  dat <- dat %>%
    mutate(
      
      crop = "potato",
      
      variety = genotype,
      
      dataset_id = uri,
      
      record_id = seq_len(nrow(dat)),
      
      on_farm = FALSE,
      
      is_survey = FALSE,
      
      geo_from_source = FALSE,
      
      latitude = NA_real_,
      
      longitude = NA_real_,
      
      planting_date = as.Date(NA),
      
      harvest_date = as.Date(NA),
      
      N_fertilizer = NA_real_,
      
      P_fertilizer = NA_real_,
      
      K_fertilizer = NA_real_,
      
      irrigated = NA
    )
  
  
  # =========================================================
  # 11. KEEP CAROB VARIABLES
  # =========================================================
  
  carob_vars <- c(
    
    "trial_id",
    "plot_id",
    "rep",
    "column",
    "row",
    
    "crop",
    "variety",
    "genotype_type",
    
    "yield_part",
    "yield",
    "yield_moisture",
    "yield_isfresh",
    
    "nmtp",
    "non_marketable_tubers",
    "tntp",
    
    "marketable_tuber_weight_plot",
    "non_marketable_tuber_weight_plot",
    "total_tuber_weight_plot",
    
    "total_tuber_weight_plant",
    "marketable_tuber_weight_plant",
    
    "marketable_tuber_yield_na",
    "total_tuber_yield_na",
    
    "marketable_tuber_yield_adjusted",
    "total_tuber_yield_adjusted",
    
    "dm_percent",
    
    "tuber_appearance",
    "tuber_uniformity",
    "tuber_size",
    
    "nph",
    
    "lb1",
    "lb2",
    "lb3",
    "lb4",
    "lb5",
    "lb6",
    "lb7",
    "lb8",
    
    "audpc",
    "raudpc",
    
    "dataset_id",
    "record_id",
    
    "on_farm",
    "is_survey",
    
    "country",
    "location",
    
    "geo_from_source",
    "latitude",
    "longitude",
    
    "planting_date",
    "harvest_date",
    
    "N_fertilizer",
    "P_fertilizer",
    "K_fertilizer",
    
    "irrigated"
  )
  
  carob_vars <- intersect(
    carob_vars,
    names(dat)
  )
  
  d_carob <- dat[
    ,
    carob_vars,
    drop = FALSE
  ]
  
  d_carob <- as.data.frame(d_carob)
  
  
  # =========================================================
  # 12. METADATA
  # =========================================================
  
  meta <- carobiner::get_metadata(
    uri = uri,
    path = path,
    group = group,
    
    major = 2,
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
  # 13. CLEAN METADATA
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
  # 14. FINAL CHECK
  # =========================================================
  
  cat("\n========================================\n")
  cat("FINAL CAROB DATA CHECK\n")
  cat("========================================\n")
  
  cat(
    "Rows:",
    nrow(d_carob),
    "\n"
  )
  
  cat(
    "Columns:",
    ncol(d_carob),
    "\n"
  )
  
  
  cat("\n===== EXPERIMENTS =====\n")
  
  print(
    table(
      d_carob$trial_id,
      useNA = "ifany"
    )
  )
  
  
  cat("\n===== LOCATIONS =====\n")
  
  print(
    table(
      d_carob$location,
      useNA = "ifany"
    )
  )
  
  
  cat("\n===== UNIQUE GENOTYPES =====\n")
  
  print(
    length(
      unique(
        stats::na.omit(
          d_carob$variety
        )
      )
    )
  )
  
  
  cat("\n===== GENOTYPE TYPES =====\n")
  
  print(
    table(
      dat$genotype_type,
      useNA = "ifany"
    )
  )
  
  
  cat("\n===== YIELD RANGE (kg/ha) =====\n")
  
  print(
    range(
      d_carob$yield,
      na.rm = TRUE
    )
  )
  
  
  cat("\n===== YIELD SUMMARY =====\n")
  
  print(
    summary(
      d_carob$yield
    )
  )
  
  
  cat("\n===== MISSING YIELD =====\n")
  
  print(
    sum(
      is.na(
        d_carob$yield
      )
    )
  )
  
  
  cat("\n===== RECORD ID CHECK =====\n")
  
  cat(
    "Total records:",
    nrow(d_carob),
    "\n"
  )
  
  cat(
    "Unique record IDs:",
    length(
      unique(
        d_carob$record_id
      )
    ),
    "\n"
  )
  
  cat(
    "Duplicated record IDs:",
    sum(
      duplicated(
        d_carob$record_id
      )
    ),
    "\n"
  )
  
  
  # =========================================================
  # 15. CAROB TERMS CHECK
  # =========================================================
  
  final_check <- carobiner::check_terms(
    records = d_carob,
    metadata = meta,
    group = group,
    check = "all"
  )
  
  cat("\n===== CAROB CHECK =====\n")
  
  print(final_check)
  
  
  # =========================================================
  # 16. WRITE CAROB FILES
  # =========================================================
  
  cat("\n===== WRITING CAROB FILES =====\n")
  
  carobiner::write_files(
    path = path,
    metadata = meta,
    wide = d_carob
  )
  
  
  # =========================================================
  # 17. SAVE FINAL DATA COPY
  # =========================================================
  
  write.csv(
    d_carob,
    file.path(
      path,
      "final_B7HWWH.csv"
    ),
    row.names = FALSE
  )
  
  
  # =========================================================
  # 18. FINISHED
  # =========================================================
  
  cat("\n========================================\n")
  cat("DATASET 508 FINISHED\n")
  cat("DOI: 10.21223/B7HWWH\n")
  cat("========================================\n")
  
  return(d_carob)
}