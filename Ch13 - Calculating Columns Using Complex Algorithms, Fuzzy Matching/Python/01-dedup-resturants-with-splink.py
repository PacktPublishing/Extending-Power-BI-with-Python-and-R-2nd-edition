# %%
import os
import re
import numpy as np
import pandas as pd

from splink.duckdb.linker import DuckDBLinker
from splink.duckdb.comparison_template_library import name_comparison
import splink.duckdb.comparison_library as cl

# %%
def clean_string(input_string):
    # Convert to lower case
    cleaned_string = input_string.lower()
    
    # Remove trailing spaces
    cleaned_string = cleaned_string.strip()
    
    # Remove special characters
    cleaned_string = re.sub(r'[^a-zA-Z0-9\s]', '', cleaned_string)
    
    return cleaned_string


# %%
# https://www.cs.utexas.edu/users/ml/riddle/data.html

main_path = r'C:\<your path>\Ch13 - Calculating Columns Using Complex Algorithms, Fuzzy Matching'

restaurants_df = pd.read_csv(os.path.join(main_path, 'restaurants.csv'),
                             skipinitialspace=True)

restaurants_df["name"] = restaurants_df["name"].apply(lambda x: clean_string(x))
restaurants_df["addr"] = restaurants_df["addr"].apply(lambda x: clean_string(x))
restaurants_df["city"] = restaurants_df["city"].apply(lambda x: clean_string(x))

restaurants_df


# %%

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


# %%
linker.estimate_u_using_random_sampling(max_pairs=1e6)

# %%
training_blocking_rule = "l.name = r.name and l.addr = r.addr"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

# %%
training_blocking_rule = "l.name = r.name and l.city = r.city"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

# %%
training_blocking_rule = "l.city = r.city and l.addr = r.addr"
training_session_names = linker.estimate_parameters_using_expectation_maximisation(training_blocking_rule)

# %%
#linker.match_weights_chart()
linker.m_u_parameters_chart()

# %%
df_predict = linker.predict()

matches_df = df_predict.as_pandas_dataframe()
matches_df

# %%
low_prob_matches_dict = matches_df[
    (matches_df["match_weight"] >= 0) & (matches_df["match_weight"] < 1)].to_dict(orient="records")

linker.waterfall_chart(low_prob_matches_dict)


# %%
truth_step0_df = restaurants_df.merge(restaurants_df, how='inner', on='class').query('id_x != id_y')

truth_step0_df['row_num'] = truth_step0_df.reset_index().index
truth_step0_df = truth_step0_df[['id_x', 'id_y', 'row_num']]

truth_df = truth_step0_df.merge(truth_step0_df, how='inner',
                          left_on=['id_x', 'id_y'], right_on = ['id_y', 'id_x']).query('row_num_x < row_num_y')
truth_df['truth'] = True

truth_df = truth_df.rename(columns={'id_x_x': 'id_l', 'id_x_y': 'id_r'})[['id_l', 'id_r', 'truth']]

truth_df

# %%
matches_df = matches_df.drop(columns=['match_key']).drop_duplicates().merge(truth_df, how='left', on=['id_l', 'id_r'])
matches_df['truth'] = matches_df['truth'].apply(lambda x: True if x == True else False)

weight_threshold = 0
matches_df['match'] = np.where(matches_df['match_weight'] >= weight_threshold, True, False)

matches_df

# %%
# pass predicted and original labels to this function
def confusion_matrix(pred,original):
    matrix=np.zeros((2,2), dtype=np.int32)
    # adds up the frequencies of the tps,tns,fps,fns
    for i in range(len(pred)):
        if int(pred[i])==1 and int(original[i])==1: 
            matrix[1,1]+=1 #True Positives
        elif int(pred[i])==0 and int(original[i])==1:
            matrix[0,1]+=1 #False Positives
        elif int(pred[i])==1 and int(original[i])==0:
            matrix[1,0]+=1 #False Negatives
        elif int(pred[i])==0 and int(original[i])==0:
            matrix[0,0]+=1 #True Negatives
    
    return matrix

print( confusion_matrix(matches_df['match'], matches_df['truth']) )
