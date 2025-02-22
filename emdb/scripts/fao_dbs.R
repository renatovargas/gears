# Food and Agriculture Organization of the United Nations (FAO)
# Agrifood Economics and Policy Division (ESA)
# Monitoring and Analysing Food and Agricultural Policies (MAFAP)
# Global Emissions Analysis for Resilient Systems (GEARS)

# Note: This is the script to import the Faostat emissions dataset.
# faostat_em_totals.csv is not in the data folder for 
# space considerations. 
# To download, visit: https://www.fao.org/faostat/en/#data/GT

library(dplyr)
library(tidyr)
library(readr)
library(forcats)

rm(list = ls())

# total_emissions <- read_csv(
#   "emdb/data/faostat/faostat_em_totals.csv",
#   locale = locale(encoding = "latin1"))
# crops <- read_csv(
#   "D:/OneDrive/_WORK/2024-03-FAO/materials/FAOSTAT/Emissions_crops_E_All_Data_(Normalized)/Emissions_crops_E_All_Data_(Normalized).csv",
#   locale = locale(encoding = "utf8")) |>
#   mutate_if(is.character, factor)
# livestock <- read_csv(
#   "D:/OneDrive/_WORK/2024-03-FAO/materials/FAOSTAT/Emissions_livestock_E_All_Data_(Normalized)/Emissions_livestock_E_All_Data_(Normalized).csv",
#   locale = locale(encoding = "utf8")) |>
#   mutate_if(is.character, factor)
# drained_organic_soils <- read_csv(
#     "D:/OneDrive/_WORK/2024-03-FAO/materials/FAOSTAT/Emissions_Drained_Organic_Soils_E_All_Data_(Normalized)/Emissions_Drained_Organic_Soils_E_All_Data_(Normalized).csv",
#     locale = locale(encoding = "utf8")) |>
#     mutate_if(is.character, factor)
# area_codes <- read_csv(
#   "emdb/data/faostat/faostat_area_codes.csv",
#   locale = locale(encoding = "latin1"))
# flags <- read_csv(
#   "emdb/data/faostat/faostat_flags.csv",
#   locale = locale(encoding = "latin1"))
# production <- read_csv(
#   "D:/OneDrive/_WORK/2024-03-FAO/materials/FAOSTAT/Production_Crops_Livestock_E_All_Data_(Normalized)/Production_Crops_Livestock_E_All_Data_(Normalized).csv",
#   locale = locale(encoding = "utf8")) |>
#   mutate_if(is.character, factor)
# saveRDS(total_emissions,"emdb/data/faostat/total_emissions.rds")
# saveRDS(crops,"emdb/data/faostat/crops.rds")
# saveRDS(drained_organic_soils,"emdb/data/faostat/drained_organic_soils.rds")
# saveRDS(flags,"emdb/data/faostat/flags.rds")
# saveRDS(livestock,"emdb/data/faostat/livestock.rds")
# saveRDS(production,"emdb/data/faostat/production.rds")
# saveRDS(area_codes,"emdb/data/faostat/area_codes.rds")
# save.image("emdb/data/faostat/faostat.RData" )
# load("emdb/data/faostat/faostat.RData")

total_emissions <- readRDS("emdb/data/faostat/total_emissions.rds") |> 
  mutate(across(where(is.character), as.factor))
crops <- readRDS("emdb/data/faostat/crops.rds") |> 
  mutate(across(where(is.character), as.factor))
drained_organic_soils <- readRDS("emdb/data/faostat/drained_organic_soils.rds") |> 
  mutate(across(where(is.character), as.factor))
flags <- readRDS("emdb/data/faostat/flags.rds") |> 
  mutate(across(where(is.character), as.factor))
livestock <- readRDS("emdb/data/faostat/livestock.rds") |> 
  mutate(across(where(is.character), as.factor))
production <- readRDS("emdb/data/faostat/production.rds") |> 
  mutate(across(where(is.character), as.factor))
area_codes <- readRDS("emdb/data/faostat/area_codes.rds") |> 
  mutate(across(where(is.character), as.factor))
elements <- unique(total_emissions$Element)
items <- unique(total_emissions$Item)

nigeria_production <- production |> 
  filter(
    Year == 2018,
    Area == "Nigeria",
    `Element Code` == "5312"
  )

nigeria <- total_emissions |> 
  filter(
    Year == 2018,
         Area == "Nigeria",
         `Item Code` %in% c(
           5064,  5060, 5066, 
           5058,  5059, 5063, 
           5062,  5061, 67292, 
           67291, 6751, 6750, 
           6795,  6993, 6992
           # 1711,1707 # Totals IPCC Agriculture, LULUCF
         ),
         Element %in% c(elements[c(4,7,8,9)]),
         # Element == elements[5],
         )
  
