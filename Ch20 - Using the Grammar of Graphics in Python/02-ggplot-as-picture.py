# %%
import io
import base64
import re
import pandas as pd
from math import ceil
from plotnine import (
    options, theme_tufte, ggplot, aes, geom_bar,
    geom_text, after_stat, labs
)

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

# Using a BytesIO object as a buffer to store the image data in memory
with io.BytesIO() as buffer:
    # Save the Matplotlib plot (mplt) as a PNG image in the buffer
    mplt.savefig(buffer, format='png')

    # Move the buffer's pointer to the beginning of the buffer
    buffer.seek(0)

    # Read the image data from the buffer into the variable 'image'
    image = buffer.getvalue()

    # Convert the binary image data to a Base64-encoded string
    # The string is encoded using 'latin1' character set
    image_to_string = base64.b64encode(image).decode('latin1')



# %%
# Checking the length of the byte string representation
len(image_to_string) # 78.164

# %%
def toCut(obj, width):
    return re.findall('.{1,%s}' % width, obj, flags=re.S)

def find_largest_chunk_length(n):
    # Calculate k so that k*10000 <= n and k*10000 <= 30000
    # to respect the limit of 32,766 characters for the
    # length of a string in a dataset cell in Power Query 
    k = min(n // 10000, 3)
    
    # Return the larger value of k * 10000 that fits in n
    # so that k * 10000 <= 30000
    return k * 10000

str_len = len(image_to_string)
max_len = find_largest_chunk_length(str_len)

# %%
image_to_string_splitted = toCut(image_to_string, max_len)

num_chops = ceil(str_len / max_len)

tmp_data = {
    'plot_name': ['plot01'] * num_chops,
    'chunk_id': list(range(1, num_chops+1)),
    'plot_str': image_to_string_splitted
}

img_to_str_splitted_df = pd.DataFrame(tmp_data, columns = ['plot_name','chunk_id','plot_str'])

img_to_str_splitted_df

# %%
