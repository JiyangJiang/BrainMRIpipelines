# install older version package
require (devtools)
install_version("class",version="7.3-14",repos="http://cran.us.r-project.org")

# if encounter the error of "error: linker command failed with exit code 1"
# install the latest gfortran : https://gcc.gnu.org/wiki/GFortranBinaries

# check R package version
packageVersion("class")