# Food and Agriculture Organization of the United Nations (FAO)
# Agrifood Economics and Policy Division (ESA)
# Monitoring and Analysing Food and Agricultural Policies (MAFAP)
# Global Emissions Analysis for Resilient Systems (GEARS)

# Note: This is the script to import the Faostat emissions dataset.
# faostat_em_totals.csv is not in the data folder for 
# space considerations. 
# To download, visit: https://www.fao.org/faostat/en/#data/GT
# A leaner version in DuckDb format can be found in the 
# data folder of this repository at: 
# "data/faostat/faostat_em_totals.duckdb"

library(dplyr)
library(duckdb)
library(readr)

emissions <- read_csv(
  "gears_db/data/faostat/faostat_em_totals.csv", locale = locale(encoding = "latin1"))
area_codes <- read_csv(
  "data/faostat/faostat_area_codes.csv", locale = locale(encoding = "latin1"))
flags <- read_csv(
  "gears_db/data/faostat/faostat_flags.csv", locale = locale(encoding = "latin1"))

con <- dbConnect(
  duckdb(), 
  dbdir = "data/faostat/faostat_em_totals.duckdb", 
  read_only = FALSE)
dbWriteTable(con, "emissions", emissions, overwrite = T)
dbWriteTable(con, "flags", flags, overwrite = T)
dbWriteTable(con, "area_codes", area_codes, overwrite = T)
dbDisconnect(con)
