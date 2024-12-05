rm(list = ls())

# Call libraries
library(tidyr)
library(dplyr)
library(duckdb)
library(readxl)
library(openxlsx)

edgar <- read_xlsx(
  "gears_db/data/edgar/EDGAR_AR5_GHG_1970_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_c02 <- read_xlsx(
  "gears_db/data/edgar/IEA_EDGAR_CO2_1970_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_co02bio  <- read_xlsx(
  "gears_db/data/edgar/EDGAR_CO2bio_1970_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_ch4 <- read_xlsx(
  "gears_db/data/edgar/EDGAR_CH4_1970_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_n2o <- read_xlsx(
  "gears_db/data/edgar/EDGAR_N2O_1970_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_f_gases <- read_xlsx(
  "gears_db/data/edgar/EDGAR_AR5g_F-gases_1990_2023.xlsx",
  skip = 9,
  sheet = "IPCC 2006")

edgar_ipcc_names <- data.frame(code = unique(edgar$ipcc_code_2006_for_standard_report),
                               ipcc_name = unique(edgar$ipcc_code_2006_for_standard_report_name))
nga_all <- edgar |> 
  filter(Name == "Nigeria") |> 
  select(c(5, 6, 7, 8, 57))


nga_c02 <- edgar_c02 |> 
  filter(Name == "Nigeria",
         startsWith(ipcc_code_2006_for_standard_report,"2") |
           startsWith(ipcc_code_2006_for_standard_report,"4")|
           startsWith(ipcc_code_2006_for_standard_report,"5")
         ) |> 
  select(c(5, 6, 7, 8, 57))

# nga_co2bio <- edgar_co02bio |> 
#   filter(Name == "Nigeria",
#          startsWith(ipcc_code_2006_for_standard_report,"2") |
#            startsWith(ipcc_code_2006_for_standard_report,"4")
#   ) |> 
#   select(c(5, 6, 7, 8, 57))

nga_ch4 <- edgar_ch4 |> 
  filter(Name == "Nigeria",
         startsWith(ipcc_code_2006_for_standard_report,"2") |
           startsWith(ipcc_code_2006_for_standard_report,"4") |
           startsWith(ipcc_code_2006_for_standard_report,"5")
  ) |> 
  select(c(5, 6, 7, 8, 57)) |> 
  mutate(
    Y_2018 = Y_2018 * 28 # GWP AR5 100-year horizon
  )

nga_n2o <- edgar_n2o |> 
  filter(Name == "Nigeria",
         startsWith(ipcc_code_2006_for_standard_report,"2") |
           startsWith(ipcc_code_2006_for_standard_report,"4") |
           startsWith(ipcc_code_2006_for_standard_report,"5")
  ) |> 
  select(c(5, 6, 7, 8, 57)) |> 
  mutate(
    Y_2018 = Y_2018 * 265 # GWP AR5 100-year horizon
  )

nga_f_gases <- edgar_f_gases |> 
  filter(Name == "Nigeria",
         # startsWith(ipcc_code_2006_for_standard_report,"2") |
         #   startsWith(ipcc_code_2006_for_standard_report,"4")
  ) |> 
  select(c(5, 6, 7, 8, 37)) |> 
  mutate(
    Y_2018 = if_else(is.na(Y_2018), 0, Y_2018)
  )

nga_total <- rbind(
  nga_c02,
  nga_ch4,
  nga_n2o,
  nga_f_gases
)


write.table(nga_total, "clipboard", sep = "\t", row.names = F)

