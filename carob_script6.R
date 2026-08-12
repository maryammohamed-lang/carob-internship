library(carobiner)
library(readr)
library(dplyr)
library(stringr)

# ============================================================
# DATASET 508
# Genomic selection for resistance to LB in population LBHTC2
# DOI: 10.21223/B7HWWH
# ============================================================

carob_script <- function(path) {
  
  uri <- "doi:10.21223/B7HWWH"
  group <- "agronomy"
  
  # ----------------------------------------------------------
  # 1. GET DATA FROM CAROB
  # ----------------------------------------------------------
  
  ff <- carobiner::get_data(
    uri = uri,
    path = path,
    group = group
  )
  
  cat("\n============================================================\n")
  cat("DATASET 508 - FILES DOWNLOADED\n")
  cat("============================================================\n")
  
  print(ff)
  
  # ----------------------------------------------------------
  # 2. FILE INFORMATION
  # ----------------------------------------------------------
  
  file_info <- tibble(
    file = basename(ff),
    full_path = ff,
    extension = tools::file_ext(ff),
    size_kb = round(file.info(ff)$size / 1024, 2)
  )
  
  cat("\n============================================================\n")
  cat("FILE INFORMATION\n")
  cat("============================================================\n")
  
  print(file_info)
  
  # ----------------------------------------------------------
  # 3. READ ALL TAB FILES WITHOUT CHANGING ANYTHING
  # ----------------------------------------------------------
  
  read_tab <- function(file) {
    
    cat("\n------------------------------------------------------------\n")
    cat("READING:", basename(file), "\n")
    cat("------------------------------------------------------------\n")
    
    dat <- read.delim(
      file,
      header = TRUE,
      sep = "\t",
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = c("", "NA", "NaN", "NULL")
    )
    
    cat("Rows:", nrow(dat), "\n")
    cat("Columns:", ncol(dat), "\n")
    
    cat("\nCOLUMN NAMES:\n")
    print(names(dat))
    
    cat("\nDATA TYPES:\n")
    print(sapply(dat, class))
    
    cat("\nFIRST 10 ROWS:\n")
    print(head(dat, 10))
    
    return(dat)
  }
  
  tab_files <- ff[
    str_to_lower(tools::file_ext(ff)) == "tab"
  ]
  
  all_data <- lapply(tab_files, read_tab)
  
  names(all_data) <- basename(tab_files)
  
  # ----------------------------------------------------------
  # 4. SAVE STRUCTURE INFORMATION
  # ----------------------------------------------------------
  
  output_file <- file.path(
    path,
    "B7HWWH_structure_information.txt"
  )
  
  sink(output_file)
  
  cat("============================================================\n")
  cat("DATASET 508 STRUCTURE INFORMATION\n")
  cat("DOI: 10.21223/B7HWWH\n")
  cat("============================================================\n\n")
  
  for (i in seq_along(all_data)) {
    
    dat <- all_data[[i]]
    
    cat("\n\n############################################################\n")
    cat("FILE:", names(all_data)[i], "\n")
    cat("############################################################\n\n")
    
    cat("DIMENSIONS:\n")
    cat("Rows:", nrow(dat), "\n")
    cat("Columns:", ncol(dat), "\n\n")
    
    cat("COLUMN NAMES:\n")
    print(names(dat))
    
    cat("\n\nDATA TYPES:\n")
    print(sapply(dat, class))
    
    cat("\n\nFIRST 20 ROWS:\n")
    print(head(dat, 20))
  }
  
  sink()
  
  # ----------------------------------------------------------
  # 5. FINAL MESSAGE
  # ----------------------------------------------------------
  
  cat("\n\n============================================================\n")
  cat("STRUCTURE INSPECTION COMPLETE\n")
  cat("============================================================\n")
  
  cat(
    "\nComplete structure file:\n",
    normalizePath(output_file),
    "\n\n"
  )
  
  cat(
    "IMPORTANT: No variables were deleted or transformed.\n"
  )
  
  cat(
    "Next step: identify yield, genotype, trial, location and\n",
    "other CAROB variables from the actual data structure.\n"
  )
  
  invisible(all_data)
}