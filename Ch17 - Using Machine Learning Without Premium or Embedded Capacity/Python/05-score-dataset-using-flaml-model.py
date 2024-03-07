# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import numpy as np
import pandas as pd
import pickle
import os


# %%
main_path = r'C:\<your-path>\Ch17 - Using Machine Learning Without Premium or Embedded Capacity'

# # %%
# # Uncomment this code if you're not using it in Power BI
# # in order to load the imputed test dataset
# dataset = pd.read_csv(os.path.join(main_path, 'titanic-test.csv'),
#                       index_col=False)
# dataset

# %%
# Unserialize the FLAML AutoML object previously trained
# with open(os.path.join(main_path, r'Python\titanic-model-flaml.pkl'), 'rb') as f:
#     model = pickle.load(f)

with open(os.path.join(main_path, r'Python\titanic-best-model-flaml.pkl'), 'rb') as f:
    model = pickle.load(f)

# %%
# Get model predictions for the test dataframe
X_test = dataset.drop('Survived',axis=1)

y_pred = model.predict(X_test)
y_pred_proba = model.predict_proba(X_test)[:,1]

predictions = dataset
predictions['prediction_label'] = y_pred
predictions['prediction_score'] = np.where(predictions['prediction_label'] == 1, y_pred_proba, 1 - y_pred_proba) 
predictions

# %%
