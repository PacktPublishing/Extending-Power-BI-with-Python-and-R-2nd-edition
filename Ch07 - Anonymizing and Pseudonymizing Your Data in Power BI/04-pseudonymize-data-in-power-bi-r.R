
library(stringr)
library(spacyr)
library(dplyr)
library(purrr)
library(charlatan)

####### WARNING #######
# 
# Starting from the version 0.6.0, the charlatan library has introuced distinct classes,
# like InternetProvider_en_US, to handle locale-specific functionality.
#
# Here some examples:
# https://cran.r-project.org/web/packages/charlatan/vignettes/creating-realistic-data.html#Protected_health_information
#
# Note that not all the providers are implemented for all the locales. For example, there is no InternetProvider_it_IT,
# so you're forced to use a different locale. 

anonymizeEmails <- function(text_to_anonymize, country) {
  
  locale <- faker_locales_dict[[country]]
  
  matched_results <- spacy_parse(text_to_anonymize, pos = TRUE, additional_attributes = c("like_email")) %>%
    filter( like_email == TRUE ) %>% 
    pull(token)
  
  matched_emails <- list()
  for (email in matched_results) {
    
    if (!email %in% names(emails_lst)) {
      
	  # The following row of code won't work if you are using charlatan >= 0.6.1
      # In that case, use this code:
      #
      #     fake_email <- InternetProvider_en_US$new()$email()
      #
      # Change the class according to your specific locale. Keep in mind that the current code falls back to en_US
	  # in case the locale hasn't be implemented for that provider. So, the default locale in case of
	  # ITALY as country will be en_US. The same logic could be implemented for charlatan >= 0.6.1 using the
	  # locale-specific providers.
			
      fake_email <- InternetProvider$new(locale = locale)$email()
      
      while ( (fake_email %in% emails_lst) | (fake_email %in% names(emails_lst)) ) {
        fake_email <- InternetProvider$new(locale = locale)$email()
      }
      
      emails_lst[email] <- fake_email
      matched_emails[email] <- fake_email
      
    } else {
      
      fake_email <- emails_lst[[email]]
      matched_emails[email] <- fake_email
      
    }
  }
  
  anonymized_result <- text_to_anonymize
  
  for (email in names(matched_emails)) {
    anonymized_result <- str_replace(anonymized_result, email, matched_emails[[email]])
  }
  
  return(anonymized_result)
  
}


anonymizeNames <- function(text_to_anonymize, country) {
  
  locale <- faker_locales_dict[[country]]
  
  matched_patterns <- spacy_parse(text_to_anonymize, pos = TRUE, entity = TRUE) %>% 
    entity_consolidate(concatenator = " ") %>% 
    filter( entity_type == "PERSON" ) %>% 
    mutate( pattern = str_replace(token, pattern = r"{^([^\s]+).*?([^\s]+)$}", replacement = r"{\1.*?\2}") ) %>% 
    pull(pattern)
  
  matched_results <- str_match_all(text_to_anonymize, matched_patterns) %>% 
    map_chr( ~ .x[1,1] )
  
  matched_names <- list()
  for (name in matched_results) {
    
    if (!name %in% names(names_lst)) {
      
      fake_name <-  ch_name(n = 1, locale = locale)
      
      while ( (fake_name %in% names_lst) | (fake_name %in% names(names_lst)) ) {
        fake_name <- ch_name(n = 1, locale = locale)
      }
      
      names_lst[name] <- fake_name
      matched_names[name] <- fake_name
      
    } else {
      
      fake_name <- names_lst[[name]]
      matched_names[name] <- fake_name
      
    }
  }
  
  anonymized_result <- text_to_anonymize
  
  for (name in names(matched_names)) {
    anonymized_result <- str_replace(anonymized_result, name, matched_names[[name]])
  }
  
  return(anonymized_result)
  
}


# In case of new versions of spacy, spacy_initialize has changed and you have to set the environment
# using sys.setenv and make sure you have the language model installed using spacy_install()
#
#    Sys.setenv(SPACY_PYTHON = "C:/ProgramData/Miniconda3/envs/presidio_env")
#
#    spacy_install(lang_models = "en_core_web_lg")
#    spacy_initialize(
#        model = "en_core_web_lg",
#        entity = TRUE
#    )
#
# (thanks to Antti Rask)

spacy_initialize(
  model = "en_core_web_lg",
  condaenv = r"{C:\ProgramData\Miniconda3\envs\presidio_env}",
  entity = TRUE
)

# Define locale and language dictionaries
faker_locales_dict <- list(
  'UNITED STATES' = 'en_US', 'ITALY' = 'it_IT', 'GERMANY' = 'de_DE'
)

# Load mapping lists from RDS files if they exist, otherwise create empty lists
rds_path <- r'{D:\<your-path>\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch07 - Anonymizing and Pseudonymizing Your Data in Power BI\RDSs}'

emails_list_rds_path <- file.path(rds_path, 'emails_list.rds')
names_list_rds_path <- file.path(rds_path , 'names_list.rds')

if (file.exists(emails_list_rds_path)){
  emails_lst <- readRDS(emails_list_rds_path)
} else {
  emails_lst <- list()
}

if (file.exists(names_list_rds_path)){
  names_lst <- readRDS(names_list_rds_path)
} else {
  names_lst <- list()
}


# For testing purpose you can load the Excel content directly here
# # Load the Excel content in a dataframe
# library(readxl)
# dataset <- read_xlsx(r"{D:\<your-path>\Chapter06\CustomersCreditCardAttempts.xlsx}")

df <- dataset

# Since we are using two arguments, we need to use map2_chr instead of map_chr. Notice that we also added .y to the 
# anonymizeNames() and anonymizeEmails() functions for the same reason (thanks to Antti Rask).

df <- df %>% 
  mutate(
    Name  = map2_chr(Name,  Country, .f = ~ anonymizeNames(.x, .y)),
    Email = map2_chr(Email, Country, .f = ~ anonymizeEmails(.x, .y)),
    Notes = map2_chr(Notes, Country, .f = ~ anonymizeEmails(.x, .y))
  ) %>% 
  mutate(
    Notes = map2_chr(Notes, Country, .f = ~ anonymizeNames(.x, .y))
  )


# # Show both the dataframes
# dataset
# df

# Write emails and names lists to RDS files
saveRDS(emails_lst, emails_list_rds_path)
saveRDS(names_lst, names_list_rds_path)
