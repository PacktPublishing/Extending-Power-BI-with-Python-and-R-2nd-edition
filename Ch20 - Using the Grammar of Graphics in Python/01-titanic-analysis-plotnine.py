# %%
import pandas as pd
from plotnine import (
    options, theme_tufte, ggplot, aes, geom_bar,
    geom_text, after_stat, geom_histogram, facet_grid, labs
)

dataset_url = 'http://bit.ly/titanic-dataset-csv'
df = pd.read_csv(dataset_url)
df.head()

# %%
options.dpi = 300

p = (
        ggplot(df) 
        + aes(x='Pclass') 
        + geom_bar()
        + labs(title='Passenger Count by Class', x='Class', y='Count')
)
p

# %%
p = (
    p
    + aes(fill="factor(Pclass)")
    + labs(fill='Class')
    + theme_tufte()
)
p

# %%
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
p

# %%
(
    ggplot(df) 
    + aes(x='Age') 
    + geom_histogram(binwidth = 10, color = 'brown', fill = 'orange')
    + labs(title = 'Age Distribution of Passengers',
           x='Age', y='Count')
    + theme_tufte()
)

# %%
(
    ggplot(df) 
    + aes(x='Age') 
    + geom_histogram(binwidth = 10, color = 'brown', fill = 'orange')
    + facet_grid('. ~ Sex')
    + labs(title = 'Age Distribution of Passengers by Sex',
           x='Age', y='Count')
    + theme_tufte()
)

# %%
type(p)

# %%
type(p.draw())

# %%
