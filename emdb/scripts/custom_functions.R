library(tidyverse)

# Recursive function with direct naming of outputs
transform_edgar_datasets <- function(datasets, dataset_names) {
  if (length(datasets) == 0) {
    return(invisible(NULL)) # End recursion
  }
  if(length(datasets)== 1){
    print("The transformed datasets have the prefix 'transformed_'")
  }
  # Process the first dataset
  dataset <- datasets[[1]]
  name <- dataset_names[[1]]
  
  # Apply the transformation
  transformed <- dataset |> 
    filter(grepl("^(1|2|4|5)", ipcc_code_2006_for_standard_report)) |> 
    pivot_longer(
      cols = starts_with("Y_"),
      names_to = "Year",
      values_to= "Value"
    ) |> 
    mutate(
      Year = as.numeric(sub("^Y_", "", Year))
    )
  
  # Assign the transformed dataset to the global environment
  assign(paste0("transformed_", name), transformed, envir = .GlobalEnv)
  
  # Recur with the rest of the datasets
  transform_edgar_datasets(datasets[-1], dataset_names[-1])
}
