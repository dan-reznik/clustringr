
<!-- README.md is generated from README.Rmd. Please edit that file -->
clustringr 0.1.0
================

`clustringr` clusters a vector of strings into groups of small mutual "edit distance" (see `stringdist`), using graph algorithms. Notice it's unsupervised, i.e., you do not need to pre-specify cluster count.

Usage
-----

In the example below a vector of 9 strings is clustered into 4 groups by levenshtein distance and connected components. The call to `cluster_strings()` returns a list w/ 3 elements, the last of which is `df_clusters` which associates to every input string a `cluster`, along with its cluster `size`.

``` r
library(clustringr)
s_vec <- c("alcool",
           "alcohol",
           "alcoholic",
           "brandy",
           "brandie",
           "cachaça",
           "whisky",
           "whiskie",
           "whiskers")
clusters <- cluster_strings(s_vec # input vector
                            ,clean=T # dedup and squish
                            ,method="lv" # levenshtein
                            # use: method="dl" (dam-lev) or "osa" for opt-seq-align
                            ,max_dist=3 # max edit distance for neighbors
                            ,algo="cc" # connected components
                            # use algo="eb" for edge-betweeness
                            )
clusters$df_clusters
#> # A tibble: 9 x 3
#>   cluster  size node     
#>     <int> <int> <chr>    
#> 1       1     3 alcohol  
#> 2       1     3 alcoholic
#> 3       1     3 alcool   
#> 4       2     3 whiskers 
#> 5       2     3 whiskie  
#> 6       2     3 whisky   
#> 7       3     2 brandie  
#> 8       3     2 brandy   
#> 9       4     1 cachaça
```

Cluster Visualization
---------------------

Below is a graph of non-singleton clusters computed from some 300 spanish words sampled from Miguel de Cervantes' [Don Quijote](http://www.gutenberg.org/cache/epub/2000/pg2000.txt). \[Stay tuned for code entry point\]

<img src="./man/figures/quijote800.png" width="533" />

Installation
============

Currently a development version is available on github.

``` r
# install.packages('devtools')
devtools::install_github('dan-reznik/clustringr')
```
