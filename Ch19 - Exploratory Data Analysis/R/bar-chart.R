# Loading necessary library
library(ggplot2)

# Assuming your tibble is named 'tbl', create the plot:
plot <- ggplot(tbl, aes(x = factor(Pclass))) +
  geom_bar(aes(fill = factor(Pclass)), position = "dodge") +
  geom_text(stat='count', aes(label=sprintf("%d (%d%%)", ..count.., round(..count../sum(..count..)*100))), vjust=-0.5) +
  labs(x = "Pclass", y = "Freq", fill = "Pclass") +
  theme_minimal()

print(plot)
