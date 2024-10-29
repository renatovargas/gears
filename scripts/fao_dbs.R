library(dplyr)
library(duckdb)
library(readr)

emissions <- read_csv(
  "data/faostat/faostat_em_totals.csv", locale = locale(encoding = "latin1"))
area_codes <- read_csv(
  "data/faostat/faostat_area_codes.csv", locale = locale(encoding = "latin1"))
flags <- read_csv(
  "data/faostat/faostat_flags.csv", locale = locale(encoding = "latin1"))

con <- dbConnect(
  duckdb(), 
  dbdir = "data/faostat/faostat_em_totals.duckdb", 
  read_only = FALSE)
dbWriteTable(con, "emissions", emissions, overwrite = T)
dbWriteTable(con, "flags", flags, overwrite = T)
dbWriteTable(con, "area_codes", area_codes, overwrite = T)
dbDisconnect(con)
