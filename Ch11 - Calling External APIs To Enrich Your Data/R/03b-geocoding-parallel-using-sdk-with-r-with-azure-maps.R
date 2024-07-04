# Bing Maps is being deprecated and retired (no new users).
# Azure Maps doesn't have an R package (compared to the Python SDK).
# To demonstrate {tidygeocoder}, this code uses the Nominatim/OpenStreetMap API:
# https://nominatim.org/

# Load necessary packages
library(dplyr)
library(furrr)
library(purrr)
library(readr)
library(tictoc)
library(tidygeocoder)

# Function to get geocode information from an address using the Nominatim/OpenStreetMap API
osm_geocode_via_address <- function(address) {
    
    details_tbl <- geo(address, method = "osm", full_results = TRUE) %>% 
        select(
            formattedAddress = address,
            lat,
            lng = long
        )
    
    return(details_tbl)
}

# Load the original CSV data containing addresses
tbl_orig <- read_csv(
    "<your-file-path>/geocoding_test_data.csv",
    locale = locale(encoding = "ISO-8859-1")
)

# Select relevant columns from the original data
tbl <- tbl_orig %>%
    select("full_address", "lat_true", "lon_true")

# Determine the number of virtual processors available
n_cores <- availableCores() - 1
plan(cluster, workers = n_cores)

# Start measuring the time for the geocoding process
tic()

# Use {furrr} to augment the original data for each of the addresses
tbl_enriched <- tbl %>%
    pull(full_address) %>% 
    future_map(~ osm_geocode_via_address(.x)) %>% 
    list_rbind() %>% 
    bind_cols(tbl, .)

# Stop measuring the time for the geocoding process
toc()

tbl_enriched

future:::ClusterRegistry("stop")