library(nc)
library(readr)

path             <- "<your-path>/Extending-Power-BI-with-Python-and-R-2nd-edition/Ch06 - Using Regular Expressions in Power BI/02-loading-complex-log-files-using-regex/apache_logs.txt"
access_log_lines <- read_lines(path)

# Define a regex for the information (variables) contained in each row of the log
pattern <- list(
    hostName = "\\S+",                                    # remote hostname (IP address)
    " ", "\\S+",                                          # remote logname (you’ll find a dash if empty; not used in the sample file)
    " ", userName = "\\S+",                               # remote user if the request was authenticated (you’ll find a dash if empty)
    " \\[", requestDateTime = "[\\w:/]+\\s[+\\-]\\d{4}",  # datetime the request was received, in the format [18/Sep/2011:19:18:28 -0400]
    "\\] \"", requestContent = "\\S+\\s?\\S+?\\s?\\S+?",  # first line of the request made to the server between double quotes "%r"
    "\" ", requestStatus = "\\d{3}|-",                    # HTTP status code for the request
    " ", responseSizeBytes = "\\d+|-",                    # size of response in bytes, excluding HTTP headers (can be '-')
    " \"", requestReferrer = "[^\"]*",                    # Referer HTTP request header, that contains the absolute or partial address of the page making the request
    "\" \"", requestAgent = "[^\"]*",                     # User-Agent HTTP request header, that contains a string that identifies the application, operating system, vendor, and/or version of the requesting user agent
    "\""
)

# Use capture_first_vec() to match the pattern and capture named groups
matches <- capture_first_vec(access_log_lines, pattern)

# Convert the resulting list to a data frame
df      <- as.data.frame(matches)
