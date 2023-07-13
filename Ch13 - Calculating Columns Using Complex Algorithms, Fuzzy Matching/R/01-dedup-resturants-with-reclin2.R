library(readr)
library(reclin2)
library(dplyr)


main_path <- r"{C:\<your path>\Ch13 - Calculating Columns Using Complex Algorithms, Fuzzy Matching}"

restaurants_df <- read_csv(file.path(main_path, "restaurants.csv"))

head(restaurants_df)

pairs <- 
  pair_minsim(restaurants_df, deduplication = TRUE, on = "city",
                     comparators = list(lcs(threshold = 0.7),
                                        jaro_winkler(threshold = 0.7)),
                     minsim = 0.7, keep_simsum = TRUE)
  
  # pair_blocking(restaurants_df, on = "city", deduplication = TRUE)

print(pairs)

compare_pairs(pairs, on = c("name", "addr", "city"),
              comparators = list(jaro_winkler(threshold = 0.9),
                                 jaro_winkler(threshold = 0.8),
                                 jaccard(threshold = 0.7)),
              default_comparator = jaro_winkler(threshold = 0.9),
              inplace = TRUE)

print(pairs)


m <- problink_em(~ name + addr, data = pairs)

print(m)


pairs <- predict(m, pairs = pairs, add = TRUE)

print(pairs)



pairs <- select_threshold(pairs, variable = "match",
                          score = "weights", threshold = 3)

pairs %>% filter(match == TRUE)


truth_src <- restaurants_df %>% 
  inner_join(restaurants_df, by = "class", suffix = c("", "_y")) %>% 
  filter( (id != id_y) ) %>% 
  select( id_x = id, id_y ) %>% 
  mutate( id = row_number() )

truth <- truth_src %>% 
  inner_join(truth_src, by = join_by(id_x == id_y, id_y == id_x)) %>% 
  filter( id.x < id.y ) %>% 
  mutate( id_x = id_x + 1,
          id_y = id_y + 1,
          truth = TRUE ) %>% 
  select( id_x, id_y, truth )


pairs <- pairs %>% 
  left_join( truth, by = join_by(.x == id_x, .y == id_y) ) %>% 
  mutate( truth = ifelse( is.na(truth), FALSE, truth) )


table(pairs$truth, pairs$match, dnn = c("Truth", "Matched"))

