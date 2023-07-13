
library(dplyr)
library(tidyr)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)


n_warehouses <- shipping_cost_df %>% 
  distinct(warehouse_name) %>% 
  count() %>% 
  pull(n)
n_countries <- shipping_cost_df %>% 
  distinct(country_name) %>% 
  count() %>% 
  pull(n)

warehouse_supply <- warehouse_supply_df %>% 
  pull(product_qty)
country_demands <- country_demands_df %>% 
  pull(product_qty)
cost_matrix <- data.matrix(
  shipping_cost_df %>% 
    pivot_wider( names_from = country_name, values_from = shipping_cost ) %>% 
    select( -warehouse_name )
)
rownames(cost_matrix) <- warehouse_supply_df %>% pull(warehouse_name)


model <- MIPModel() %>% 
    add_variable( x[i, j], i = 1:n_warehouses, j = 1:n_countries, type = "integer", lb = 0 ) %>% 
    set_objective( sum_expr(cost_matrix[i, j] * x[i, j], i = 1:n_warehouses, j = 1:n_countries), sense = 'min' ) %>% 
    add_constraint( sum_expr(x[i, j], j = 1:n_countries) <= warehouse_supply[i], i = 1:n_warehouses ) %>% 
    add_constraint( sum_expr(x[i, j], i = 1:n_warehouses) >= country_demands[j], j = 1:n_countries )

result <- model %>% 
    solve_model(with_ROI(solver = 'glpk'))



countries <- colnames(cost_matrix)
warehouses <- rownames(cost_matrix)


decision_var_results <- result$solution[ sort(names(result$solution)) ]

result_df <- data.frame(
    warehouse_name = rep(warehouses, each=n_countries),
    country_name = rep(countries, times=n_warehouses),
    shipped_qty = decision_var_results,
    cost = as.vector(t(cost_matrix)) * decision_var_results
)

