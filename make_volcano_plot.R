# Volcano Plot Function

make_volcano_plot <- function(res) {
  res <- res %>% 
    as.data.frame() %>% 
    mutate(graph_alpha = ifelse((padj < 0.1) | (is.na(padj)), 1,0.2)) %>%
    mutate(graph_color = case_when(graph_alpha == 1 & log2FoldChange < 0 ~ "downregulated",
                                   graph_alpha == 1 & log2FoldChange > 0 ~ "upregulated",
                                   TRUE ~ "not significant")) 
  
  my_plot <- ggplot(res, aes(x = log2FoldChange,
                             y= -log10(padj),
                             fill = graph_color)) +
    geom_point(aes(alpha = graph_alpha), pch = 21) +
    theme(legend.position = 'top') +
    ggpubr::theme_pubr() +
    scale_fill_manual(values = c("yellow", "gray", "purple")) +
    ylab(expression(paste("-Lo", g[10], "P-value"))) +
    xlab(expression(paste("Lo", g[2], "Fold Change"))) +
    theme(text = element_text(size = 24)) +
    theme(legend.text = element_text(size = 22)) +
    geom_hline(yintercept = -log10(0.1)) +
    geom_vline(xintercept = c(0), linetype = "dotted") +
    guides(alpha = FALSE, size = FALSE, fill = FALSE)
  

  return(my_plot)
}
  
# here are some helper functions to do extra stuff to the volcano plot

#this one will add the gene names of those of interest to the plot

add_name_to_plot <-  function(res, gene_names = "Tardbp"){
  
  first_plot <- make_volcano_plot(res)
  
  with_name <- first_plot$data %>% 
    as.data.frame() %>% 
    rownames_to_column("ensgene") %>% 
    left_join(annotables::grcm38) %>% 
    filter(symbol %in% gene_names) 
  
  named_plot <- first_plot + 
    geom_text(data = with_name, aes(label = symbol))
  
  return(named_plot)
}

#this one will return the volcano plot with added gene name labels based on significance

label_significant <- function(res, log2FoldCut = 3, log10padj = 20){
  first_plot <- make_volcano_plot(res)
  
  with_name <-first_plot$data %>% 
    as.data.frame() %>% 
    rownames_to_column("ensgene") %>% 
    left_join(annotables::grcm38)  %>% 
    filter(-log10(padj) > log10padj) %>% 
    filter(abs(log2FoldChange) > log2FoldCut)
  
  print(dim(with_name))
  named_plot <- first_plot +
    geom_text(data = with_name, aes(label = symbol))
  
  return(named_plot)
}
