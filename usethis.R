# just for reference!
# had to do: git config remote.origin.url \
# git@github.com:dan-reznik/clustringr.git
pacman::p_load(
  devtools,
  usethis,
  roxygen2,
  testthat,
  knitr,
  rmarkdown
)
use_package("magrittr")
use_package("dplyr")
use_package("forcats")
use_package("stringi")
use_package("stringr")
use_package("stringdist")
use_package("igraph")
use_package("assertthat")
use_package("rlang")
