library(reclin2)
library(dplyr)


restaurants_df <- dataset

pairs <- 
  pair_minsim(restaurants_df, deduplication = TRUE, on = "city",
              comparators = list(lcs(threshold = 0.7),
                                 jaro_winkler(threshold = 0.7)),
              minsim = 0.7, keep_simsum = TRUE)

compare_pairs(pairs, on = c("name", "addr", "city"),
              comparators = list(jaro_winkler(threshold = 0.9),
                                 jaro_winkler(threshold = 0.8),
                                 jaccard(threshold = 0.7)),
              default_comparator = jaro_winkler(threshold = 0.9),
              inplace = TRUE)

m <- problink_em(~ name + addr, data = pairs)

pairs <- predict(m, pairs = pairs, add = TRUE)

select_threshold(pairs, variable = "match",
                 score = "weights", threshold = 3, inplace = TRUE)

restaurants_dedup_df <- restaurants_df %>% 
  filter( !(id+1) %in% (pairs %>% filter(match == TRUE) %>% pull(.y)) )

rm(m)
rm(pairs)
