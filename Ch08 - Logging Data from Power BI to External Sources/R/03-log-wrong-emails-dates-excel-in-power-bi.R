library(dplyr)
library(openxlsx)

wrong_emails_df <- dataset %>%
    filter( isEmailValidFromRegex == 0 ) %>%
    select( UserId, Email )

wrong_dates_df <- dataset %>%
    filter( isDateValidFromRegex == 0 ) %>%
    select( UserId, BannedDate )

df_named_lst <- list("Wrong emails" = wrong_emails_df, "Wrong dates" = wrong_dates_df)

write.xlsx(df_named_lst, file = r'{D:\<your-path>\Ch08 - Logging Data from Power BI to External Sources\R\wrong-data.xlsx}')

# Keep only rows having valid email and ban date
df <- dataset %>%
    filter( isEmailValidFromRegex == 1 & isDateValidFromRegex == 1 )
