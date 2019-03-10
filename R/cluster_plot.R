#' @importFrom tidygraph as_tbl_graph %N>% %E>%
#' @importFrom dplyr filter
#' @importFrom forcats fct_infreq fct_lump_min
#' @importFrom ggraph ggraph geom_node_text geom_node_point geom_edge_diagonal
#' @importFrom ggplot2 aes coord_equal theme_minimal theme element_blank
#' @importFrom rlang .data

# library(extrafont)
# loadfonts(quiet = T)

# Compute igraph augmented by clusters (for plot)

tbl_graph_cluster <- function(cluster) {
  igc0 <- as_tbl_graph(cluster$igraph) %N>%
    left_join(cluster$df_clusters,by=c("name"="node")) %>%
    mutate(cluster=as.factor(cluster)%>%
             fct_infreq%>%
             fct_lump_min(min=2))
  igc1 <- igc0 %E>%
    mutate(from_name=(igraph::V(igc0)%>%names)[.data$from],
           to_name=(igraph::V(igc0)%>%names)[.data$to])
  igc1
}

#' Plot string clusters as graph.
#'
#' @param cluster string clusters returned from `cluster_strings()`
#' @param min_cluster_size minimum size for clusters to be plotted.
#' @param label_size how big should the cluster name fonts be.
#' @param repel whether to "repel" (so cluster names won't overlap)
#'
#' @return a graph plot (using `ggraph`) of the string clusters.
#' @export
#'
#' @examples
#' s_vec <- c("alcool","alcohol","alcoholic","brandy","brandie","cachaça")
#' s_clust <- cluster_strings(s_vec,method="lv",max_dist=3,algo="cc")
#' cluster_plot(s_clust,min_cluster_size=1)
cluster_plot <- function(cluster,
                     min_cluster_size=2,
                     label_size=2.5,
                     repel=T) {
  igraph <- cluster %>% tbl_graph_cluster
  igraph %N>%
    # activate(nodes) %>%
    filter(.data$size>=min_cluster_size) %>%
    ggraph(layout = "auto") +
    geom_node_point(aes(color=cluster),size=2) +
    geom_node_text(aes(label=.data$name),
                   size=label_size,
                   fontface="plain",
                   repel=repel) +
    geom_edge_diagonal() +
    coord_equal() +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank(),
      panel.grid.major = element_blank()
    )
}
