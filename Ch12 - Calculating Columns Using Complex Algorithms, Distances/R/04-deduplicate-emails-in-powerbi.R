library(dplyr)
library(stringdist)

deduplicate_data <- function(data, similarity_method, p=0.1, q=1, similarity_threshold=0.8) {
  
  new_columns <- c(colnames(data), "Best Comparison", "Similarity")
  
  # Create new data frames to store deduplicated and duplicated records
  deduplicated_data <- tibble::tibble(!!!setNames(rep(list(NULL), length(new_columns)), new_columns))
  duplicated_data <- tibble::tibble(!!!setNames(rep(list(NULL), length(new_columns)), new_columns))
  
  colnames(deduplicated_data) <- new_columns
  colnames(duplicated_data) <- new_columns
  
  # Create a vector to keep track of unique emails
  unique_emails <- c()
  
  # Iterate through each row in the original dataset
  for (i in 1:nrow(data)) {
    email <- data$Email[i]
    is_duplicate <- FALSE
    best_comparison <- ''
    best_similarity_score <- 0.0
    
    # Compare the current email with unique emails using the chosen similarity metric
    for (unique_email in unique_emails) {
      if (similarity_method == 'jw') {
        
        similarity_score <- stringsim(email, unique_email, method = similarity_method, q = q, p = p)  
        
      } else {
        
        similarity_score <- stringsim(email, unique_email, method = similarity_method, q = q)  
        
      }
      
      
      # If the similarity score exceeds the threshold, consider it a duplicate
      if (similarity_score > similarity_threshold) {
        is_duplicate <- TRUE
        
        row_to_append <- data[i, ]
        row_to_append['Best Comparison'] <- unique_email
        row_to_append['Similarity'] <- similarity_score
        
        duplicated_data <- bind_rows(duplicated_data, row_to_append)
        break
      }
      
      if (similarity_score > best_similarity_score) {
        best_similarity_score <- similarity_score
        best_comparison <- unique_email
      }
    }
    
    # If it's not a duplicate, add it to the deduplicated dataset
    if (!is_duplicate) {
      unique_emails <- c(unique_emails, email)
      
      row_to_append <- data[i, ]
      row_to_append['Best Comparison'] <- best_comparison
      row_to_append['Similarity'] <- best_similarity_score
      
      deduplicated_data <- bind_rows(deduplicated_data, row_to_append)
    }
    
  }
  
  if (length(deduplicated_data) > 0)
    deduplicated_data <- deduplicated_data %>% arrange(Name)
  
  if (length(duplicated_data) > 0)
    duplicated_data <- duplicated_data %>% arrange(Name)
  
  # Return datasets
  return( list(deduplicated_data=deduplicated_data, duplicated_data=duplicated_data) )
}

deduplicated_data_jaccard_3grams <- deduplicate_data(dataset, similarity_method = "jaccard", q = 3, similarity_threshold = 0.55)

deduplicated_data_jaccard_3grams_df = deduplicated_data_jaccard_3grams[[1]]
