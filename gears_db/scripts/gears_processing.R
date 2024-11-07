# Food and Agriculture Organization of the United Nations (FAO)
# Agrifood Economics and Policy Division (ESA)
# Monitoring and Analysing Food and Agricultural Policies (MAFAP)
# Global Emissions Analysis for Resilient Systems (GEARS)

# Author: Renato Vargas (hugo.vargasaldana@fao.org)

# Data Processing

# Main objective: Process raw data into structured schema.


# Afrec Energy Balances
# Connect to DuckDB database

# Preamble

# Clean environment
rm(list = ls())

# Call libraries
library(duckdb)
library(dplyr)


# Connect to energy balances database
con <- dbConnect(
  duckdb(),
  dbdir = "gears_db/data/afrec_energy_balances.duckdb", 
  read_only = T
)

# List all tables
dbGetQuery(con, "SHOW TABLES")

# We get a view of each table
tbl(con, "all_data") |> 
  head()

tbl(con, "series") |> 
  head()
# We see that series has a lot of columns
tbl(con, "series") |> 
  colnames()

dbDisconnect(con)
