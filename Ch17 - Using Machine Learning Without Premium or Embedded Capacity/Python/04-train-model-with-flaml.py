# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from flaml import AutoML
import pickle
import os

# %%
main_path = r'C:\<your-path>\Ch17 - Using Machine Learning Without Premium or Embedded Capacity'

# %%
# Uncomment this code if you're not using it in Power BI
# in order to load the previous imputed Titanic dataset in script 01
dataset = pd.read_csv(os.path.join(main_path, 'titanic-imputed.csv'))
dataset

# %%
# Let's split the dataframe in a small part to be kept for test purpose and
# a large part for training.
X = dataset.drop('Survived',axis=1)
y = dataset[['Survived']]

# Force the float values of Pclass to integer, as Power BI imports it as an int column
X['Pclass'] = X['Pclass'].astype('int')

X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.05)

# %%
# Setup the FLAML AutoML experiment properly
automl = AutoML()

settings = {
    "time_budget": 600,  # total running time in seconds
    "metric": 'roc_auc', # check the documentation for options of metrics (https://microsoft.github.io/FLAML/docs/Use-Cases/Task-Oriented-AutoML#optimization-metric)
    "task": 'classification',  # task type
    "log_file_name": 'titanic.log',  # flaml log file
    "seed": 7654321,    # random seed
}

# Get a Pandas series from the single column y_train datarame,
# as automl.fit requires a series for its y_train parameter
y_train_series = y_train.squeeze()

automl.fit(X_train=X_train, y_train=y_train_series, **settings)

# %%
'''retrieve best config and best learner'''
print('Best ML leaner:', automl.best_estimator)
print('Best AUC on validation data: {0:.4g}'.format(1-automl.best_loss))


# %%
# Save the FLAML AutoML object in a pkl file for future reuse
with open(os.path.join(main_path, r'Python\titanic-model-flaml.pkl'), 'wb') as f:
    pickle.dump(automl, f, pickle.HIGHEST_PROTOCOL)

# Save the Scikit-learn best estimator in a pkl file for future reuse
with open(os.path.join(main_path, r'Python\titanic-best-model-flaml.pkl'), 'wb') as f:
    pickle.dump(automl.model.estimator, f, pickle.HIGHEST_PROTOCOL)

# %%
# Merge the feature test dataframe and target test column in a unique test dataframe
# and save it in a CSV file for future reuse
df_test = pd.concat([X_test, y_test], axis=1, ignore_index=True).reset_index(drop=True, inplace=False)
df_test = df_test.set_axis(np.append(X.columns.values, 'Survived'),axis=1)
df_test


# %%
df_test.to_csv(os.path.join(main_path, r'titanic-test.csv'),
               index=False)

# %%
# Get model predictions for the test dataframe
y_pred = automl.predict(X_test)
y_pred_proba = automl.predict_proba(X_test)[:,1]

predictions = df_test
predictions['prediction_label'] = y_pred
predictions['prediction_proba'] = np.where(predictions['prediction_label'] == 1, y_pred_proba, 1 - y_pred_proba) 
predictions

# %%
