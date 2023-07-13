import re

from splink.duckdb.linker import DuckDBLinker
from splink.duckdb.comparison_template_library import name_comparison
import splink.duckdb.comparison_library as cl

def clean_string(input_string):
    # Convert to lower case
    cleaned_string = input_string.lower()
    
    # Remove trailing spaces
    cleaned_string = cleaned_string.strip()
    
    # Remove special characters
    cleaned_string = re.sub(r'[^a-zA-Z0-9\s]', '', cleaned_string)
    
    return cleaned_string


restaurants_df = dataset

restaurants_df["name"] = restaurants_df["name"].apply(lambda x: clean_string(x))
restaurants_df["addr"] = restaurants_df["addr"].apply(lambda x: clean_string(x))
restaurants_df["city"] = restaurants_df["city"].apply(lambda x: clean_string(x))

settings = {
    "link_type": "dedupe_only",
    "blocking_rules_to_generate_predictions": [
       "l.name = r.name and l.addr = r.addr",
       "l.name = r.name and l.city = r.city",
       "l.name LIKE CONCAT('%',r.name,'%') or r.name LIKE CONCAT('%',l.name,'%')",
    ],
    "comparisons": [
        name_comparison("name", jaro_winkler_thresholds=[0.9, 0.8]),
        name_comparison("addr", jaro_winkler_thresholds=[0.9, 0.8]),
        cl.exact_match("city"),
    ],
    "unique_id_column_name": "id",
    "retain_matching_columns": True,
    "retain_intermediate_calculation_columns": True,
    "max_iterations": 10,
    "em_convergence": 0.0001     
}

linker = DuckDBLinker(restaurants_df, settings)

linker.estimate_u_using_random_sampling(max_pairs=1e6)

training_blocking_rule = "l.name = r.name and l.addr = r.addr"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

training_blocking_rule = "l.name = r.name and l.city = r.city"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

training_blocking_rule = "l.city = r.city and l.addr = r.addr"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

df_predict = linker.predict()

matches_df = df_predict.as_pandas_dataframe()
matches_df = matches_df.drop(columns=['match_key']).drop_duplicates().query('match_weight >= 0')

duplicates_ids = matches_df['id_r']

restaurants_dedup_df = restaurants_df[~restaurants_df['id'].isin(duplicates_ids)]
