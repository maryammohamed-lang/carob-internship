library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/H8E8KL"
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
             "01_PTYield112020_CAJ_exp1_data.xlsx"]
  
  f2 <- ff[basename(ff) ==
             "02_PTYield112020_HCHO_exp2_data.xlsx"]
  
  f3 <- ff[basename(ff) ==
             "03_PTYield112020_HCHO_exp3_data.xlsx"]
  
  f4 <- ff[basename(ff) ==
             "04_Materials_list.xlsx"]
  
  files <- c(f1, f2, f3, f4)
  
  if (length(files) != 4 || any(is.na(files))) {
    stop("One or more expected Excel files were not found.")
  }
  
  
  ## =========================================================
  ## Read source files
  ## =========================================================
  
  r1 <- carobiner::read.excel(f1)
  r2 <- carobiner::read.excel(f2)
  r3 <- carobiner::read.excel(f3)
  r4 <- carobiner::read.excel(f4)
  
  
  ## =========================================================
  ## Add experiment and location
  ## =========================================================
  
  r1$experiment <- "CAJ_exp1"
  r1$location <- "Cajamarca"
  
  r2$experiment <- "HCHO_exp2"
  r2$location <- "Huamachuco"
  
  r3$experiment <- "HCHO_exp3"
  r3$location <- "Huamachuco"
  
  
  ## =========================================================
  ## Make the three experimental datasets
  ## have the same columns
  ## =========================================================
  
  all_names <- union(
    names(r1),
    union(names(r2), names(r3))
  )
  
  add_missing_columns <- function(x, all_names) {
    
    missing <- setdiff(all_names, names(x))
    
    for (v in missing) {
      x[[v]] <- NA
    }
    
    x <- x[, all_names, drop = FALSE]
    
    return(x)
  }
  
  r1 <- add_missing_columns(r1, all_names)
  r2 <- add_missing_columns(r2, all_names)
  r3 <- add_missing_columns(r3, all_names)
  
  
  ## =========================================================
  ## Combine the three experimental datasets
  ## =========================================================
  
  r <- rbind(
    r1,
    r2,
    r3
  )
  
  
  ## =========================================================
  ## Standardize identifiers
  ## =========================================================
  
  r$PLOT <- as.character(r$PLOT)
  r$REP <- as.integer(r$REP)
  r$INSTN <- as.character(r$INSTN)
  
  r$experiment <- as.character(r$experiment)
  r$location <- as.character(r$location)
  
  
  ## =========================================================
  ## CAROB standardized data
  ## =========================================================
  
  d <- data.frame(
    
    ## Trial information
    trial_id = paste(
      "H8E8KL",
      r$experiment,
      sep = "_"
    ),
    
    plot_id = r$PLOT,
    
    crop = "potato",
    
    variety = r$INSTN,
    
    rep = r$REP,
    
    country = "Peru",
    
    location = r$location,
    
    
    ## =======================================================
    ## Yield
    ## =======================================================
    
    ## TTYA = Total Tuber Yield Adjusted.
    ## Source unit: tons/ha.
    ## CAROB yield unit: kg/ha.
    ## Therefore, TTYA is converted from tons/ha to kg/ha.
    
    yield = r$TTYA * 1000,
    
    yield_moisture = NA_real_,
    
    yield_part = "tubers",
    
    ## TTYA is based on fresh tuber weight.
    yield_isfresh = TRUE,
    
    
    ## =======================================================
    ## Location
    ## =======================================================
    
    ## Coordinates represent the reported location/city,
    ## because exact trial coordinates are not available
    ## in the source dataset.
    
    latitude = ifelse(
      r$location == "Cajamarca",
      -7.16378,
      ifelse(
        r$location == "Huamachuco",
        -7.81547,
        NA_real_
      )
    ),
    
    longitude = ifelse(
      r$location == "Cajamarca",
      -78.50027,
      ifelse(
        r$location == "Huamachuco",
        -78.04871,
        NA_real_
      )
    ),
    
    
    ## =======================================================
    ## Management
    ## =======================================================
    
    
    irrigated = NA,
    
    N_fertilizer = NA_real_,
    P_fertilizer = NA_real_,
    K_fertilizer = NA_real_,
    
    
    ## =======================================================
    ## Dates
    ## =======================================================
    
    planting_date = NA_character_,
    harvest_date = NA_character_,
    
    
    ## =======================================================
    ## Other CAROB fields
    ## =======================================================
    
    is_survey = FALSE,
    on_farm = FALSE,
    geo_from_source = FALSE,
    
    stringsAsFactors = FALSE
  )
  
  
  ## =========================================================
  ## Preserve ALL important source variables
  ##
  ## These variables are important experimental measurements.
  ## They are retained even though they are not currently
  ## part of the CAROB standard vocabulary.
  ## =========================================================
  
  d$NTP <- r$NTP
  d$NPH <- r$NPH
  d$PPH <- r$PPH
  
  d$NNoMTP <- r$NNoMTP
  d$TNTP <- r$TNTP
  d$NMTP <- r$NMTP
  
  d$NoMTWP <- r$NoMTWP
  d$TTWP <- r$TTWP
  
  d$TTYNA <- r$TTYNA
  d$TTYA <- r$TTYA
  
  d$MTWP <- r$MTWP
  d$MTYNA <- r$MTYNA
  d$MTYA <- r$MTYA
  
  d$Tuber_Apper <- r$Tuber_Apper
  d$Tub_Unif <- r$Tub_Unif
  d$Tub_Size <- r$Tub_Size
  
  
  ## These variables are available only in experiment 1.
  ## Missing values in experiments 2 and 3 are retained.
  
  d$TBSKN1 <- r$TBSKN1
  d$TBSKN2 <- r$TBSKN2
  d$TBFSH1 <- r$TBFSH1
  d$TBSHP1 <- r$TBSHP1
  d$TBSHP3 <- r$TBSHP3
  
  
  ## =========================================================
  ## Metadata
  ## =========================================================
  
  meta <- carobiner::get_metadata(
    
    uri = uri,
    path = path,
    group = group,
    
    major = 1,
    minor = 2,
    
    data_organization = "CIP",
    
    publication = NA,
    project = NA,
    design = "randomized complete block design",
    
    data_type = "experiment",
    
    treatment_vars = "variety",
    
    response_vars = paste(
      "yield",
      "NPH",
      "PPH",
      "NNoMTP",
      "TNTP",
      "NMTP",
      "NoMTWP",
      "TTWP",
      "TTYNA",
      "TTYA",
      "MTWP",
      "MTYNA",
      "MTYA",
      "Tuber_Apper",
      "Tub_Unif",
      "Tub_Size",
      sep = ";"
    ),
    
    notes = paste(
      "Potato varietal evaluation during 2020-2021",
      "in Cajamarca and Huamachuco, Peru.",
      "The experiments used a randomized complete block",
      "design with three replications.",
      "The reported total tuber yield (TTYA) is in tons/ha",
      "and was converted to kg/ha for the CAROB yield field.",
      "The publication reports NPK fertilization of",
      "200-220-180 kg/ha.",
      "Coordinates represent the reported city locations",
      "because exact trial coordinates were not available",
      "in the source data."
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