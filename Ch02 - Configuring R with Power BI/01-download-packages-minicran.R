library("miniCRAN")

# Reference the CRAN 0-Clud mirror
CRAN_mirror <- c(CRAN = "https://cloud.r-project.org")

# Declare the packages' destination folder in your local machine
# and create it
local_repo <- "C:/miniCRAN_R344"
dir.create(local_repo)

# Declare the packages you want to install.
# Note that plyr and reshape2 are needed for ggplot2 even if
# they aren't declared as its direct dependencies
pkgs_needed <- c("plyr", "reshape2", "ggplot2")

# Reference the package dependencies and add them as
# packages to download
pkgs_with_dependencies <- pkgDep(pkgs_needed, repos = CRAN_mirror)

# Download all packages with version compatible with the engine R 3.4.4 
makeRepo(pkgs_with_dependencies, path = local_repo,
         repos = CRAN_mirror,
         type = "win.binary",
         Rversion = "3.4.4")

# Fix a bug in miniCRAN 0.2.16 on versioning of the packages RDS file
# Check this issue: https://github.com/andrie/miniCRAN/issues/129
pkgs_rds_path <- file.path(local_repo, "/bin/windows/contrib/3.4", "PACKAGES.rds")
pkgs_rds <- readRDS(pkgs_rds_path)
saveRDS(pkgs_rds, file = pkgs_rds_path, version = 2)