agriculture_factors <- c(
  "a-maize",
  "a-sorghum_millet",
  "a-rice",
  "a-wheat",
  "a-ocereals",
  "a-pulses",
  "a-groundnuts",
  "a-ooilseeds",
  "a-cassava",
  "a-irishpotatoes",
  "a-sweetpotatoes",
  "a-oroots",
  "a-leafyveget",
  "a-oveget",
  "a-sugarcane",
  "a-tobacco",
  "a-cotton",
  "a-nuts",
  "a-bananas",
  "a-ofruits",
  "a-tea",
  "a-coffee",
  "a-cocoa",
  "a-flowers",
  "a-rubber",
  "a-ocrops"
)

sam_equivalent_crops <- data.frame(
  Item = c(
    "Rice", 
    "Maize (corn)", 
    "Sugar cane", 
    "Wheat", 
    "Millet", 
    "Potatoes", 
    "Sorghum", 
    "Soya beans"
  ),
  sam_a = c(
    "a-rice", 
    "a-maize", 
    "a-sugarcane", 
    "a-wheat", 
    "a-sorghum_millet", 
    "a-irishpotatoes", 
    "a-sorghum_millet", 
    "a-pulses"
  )) |> 
  mutate(
    sam_a = factor(
      sam_a,
      levels = agriculture_factors
    )
  )
  


nigeria_crops <- crops |> 
  filter(
    Year == 2018,
    Area == "Nigeria",
    ! `Element Code` %in% c(
      5162, 516201, 516202,
      7245, 72430, 72440,
      72342, 72362,
      723631, 723632, 72392
    ),
    # ! Item %in% c(
    #   "Nutrient nitrogen N (total)",
    #   "All Crops"
    # )
    )|> 
  left_join(
    sam_equivalent_crops,
    join_by(
      Item
    )
  ) |> 
  group_by(
    `Element Code`,
    Element,
    Item,
    # sam_a,
    Unit
  ) |> 
  summarize(
    Total = sum(Value, na.rm = T)
  ) |> 
  ungroup() |> 
  pivot_wider(
    names_from = Item,
    id_cols = c(
      `Element Code`,
      `Element`,
      `Unit`,
    ),
    values_from = Total,
    values_fill = 0,
    names_expand = T
  )

sam_equivalents <- data.frame(
  Item = c(
    "Asses", "Camels", 
    "Cattle, dairy", 
    "Cattle, non-dairy", 
    "Chickens, broilers", 
    "Chickens, layers", 
    "Goats", "Horses", 
    "Sheep", "Swine, breeding", 
    "Swine, market"
  ),
  sam_a = c(
    "a-olivestock", "a-olivestock", 
    "a-rawmilk", "a-cattle", 
    "a-poultry", "a-eggs", 
    "a-smallruminants", "a-olivestock", 
    "a-smallruminants", "a-olivestock", 
    "a-olivestock"
  )
)

sam_equivalent_crops <- sam_equivalent_crops |> 
  mutate(
    sam_a = factor(
      sam_a,
      levels = agriculture_factors
    )
  )

animal_factors <- c(
  "a-cattle", "a-rawmilk", 
  "a-poultry", "a-eggs", 
  "a-smallruminants", "a-olivestock"
)

sam_equivalents <- sam_equivalents |> 
  mutate(
    sam_a = factor(
      sam_a,
      levels = animal_factors
    )
  )

nigeria_livestock <- livestock |> 
  filter(
    Year == 2018,
    Area == "Nigeria",
    ! `Element Code` %in% c(
      72380,  72381, 72386, 
      723601, 723602, 723611, 
      723612, 723801, 723802, 
      723811, 723812, 72340, 
      72341, 72346, 72360, 
      72361, 72366, 72431,
      72441
    ),
    ! `Item Code` %in% c(
      1757, 1759, 1760,
      1054, 2029, 1749,
      1048, 1755
    ))|>
  left_join(
    sam_equivalents,
    join_by(Item)
  ) |> 
  group_by(
    `Element Code`,
    Element,
    # Item,
    sam_a,
    Unit
  ) |> 
  summarize(
    Total = sum(Value, na.rm = T)
  ) |> 
  ungroup() |> 
  pivot_wider(
    names_from = `sam_a`,
    id_cols = c(
      `Element Code`,
      `Element`,
      `Unit`,
    ),
    values_from = Total,
    values_fill = 0
  )

# Drained organic soils

nigeria_organic_soils <- drained_organic_soils |> 
  filter(
    Year == 2018,
    Area == "Nigeria"
  )

write.table(nigeria, "clipboard", sep = "\t", row.names = F)
write.table(nigeria_crops, "clipboard", sep = "\t", row.names = F)
write.table(nigeria_livestock, "clipboard", sep = "\t", row.names = F)

item1 <- as.matrix(unique(crops$`Element Code`))
item2 <- as.matrix(unique(crops$Element))
items <- cbind(item1,item2)


# Duck DB
# con <- dbConnect(
#   duckdb(), 
#   dbdir = "emdb/data/faostat/faostat_em_totals.duckdb", 
#   read_only = FALSE)
# dbWriteTable(con, "emissions", emissions, overwrite = T)
# dbWriteTable(con, "flags", flags, overwrite = T)
# dbWriteTable(con, "area_codes", area_codes, overwrite = T)
# dbDisconnect(con)