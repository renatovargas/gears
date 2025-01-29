library(tidyverse)

rm(list = ls())

# Set the working directory to the folder containing the CSV files
path <- "D:/_work/UN_ENERGY"

# List all CSV files in the directory
file_list <- list.files(path = path, pattern = "*.csv")

# Initialize an empty list to store data frames
data_list <- list()

# Loop through each file and read it into the list
for (file in file_list) {
  # Read the CSV file
  temp_data <- read.csv(paste0(path,"//",file), stringsAsFactors = FALSE)
  
  # Split the "Commodity - Transaction" column into two columns
  split_columns <- strsplit(temp_data$Commodity...Transaction, " - ", fixed = TRUE)
  temp_data$Commodity <- sapply(split_columns, `[`, 1)
  temp_data$Transaction <- sapply(split_columns, `[`, 2)
  
  # Append the processed data to the list
  data_list[[file]] <- temp_data
}

# Combine all data frames into a single data frame
combined_data <- do.call(rbind, data_list)

# Remove auto row names
row.names(combined_data) <- NULL

# Make all observations lowercase to avoid duplicates
combined_data$Transaction <- tolower(combined_data$Transaction)

# Remove leading and trailing spaces from the Transaction column
combined_data$Transaction <- trimws(combined_data$Transaction)

# View the first few rows of the combined data frame
head(combined_data)

# combined_data <- combined_data |> 
#   mutate(across(where(is.character), as.factor))

saveRDS(combined_data,"gears_db/data/un_energy/un_energy.rds")