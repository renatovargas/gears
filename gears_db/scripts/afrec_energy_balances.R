# Food and Agriculture Organization of the United Nations (FAO)
# Agrifood Economics and Policy Division (ESA)
# Monitoring and Analysing Food and Agricultural Policies (MAFAP)
# Global Emissions Analysis for Resilient Systems (GEARS)

# Preprocess AFREC Energy Balances for Africa

# Note: This is the script to import the AFREC energy balances.
# *.csv files are not in the data folder for 
# space considerations. 
# Visit:https://au-afrec.org/index.php/data-statistics-energy-balances
# A leaner version in DuckDb format can be found in the 
# data folder of this repository at: 
# "gears_db/data/afrec_energy_balances.duckdb"

library(dplyr)
library(duckdb)
# library(readr)

all_data <- read.csv(
  "gears_db/data/afrec/all_data.csv", stringsAsFactors = T)
series <- read.csv(
  "gears_db/data/afrec/series.csv", stringsAsFactors = T)
units <- read.csv(
  "gears_db/data/afrec/units.csv", stringsAsFactors = T)
zones <- read.csv(
  "gears_db/data/afrec/zones.csv", stringsAsFactors = T)

con <- dbConnect(
  duckdb(), 
  dbdir = "gears_db/data/afrec_energy_balances.duckdb", 
  read_only = FALSE)
dbWriteTable(con, "all_data", all_data, overwrite = T)
dbWriteTable(con, "series", series, overwrite = T)
dbWriteTable(con, "units", units, overwrite = T)
dbWriteTable(con, "zones", zones, overwrite = T)
dbDisconnect(con)