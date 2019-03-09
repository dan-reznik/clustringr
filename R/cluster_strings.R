#' @importFrom magrittr %>%
#' @importFrom dplyr desc tibble select mutate arrange summarize count left_join
#' @importFrom forcats fct_inorder
#' @importFrom stringr str_trim str_squish str_to_lower
#' @importFrom graphics plot
#' @importFrom rlang .data

clean_strings <- function(s_vec) {
  s_vec %>%
  str_squish %>%
  str_to_lower %>%
  unique
}

plot_graph <- function(g_cluster,g) {
  set.seed(2)
  plot(g_cluster, g,
       edge.color="black",
       vertex.label.cex=.5,
       vertex.size=5,
       vertex.label.dist=1,
       vertex.label.degree=-pi/2,
       vertex.label.family="Times")
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
  assertthat::assert_that(dups==0,
                          msg=msg)
  s_vec_c
}

get_adj_mtx <- function(s_vec,clean,max_dl,method) {
  if (clean) s_vec <- prep_strings(s_vec)
  # lower diag only, avoids computing entire symm mtx
  dist <- stringdist::stringdistmatrix(s_vec,method=method)
  mtx <- as.matrix(dist)
  mtx[mtx>max_dl] <- 0
  mtx[mtx!=0] <- 1 # weights are interpreted as number of connections
  #print(glue("edges: {sum(mtx)}"))
  rownames(mtx) <- s_vec
  colnames(mtx) <- s_vec
  mtx
}

prep_graph <- function(s_vec,clean,max_dl,method) {
  mtx <- get_adj_mtx(s_vec,clean,max_dl,method)
  g <- igraph::graph_from_adjacency_matrix(mtx,mode="undirected")
  list(mtx=mtx,g=g)
}

cluster_strings <- function(s_vec,max_dl=3,clean=T,method="osa",plot=F) {
  g <- prep_graph(s_vec,clean=clean,max_dl=max_dl,method=method)
  # other methods: cluster_label_prop(g), cluster_fast_greedy(g)
  g_clusters <- igraph::cluster_edge_betweenness(g$g)
  # components
  if(plot) plot_graph(g_clusters,g$g)
  g_memb <- igraph::membership(g_clusters)
  # return membership as tibble
  df <- tibble(node=names(g_memb),
               cluster=g_memb%>%as.integer) %>%
    # arrange(cluster) %>%
    order_by_count
  list(adj_mtx=g$mtx,igraph=g$g,df_clusters=df)
}

#' Cluster Strings via Connected Components
#'
#' @param s_vec a vector of character strings
#' @param max_dl max distance (typically damerau-levenshtein) between related strings.
#' @param method one of "osa","lv","dl" (see stringdist's methods)
#' @param clean whether to space-squish and de-duplicate s_vec
#'
#' @return a data frame containing cluster membership for each input string
#' @export
#'
#' @examples
#' cluster_strings_cc(c("alcool","alcohol","alcoholic","brandy","brandie","cachaça"))
cluster_strings_cc <- function(s_vec,max_dl=3,method="osa",clean=T) {
  g <- prep_graph(s_vec,clean=clean,max_dl=max_dl,method=method)
  g_cc <- igraph::components(g$g)
  memb <- g_cc$membership
  # return membership as tibble
  df <- tibble(node=memb%>%names,
               cluster=memb%>%as.integer) %>%
    # arrange(cluster) %>%
    order_by_count
  list(adj_mtx=g$mtx,igraph=g$g,df_clusters=df)
}
