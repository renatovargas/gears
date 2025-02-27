library(tidyverse)
library(readxl)

rm(list = ls())

# Set the path to the RDS directory
path <- "emdb/data/un_energy/original_datasets"

# List all RDS files in the directory
file_list <- list.files(path = path, pattern = "\\.rds$", full.names = TRUE)

# Initialize an empty list to store data frames
data_list <- list()

# Loop through each file and read it into the list
for (file in file_list) {
  # Read the RDS file
  temp_data <- readRDS(file)
  
  # Split the "Commodity - Transaction" column into two columns
  split_columns <- strsplit(temp_data$Commodity...Transaction, " - ", fixed = TRUE)
  temp_data$Commodity <- sapply(split_columns, `[`, 1)
  temp_data$Transaction <- sapply(split_columns, `[`, 2)
  
  # Append the processed data to the list
  data_list[[basename(file)]] <- temp_data
}

# Combine all data frames into a single data frame
combined_data2 <- do.call(rbind, data_list)

# Remove auto row names
row.names(combined_data2) <- NULL

# Make all observations lowercase to avoid duplicates
combined_data2$Transaction <- tolower(combined_data2$Transaction)
combined_data2$Commodity <- tolower(combined_data2$Commodity)

# Remove leading and trailing spaces from the Transaction column
combined_data2$Transaction <- trimws(combined_data2$Transaction)
combined_data2$Commodity <- trimws(combined_data2$Commodity)

fixed_transactions <- read_xlsx(
  "emdb/data/classifications/un_energy_transactions_fix.xlsx",
  sheet = "Transaction")
fixed_commodities <- read_xlsx(
  "emdb/data/classifications/un_energy_transactions_fix.xlsx",
  sheet = "Commodity")
fixed_countries <- read_xlsx(
  "emdb/data/classifications/un_energy_transactions_fix.xlsx",
  sheet = "Countries")

combined_data <- combined_data2 |> 
  left_join(fixed_transactions, join_by(Transaction)) |>
  left_join(fixed_commodities, join_by(Commodity)) |>
  left_join(fixed_countries, join_by(Country.or.Area)) |> 
  select(-c(Commodity...Transaction,
            Quantity.Footnotes,
            Transaction,
            Commodity,
            Country.or.Area)) |> 
  rename(Transaction = `Fixed Transaction`,
         Commodity = `Fixed Commodity`) |> 
  mutate(Transaction = str_to_sentence(Transaction),
         Commodity = str_to_sentence(Commodity)) |>
  filter(! is.na(ISO3) ) |> 
  mutate(across(where(is.character), as.factor)) |> 
  relocate(ISO3, .before = Year) |> 
  relocate(c(`Area Code`, Area), .before = ISO3)

# Save to RDS to save space
saveRDS(combined_data,"emdb/data/un_energy/un_energy.rds")