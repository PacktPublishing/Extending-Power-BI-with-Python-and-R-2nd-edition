# %%
import io
import os
import re
import base64
import pickle
import pandas as pd
from math import ceil
from plotnine import (
    options, theme_tufte, ggplot, aes, geom_bar,
    geom_text, after_stat, labs
)


def toCut(obj, width):
    return re.findall('.{1,%s}' % width, obj, flags=re.S)

# %%

dataset_url = 'http://bit.ly/titanic-dataset-csv'
df = pd.read_csv(dataset_url)
df.head()

# %%
options.dpi = 300

p = (
        ggplot(df)
        + aes(x='Pclass', fill="factor(Pclass)")
        + geom_bar()
        + geom_text(
            aes(label = after_stat('count')),
            stat = 'count',
            nudge_x = -0.14,
            nudge_y = 0.125,
            va = 'bottom',
            size = 8
        )
        + geom_text(
            aes(label = after_stat('prop*100'), group=1),
            stat = 'count',
            nudge_x = 0.14,
            nudge_y = 0.125,
            va = 'bottom',
            format_string = '({:.1f}%)',
            size = 8
        )
        + labs(title='Passenger Count by Class',
               x='Class', y='Count', fill='Class')
        + theme_tufte()
)

# %%
# Create a Matplotlib plot and assign it to mplt
mplt = p.draw()

# project_folder = r'C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch20 - Using the Grammar of Graphics in Python'
# pickle.dump( mplt, open(os.path.join(project_folder, "mplt.pkl"), "wb") )

with io.BytesIO() as buffer:
    # Instead of saving the plot as a PNG, we'll pickle the mplt object
    pickle.dump(mplt, buffer)

    buffer.seek(0)
    pickled_data = buffer.getvalue()


# %%
pickled_int_lst = [x for x in pickled_data]

pickled_string = " ".join( [str(a) for a in pickled_int_lst] )

chops_lst = toCut(pickled_string, width=32000)

num_chops = len(chops_lst)

plot_name = 'plot01'

plot_data = {
        'plot_name': [plot_name] * num_chops,
        'chunk_id': list(range(1, num_chops+1)),
        'plot_str': chops_lst
    }

plot_df = pd.DataFrame(plot_data, columns = ['plot_name','chunk_id','plot_str'])

# %%



# %%
# # Trying the code in 07-deserialize-plots-df-into-python-visual.py to deserialize the plot

# import matplotlib.pyplot as plt

# def serialize(obj):
#     return obj.encode('latin1')

# def unserialize(obj):
#     return obj.decode('latin1')


# def toUnpickle(obj):
#     return pickle.loads(obj)


# def toUncut(obj):
#     return "".join(obj)


# dataset = plot_df.sort_values(['chunk_id'], ascending=[True])
# dataset = dataset.reset_index(drop=True)

# dataset_fixed = dataset
# dataset_fixed.loc[:,'plot_str'] = dataset['plot_str'].apply( lambda x: x + ' ' if len(x) == 31999 else x)

# str_merged = toUncut(dataset_fixed['plot_str'])

# str_int_list = list(map(int, str_merged.split()))

# str_pickled_byte_string = bytearray(str_int_list)

# str_unpickled = toUnpickle(str_pickled_byte_string)

# # mng = plt.get_current_fig_manager()
# # mng.figure = str_unpickled

# # plt.show()

# str_unpickled