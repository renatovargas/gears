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
combined_data$Commodity <- tolower(combined_data$Commodity)

# Remove leading and trailing spaces from the Transaction column
combined_data$Transaction <- trimws(combined_data$Transaction)
combined_data$Commodity <- trimws(combined_data$Commodity)


# #Fix transaction duplicates
# write.table(
#   sort(unique(un_energy$Commodity)),
#   "clipboard",
#   sep = "\t",
#   row.names = F)

fixed_transactions <- read_xlsx(
  "gears_db/data/classifications/un_energy_transactions_fix.xlsx",
  sheet = "Transaction")
fixed_commodities <- read_xlsx(
  "gears_db/data/classifications/un_energy_transactions_fix.xlsx",
  sheet = "Commodity")

combined_data <- combined_data |> 
  left_join(fixed_transactions, join_by(Transaction)) |>
  left_join(fixed_commodities, join_by(Commodity)) |> 
  select(-c(Commodity...Transaction,
            Quantity.Footnotes,
            Transaction,
            Commodity)) |> 
  rename(Transaction = `Fixed Transaction`,
         Commodity = `Fixed Commodity`) |> 
  mutate(Transaction = str_to_sentence(Transaction),
         Commodity = str_to_sentence(Commodity)) |> 
  mutate(across(where(is.character), as.factor))

# Save to RDS to save space
saveRDS(combined_data,"gears_db/data/un_energy/un_energy.rds")