import pandas as pd
import pickle
import matplotlib.pyplot as plt


def serialize(obj):
    return obj.encode('latin1')

def unserialize(obj):
    return obj.decode('latin1')


def toUnpickle(obj):
    return pickle.loads(obj)


def toUncut(obj):
    return "".join(obj)

dataset = dataset.sort_values(['chunk_id'], ascending=[True])
dataset = dataset.reset_index(drop=True)

models_df = dataset.copy()[['model_id','chunk_id','model_str']]
models_df.loc[:,'model_str'] = dataset['model_str'].apply( lambda x: x + ' ' if len(x) == 31999 else x)

str_merged = toUncut(models_df['model_str'])

str_int_list = list(map(int, str_merged.split()))

str_pickled_byte_string = bytearray(str_int_list)

selected_model = toUnpickle(str_pickled_byte_string)
selected_model

input_tuple_df = dataset.copy()[['Age', 'Embarked', 'Fare', 'Parch', 'Pclass', 'Sex', 'SibSp']].drop_duplicates()
input_tuple_df

prediction_label = selected_model.predict(input_tuple_df)[0]
prediction_score = selected_model.predict_proba(input_tuple_df)[:,1][0]


plt.text(0.5, 0.5, f'Survived = {prediction_label} (prob = {prediction_score})',
         ha='center', va='center', size=20)

frame = plt.gca()
frame.axes.get_xaxis().set_visible(False)
frame.axes.get_yaxis().set_visible(False)

plt.show()

