library(carobiner)

carob_script <- function(path) {
  
  ## =========================================================
  ## Dataset information
  ## =========================================================
  
  uri <- "doi:10.21223/HDAREL"
  group <- "agronomy"
  
  
  ## =========================================================
  ## Get source files
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
             "01_PTGlycoalkaloids082019_CIPHYO_exp1_data.xlsx"]
  
  f2 <- ff[basename(ff) ==
             "02_PTGlycoalkaloids082019_CIPHYO_exp1_material_list.xlsx"]
  
  f3 <- ff[basename(ff) ==
             "03_PTGlycoalkaloids082019_CIPHYO_exp1_installation.xlsx"]
  
  f4 <- ff[basename(ff) ==
             "04_PTGlycoalkaloids082019_CIPHYO_exp1_Dictionary.xlsx"]
  
  
  if (length(f1) != 1 ||
      length(f2) != 1 ||
      length(f3) != 1 ||
      length(f4) != 1) {
    
    stop("One or more expected source files were not found.")
  }
  
  
  ## =========================================================
  ## Read source files
  ## =========================================================
  
  c1 <- carobiner::read.excel(f1)
  c2 <- carobiner::read.excel(f2)
  c3 <- carobiner::read.excel(f3)
  c4 <- carobiner::read.excel(f4)
  
  
  ## =========================================================
  ## Experimental data
  ## =========================================================
  
  c1$PLOT <- as.integer(c1$PLOT)
  c1$REP <- as.integer(c1$REP)
  c1$INSTN <- trimws(as.character(c1$INSTN))
  
  c1$NTP <- as.numeric(c1$NTP)
  c1$NPH <- as.numeric(c1$NPH)
  c1$PPH <- as.numeric(c1$PPH)
  c1$GLIDW <- as.numeric(c1$GLIDW)
  
  
  ## =========================================================
  ## Material information
  ## =========================================================
  
  c2$Accession_Number <-
    trimws(as.character(c2$Accession_Number))
  
  material <- c2[, c(
    "Accession_Number",
    "Accession_Name",
    "Accession_code",
    "Female_AcceNumb",
    "Male_AcceNumb",
    "Population"
  )]
  
  material_key <-
    trimws(as.character(material$Accession_Number))
  
  idx <- match(c1$INSTN, material_key)
  
  
  ## Add material information
  ## without removing any observations
  
  c1$accession_name <-
    material$Accession_Name[idx]
  
  c1$accession_code <-
    material$Accession_code[idx]
  
  c1$female_accession_number <-
    material$Female_AcceNumb[idx]
  
  c1$male_accession_number <-
    material$Male_AcceNumb[idx]
  
  c1$population <-
    material$Population[idx]
  
  
  ## =========================================================
  ## Installation information
  ## =========================================================
  
  get_value <- function(x) {
    
    z <- c3$Value[c3$Factor == x]
    
    if (length(z) == 0) {
      return(NA)
    }
    
    z[1]
  }
  
  
  experimental_design <-
    as.character(
      get_value("Experimental_design")
    )
  
  
  number_of_replications <-
    as.numeric(
      get_value("Number_of_replications_or_blocks")
    )
  
  
  number_of_plants_per_plot <-
    as.numeric(
      get_value("Number_of_plants_planted_per_plot")
    )
  
  
  number_of_rows_per_plot <-
    as.numeric(
      get_value("Number_of_rows_per_plot")
    )
  
  
  number_of_plants_per_row <-
    as.numeric(
      get_value("Number_of_plants_per_row")
    )
  
  
  plot_size <-
    as.numeric(
      get_value("Plot_size_(m2)")
    )
  
  
  distance_between_plants <-
    as.numeric(
      get_value("Distance_between_plants_(m)")
    )
  
  
  distance_between_rows <-
    as.numeric(
      get_value("Distance_between_rows_(m)")
    )
  
  
  planting_density <-
    as.numeric(
      get_value("Planting_density_(plants/Ha)")
    )
  
  
  planting_date_raw <-
    get_value("Planting")
  
  
  harvest_date_raw <-
    get_value("Harvest")
  
  
  planting_date <- as.character(
    as.Date(
      planting_date_raw,
      format = "%d/%m/%Y"
    )
  )
  
  
  harvest_date <- as.character(
    as.Date(
      harvest_date_raw,
      format = "%d/%m/%Y"
    )
  )
  
  
  ## =========================================================
  ## Preserve original experimental order
  ## =========================================================
  
  c1 <- c1[order(c1$REP, c1$PLOT), ]
  
  row.names(c1) <- NULL
  
  
  ## =========================================================
  ## CAROB data
  ## =========================================================
  
  d <- data.frame(
    
    ## ---------------------------------------------------------
    ## Identification
    ## ---------------------------------------------------------
    
    trial_id = "HDAREL_exp1",
    
    plot_id = paste(
      c1$REP,
      c1$PLOT,
      sep = "_"
    ),
    
    crop = "potato",
    
    variety = c1$INSTN,
    
    rep = c1$REP,
    
    
    ## ---------------------------------------------------------
    ## Location
    ## ---------------------------------------------------------
    
    country = "Peru",
    
    location = "Huancayo",
    
    latitude = NA_real_,
    
    longitude = NA_real_,
    
    geo_from_source = FALSE,
    
    
    ## ---------------------------------------------------------
    ## Yield
    ## ---------------------------------------------------------
    
    ## No tuber weight/yield measurement is available.
    
    yield = NA_real_,
    
    yield_moisture = NA_real_,
    
    yield_part = NA_character_,
    
    yield_isfresh = NA,
    
    
    ## ---------------------------------------------------------
    ## Source response variables
    ## ---------------------------------------------------------
    
    NTP = c1$NTP,
    
    NPH = c1$NPH,
    
    PPH = c1$PPH,
    
    GLIDW = c1$GLIDW,
    
    
    ## ---------------------------------------------------------
    ## Material information
    ## ---------------------------------------------------------
    
    accession_name =
      c1$accession_name,
    
    accession_code =
      c1$accession_code,
    
    female_accession_number =
      c1$female_accession_number,
    
    male_accession_number =
      c1$male_accession_number,
    
    population =
      c1$population,
    
    
    ## ---------------------------------------------------------
    ## Experimental design
    ## ---------------------------------------------------------
    
    experimental_design =
      experimental_design,
    
    number_of_replications =
      number_of_replications,
    
    number_of_plants_per_plot =
      number_of_plants_per_plot,
    
    number_of_rows_per_plot =
      number_of_rows_per_plot,
    
    number_of_plants_per_row =
      number_of_plants_per_row,
    
    plot_size =
      plot_size,
    
    distance_between_plants =
      distance_between_plants,
    
    distance_between_rows =
      distance_between_rows,
    
    plant_density =
      planting_density,
    
    
    ## ---------------------------------------------------------
    ## Dates
    ## ---------------------------------------------------------
    
    planting_date =
      planting_date,
    
    harvest_date =
      harvest_date,
    
    
    ## ---------------------------------------------------------
    ## Management
    ## ---------------------------------------------------------
    
    irrigated = NA,
    
    N_fertilizer = NA_real_,
    
    P_fertilizer = NA_real_,
    
    K_fertilizer = NA_real_,
    
    
    ## ---------------------------------------------------------
    ## Trial characteristics
    ## ---------------------------------------------------------
    
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
    
    design = "Randomized Complete Block Design (RCBD)",
    
    data_type = "experiment",
    
    treatment_vars = "variety",
    
    response_vars = "NTP;NPH;PPH;GLIDW",
    
    notes = paste(
      "Potato clone evaluation for glycoalkaloid content",
      "in Huancayo, Peru.",
      "The experiment used a randomized complete block design",
      "with three replications and ten plants per plot.",
      "The source data contain number of tubers planted,",
      "number of harvested plants, percentage of plants harvested,",
      "and glycoalkaloid dry weight.",
      "No tuber weight or tuber yield measurement is provided."
    ),
    
    carob_contributor = "Maryam",
    
    carob_effort = 1,
    
    carob_completion = 100,
    
    carob_date = "2026-08-20"
  )
  
  meta$response_vars <- "NTP;NPH;PPH;GLIDW"  
  ## =========================================================
  ## Write CAROB files
  ## =========================================================
  
  carobiner::write_files(
    path,
    meta,
    d
  )
  
  
  ## =========================================================
  ## Return data
  ## =========================================================
  
  return(d)
}