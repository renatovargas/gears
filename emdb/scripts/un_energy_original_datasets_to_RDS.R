# UN Energy to RDS

rm(list = ls())

# Path to CSV files
path <- "/VAULT/_work/UN_ENERGY"

# Create RDS folder if it doesn't exist
if (!dir.exists("emdb/data/un_energy/original_datasets")) {
  dir.create("emdb/data/un_energy/original_datasets")
}

# List all CSV files in the directory
file_list <- list.files(path = path, pattern = "\\.csv$", full.names = TRUE)

for (file in file_list) {
  temp_data <- read.csv(file, stringsAsFactors = FALSE)
  
  # Construct RDS filename by replacing .csv with .rds
  rds_filename <- gsub("\\.csv$", ".rds", basename(file))

  # Save as RDS
  saveRDS(
    temp_data, 
    file = paste0( 
      "emdb/data/un_energy/original_datasets/", 
      rds_filename))
}

