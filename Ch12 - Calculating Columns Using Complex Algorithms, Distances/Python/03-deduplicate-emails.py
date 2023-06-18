# %%
import pandas as pd
import textdistance

# %%
def deduplicate_data(data, similarity_metric, similarity_threshold):

    new_columns = data.columns.to_list()
    new_columns.append('Best Comparison')
    new_columns.append('Similarity')

    # Create a new DataFrame to store the deduplicated records
    deduplicated_data = pd.DataFrame(columns=new_columns)
    duplicated_data = pd.DataFrame(columns=new_columns)

    # Create a set to keep track of unique emails
    unique_emails = set()

    # Iterate through each row in the original dataset
    for index, row in data.iterrows():
        email = row['Email']
        is_duplicate = False
        best_comparison = ''
        best_similarity_score = 0.0

        # Compare the current email with unique emails using the chosen similarity metric
        for unique_email in unique_emails:
            similarity_score = similarity_metric.normalized_similarity(email, unique_email)

            # If the similarity score exceeds the threshold, consider it a duplicate
            if similarity_score > similarity_threshold:
                is_duplicate = True

                df_to_append = pd.DataFrame([row])
                df_to_append['Best Comparison'] = unique_email
                df_to_append['Similarity'] = similarity_score

                duplicated_data = pd.concat([duplicated_data, df_to_append],
                                            axis=0, ignore_index=True)
                break

            if similarity_score > best_similarity_score:
                best_similarity_score = similarity_score
                best_comparison = unique_email

        # If it's not a duplicate, add it to the deduplicated dataset
        if not is_duplicate:
            unique_emails.add(email)

            df_to_append = pd.DataFrame([row])
            df_to_append['Best Comparison'] = best_comparison
            df_to_append['Similarity'] = best_similarity_score

            deduplicated_data = pd.concat([deduplicated_data, df_to_append],
                                          axis=0, ignore_index=True)

    deduplicated_data.sort_values(by=['Name'], inplace=True)
    duplicated_data.sort_values(by=['Name'], inplace=True)

    # Return datasets
    return deduplicated_data, duplicated_data

# %%
# Read the dataset into a pandas DataFrame
data = pd.read_json(r'C:\<your-path>\Ch12 - Calculating Columns Using Complex Algorithms, Distances\email-addresses-to-dedup.json')

# %%
# Show unique names and their cardianlity
unique_names_df = data[['Name']].drop_duplicates().sort_values(by=['Name'])
unique_names_df

# %%
len(data['Name'].unique())

# %%
deduplicated_data_jaccard, duplicated_data_jaccard = deduplicate_data(data,
    similarity_metric=textdistance.Jaccard(as_set=True),
    similarity_threshold=0.875)

deduplicated_data_jaccard

# %%
duplicated_data_jaccard

# %%
deduplicated_data_jaro_winkler, duplicated_data_jaro_winkler = deduplicate_data(data,
    similarity_metric=textdistance.jaro_winkler,
    similarity_threshold=0.89)

deduplicated_data_jaro_winkler

# %%
duplicated_data_jaro_winkler

# %%
deduplicated_data_jaccard_3grams, duplicated_data_jaccard_3grams = deduplicate_data(data,
    similarity_metric=textdistance.Jaccard(as_set=True, qval=3),
    similarity_threshold=0.55)

deduplicated_data_jaccard_3grams

# %%
duplicated_data_jaccard_3grams

# %%
deduplicated_data_jaro_winkler_3grams, duplicated_data_jaro_winkler_3grams = deduplicate_data(data,
    similarity_metric=textdistance.JaroWinkler(qval=3),
    similarity_threshold=0.81)

deduplicated_data_jaro_winkler_3grams

# %%
duplicated_data_jaro_winkler_3grams


# %%
