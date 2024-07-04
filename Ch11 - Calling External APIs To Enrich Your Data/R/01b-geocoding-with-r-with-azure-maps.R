###############################################################################
# Azure Maps documentation: https://learn.microsoft.com/en-us/azure/azure-maps/
###############################################################################
# Azure Maps API Key to be set up separately for security reasons
###############################################################################
# Sys.setenv(.AZURE_MAPS_API_KEY = "<your-api-key>")
###############################################################################

# Load necessary packages
library(dplyr)
library(httr)
library(jsonlite)
library(purrr)
library(RCurl)
library(readr)
library(stringr)
library(tictoc)

# Set base URL for Azure Maps API
base_url <- "https://atlas.microsoft.com/search/address/json"

# Function to get geocode information from an address using Azure Maps API
azure_maps_geocode_via_address <- function(address) {
    
    # Encode the address to make it URL-safe
    encoded_address <- curlPercentEncode(address)
    
    # Construct the full URL with the encoded address and API key
    full_url        <- str_glue("{base_url}?&subscription-key={.AZURE_MAPS_API_KEY}&query={encoded_address}")
    
    # Send GET request to the API
    r               <- GET(full_url)
    
    # Parse the response content as text
    details_content <- content(r, "text", encoding = "UTF-8")
    
    # Check if the response status code is 200 (OK)
    if (r$status_code == 200) {
        
        # Try to parse the JSON response
        details_tbl <- tryCatch({
            
            details_json  <- fromJSON(details_content)
            
            num_resources <- details_json %>% pluck("summary", "numResults")
            
            # If resources are found, extract relevant details
            if (num_resources > 0) {
                details_tbl <- tibble(
                    num_of_resources  = num_resources,
                    formatted_address = details_json %>% pluck("results", "address", "freeformAddress", 1),
                    lat               = details_json %>% pluck("results", "position", "lat", 1),
                    lng               = details_json %>% pluck("results", "position", "lon", 1),
                    statusCode        = r %>% pluck("status_code"),
                    text              = details_content,
                    url               = r %>% pluck("url")
                )
                
            # If no resources are found, add 0s and NAs
            } else {
                details_tbl <- tibble(
                    num_of_resources  = 0,
                    formatted_address = NA,
                    lat               = NA,
                    lng               = NA,
                    statusCode        = r %>% pluck("status_code"),
                    text              = details_content,
                    url               = r %>% pluck("url")
                )
            }
            
        # Handle errors during JSON parsing
        }, error = function(err) {
            
            details_tbl <- tibble(
                num_of_resources  = 0,
                formatted_address = NA,
                lat               = NA,
                lng               = NA,
                statusCode        = r %>% pluck("status_code"),
                text              = details_content,
                url               = r %>% pluck("url")
            )
            
            # Return the details table
            return(details_tbl)
            
        })
        
    # If the response status code is not 200, add 0s and NAs
    } else {
        
        details_tbl <- tibble(
            num_of_resources  = 0,
            formatted_address = NA,
            lat               = NA,
            lng               = NA,
            statusCode        = r %>% pluck("status_code"),
            text              = details_content,
            url               = r %>% pluck("url")
        )
        
    }
    
    # Return the details table
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

# Start measuring the time for the geocoding process
tic()

# Use {purrr} to augment the original data for each of the addresses
tbl_enriched <- tbl %>%
    pull(full_address) %>%
    map(~ azure_maps_geocode_via_address(.x)) %>% 
    list_rbind() %>% 
    bind_cols(tbl, .)

# Stop measuring the time for the geocoding process
toc()
