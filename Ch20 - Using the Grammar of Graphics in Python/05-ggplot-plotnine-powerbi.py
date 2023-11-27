import matplotlib.pyplot as plt

from plotnine import (
    options, theme_tufte, ggplot, aes, geom_bar,
    geom_text, after_stat, labs
)

p = (
        ggplot(dataset) 
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

print(p)
