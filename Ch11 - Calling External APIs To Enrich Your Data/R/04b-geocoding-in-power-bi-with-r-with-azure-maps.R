###############################################################################
# Azure Maps documentation: https://learn.microsoft.com/en-us/azure/azure-maps/
###############################################################################
# Azure Maps API Key to be set up separately for security reasons
###############################################################################
# Sys.setenv(.AZURE_MAPS_API_KEY = "<your-api-key>")
###############################################################################

library(dplyr)
library(httr)
library(jsonlite)
library(purrr)
library(RCurl)
library(readr)
library(stringr)

base_url <- "https://atlas.microsoft.com/search/address/json"

azure_maps_geocode_via_address <- function(address) {
    
    encoded_address <- curlPercentEncode(address)
    full_url        <- str_glue("{base_url}?&subscription-key={.AZURE_MAPS_API_KEY}&query={encoded_address}")
    r               <- GET(full_url)
    details_content <- content(r, "text", encoding = "UTF-8")
    
    if (r$status_code == 200) {
        
        details_tbl <- tryCatch({
            
            details_json <- fromJSON(details_content)
            
            num_resources <- details_json %>% pluck("summary", "numResults")
            
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
            
            return(details_tbl)
            
        })
        
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
    
    return(details_tbl)
}

tbl_orig <- read_csv(
    "<your-file-path>/geocoding_test_data.csv",
    locale = locale(encoding = "ISO-8859-1")
)

tbl <- tbl_orig %>%
    select("full_address", "lat_true", "lon_true")

tbl_enriched <- tbl %>%
    pull(full_address) %>%
    map(~ azure_maps_geocode_via_address(.x)) %>% 
    list_rbind() %>% 
    bind_cols(tbl, .)
