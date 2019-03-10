# library(extrafont)
# loadfonts(quiet = T)

# Compute igraph augmented by clusters (for plot)

tbl_graph_cluster <- function(cluster) {
  igraph_w_clusters <- as_tbl_graph(cluster$igraph) %>%
    activate(nodes) %>%
    left_join(cluster$df_clusters,by=c("name"="node")) %>%
    mutate(cluster=as.factor(cluster)%>%
             fct_infreq%>%
             fct_lump_min(min=2)) %>%
    activate(edges) %>%
    mutate(from_name=(V(.)%>%names)[from],
           to_name=(V(.)%>%names)[to])
  igraph_w_clusters
}

# From: https://www.r-bloggers.com/graph-analysis-using-the-tidyverse/
  
adj_plot <- function(cluster,min_cluster_size=2,
                     label_size=2.5,repel=T) {
  igraph <- cluster %>% tbl_graph_cluster
  igraph %>%
    activate(nodes) %>%
    filter(size>=min_cluster_size) %>%
    ggraph(layout = "auto") +
    geom_node_point(aes(color=cluster),size=2) +
    geom_node_text(aes(label = name),
                   size = label_size,
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
