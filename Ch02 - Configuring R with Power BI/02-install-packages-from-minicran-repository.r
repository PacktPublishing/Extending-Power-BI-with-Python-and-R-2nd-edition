# Actual libraries folder
outputlib <- .libPaths()

# Local miniCRAN repository from which install packages
inputlib <- "C:/miniCRAN_R344"

# Declare the packages you want to install
mypackages <- c("ggplot2")

# Install the selected packages from the local miniCRAN repository
install.packages(mypackages,
                 repos = file.path("file://",
                 normalizePath(inputlib, winslash = "/")),
                 lib = outputlib,
                 type = "win.binary",
                 dependencies = TRUE);
