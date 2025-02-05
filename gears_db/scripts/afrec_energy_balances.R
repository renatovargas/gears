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

# Out of Biomass,			
# Fuelwood, Charcoal, Other vegetal and agricultural waste,
# do not count, towards the total from the published balance,
# while Solid biofuels does.


# Clean environment
rm(list = ls())

# Call libraries
library(tidyr)
library(dplyr)
library(readxl)
library(openxlsx)
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


series_clean <- series |>
  select(Id,
    Flow.category.code, 
    Flow.category.name.en,
    Flow.code,
    Flow.name.en,
    Product.category.code,
    Product.category.name.en,
    Product.code,
    Product.name.en,
    Stored.unit.code,
    Bold.Flow)

balances <- all_data |>
  select(-c(comment, source)) |> 
  left_join(series_clean, join_by(data_set_id == Id)) |> 
  filter(
    value_available == "Include",
    Stored.unit.code == "ktoe",
    ! Product.category.name.en %in% 
      c("Aggregate", 
        "Oil and oil products", 
        "Total"),
    ! Product.code %in% c("btc", "woc"),
    ! Flow.code %in% 
      c("dom", 
        "trf", 
        "trn", 
        "ino", 
        "cf"),
    Product.code != ""
  )


nigeria <- balances |> 
  filter(
    zone_code == "NGA",
    date == "1/1/2021"
  )

unique(balances$Flow.name.en)

e_flows_cats <- nigeria |> 
  select(
    Flow.category.code, 
    Flow.category.name.en,
    Flow.code, 
    Flow.name.en,
    # Product.category.code,
    Product.category.name.en,
    # Product.code,
    Product.name.en,
    value) |>
  group_by(
    Flow.category.code, 
    Flow.category.name.en,
    Flow.code, 
    Flow.name.en,
    # Product.category.code,
    Product.category.name.en,
    # Product.code,
    Product.name.en
  ) |> 
  summarize(
    Value = sum(value,na.rm = T)
  ) |>
  ungroup() #|> 
  # pivot_wider(
  #   names_from = c(Product.category.name.en, Product.name.en),
  #   values_from = Value,
  #   values_fill = 0,
  #   names_sort = T
  # )

balance_to_seea <- read_xlsx(
  "gears_db/data/classifications/classifications.xlsx",
  sheet = "balance_to_seea")

e_flows_cats2 <- e_flows_cats |> 
  left_join(
    balance_to_seea[,c(2:9)],
    join_by(Flow.name.en)) |> 
  mutate(
    value_seea = if_else(
      !is.na(Value) & Flow.code %in% c("exp","bua", "bum","sto","tfs"), Value * (-1), Value
    ),
    transaction.code = if_else(
      Flow.category.code == "tr" & !is.na(Value) & Value > 0, "P1", transaction.code
    ),
    transaction = if_else(
      Flow.category.code == "tr" & !is.na(Value) & Value > 0, "Output", transaction
    ),
    sut.code = if_else(
      Flow.category.code == "tr" & !is.na(Value) & Value > 0, 1, sut.code
    ),
    sut = if_else(
      Flow.category.code == "tr" & !is.na(Value) & Value > 0, "Supply", sut
    )
  ) |> 
  mutate(
    value_seea = if_else(
      Flow.category.code == "tr" & !is.na(Value) & Value <= 0, value_seea * (-1), value_seea
    )
  )
  

saveRDS(e_flows_cats2, file="gears_db/data/afrec/nga_2018.RDS") 

write.xlsx(
  e_flows_cats, 
  "gears_db/data/classifications/test_balance.xlsx",
  overwrite = T,
  rowNames = F)

write.xlsx(
  e_flows_cats2, 
  "gears_db/data/classifications/test_balance2.xlsx",
  overwrite = T,
  rowNames = F)
