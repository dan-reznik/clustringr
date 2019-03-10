#' @importFrom magrittr %>%
#' @importFrom dplyr desc tibble select mutate arrange summarize count left_join case_when
#' @importFrom forcats fct_inorder
#' @importFrom stringr str_trim str_squish str_to_lower
#' @importFrom assertthat assert_that
#' @importFrom igraph components cluster_edge_betweenness membership graph_from_adjacency_matrix
#' @importFrom rlang .data

clean_strings <- function(s_vec) {
  s_vec %>%
  str_squish %>%
  str_to_lower %>%
  unique
}

order_by_count <- function(clusters) {
  sizes <- clusters %>%
    count(.data$cluster,sort=T,name="size")
  clusters %>%
    left_join(sizes,by="cluster") %>%
    arrange(desc(.data$size),.data$node) %>%
    select(.data$cluster,.data$size,.data$node) %>%
    mutate(cluster=.data$cluster%>%
             as.factor%>%
             fct_inorder%>%
             as.integer)
}

prep_strings <- function(s_vec) {
  s_vec_c <- s_vec %>% clean_strings
  dups <- length(s_vec_c)-length(s_vec)
  msg=sprintf("vector has %d duplicates, use clean=T",dups)
  assert_that(dups==0,msg=msg)
  s_vec_c
}

get_adj_mtx <- function(s_vec,clean,method,max_dist) {
  if (clean) s_vec <- prep_strings(s_vec)
  # lower diag only, avoids computing entire symm mtx
  dist <- stringdist::stringdistmatrix(s_vec,method=method)
  mtx <- as.matrix(dist)
  mtx[mtx>max_dist] <- 0
  mtx[mtx!=0] <- 1 # weights are interpreted as number of connections
  #print(glue("edges: {sum(mtx)}"))
  rownames(mtx) <- s_vec
  colnames(mtx) <- s_vec
  mtx
}

prep_graph <- function(s_vec,clean,method,max_dist) {
  mtx <- get_adj_mtx(s_vec,clean,method,max_dist)
  g <- graph_from_adjacency_matrix(mtx,mode="undirected")
  list(mtx=mtx,g=g)
}

cluster_strings_eb <- function(g) {
  # other methods: cluster_label_prop(g), cluster_fast_greedy(g)
  g_clusters <- cluster_edge_betweenness(g$g)
  # components
  # if(plot) plot_graph(g_clusters,g$g)
  g_memb <- membership(g_clusters)
  # return membership as tibble
  df <- tibble(node=names(g_memb),
               cluster=g_memb%>%as.integer) %>%
    # arrange(cluster) %>%
    order_by_count
  list(adj_mtx=g$mtx,igraph=g$g,df_clusters=df)
}

cluster_strings_cc <- function(g) {
  g_cc <- components(g$g)
  memb <- g_cc$membership
  # return membership as tibble
  df <- tibble(node=memb%>%names,
               cluster=memb%>%as.integer) %>%
    # arrange(cluster) %>%
    order_by_count
  list(adj_mtx=g$mtx,igraph=g$g,df_clusters=df)
}

#' Cluster Strings by Edit-Distance
#'
#' @param s_vec a vector of character strings
#' @param clean whether to space-squish and de-duplicate s_vec
#' @param method one of "osa","lv","dl" (as in `stringdist`)
#' @param max_dist max distance (typically damerau-levenshtein) between related strings.
#' @param algo one of "cc" (connected components) or "eb" (edge betweeness)
#'
#' @return a data frame containing cluster membership for each input string
#' @export
#'
#' @examples
#' s_vec <- c("alcool","alcohol","alcoholic","brandy","brandie","cachaça")
#' s_clust <- cluster_strings(s_vec,method="lv",max_dist=3,algo="cc")
#' s_clust$df_clusters
cluster_strings <- function(s_vec,
                            clean=T,
                            method="osa",
                            max_dist=3,
                            algo="cc") {
  assert_that(method%in%c("osa","lv","dl"),
              msg="invalid method")
  assert_that(algo%in%c("cc","eb"),
              msg="invalid algorithm")

  g <- prep_graph(s_vec,clean=clean,method=method,max_dist=max_dist)
  if(algo=="cc")
    cluster_strings_cc(g)
  else
    cluster_strings_cc(g)
}
