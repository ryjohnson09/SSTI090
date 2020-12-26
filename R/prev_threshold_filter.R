prev_threshold_filter <- function(ps_taxa_prev){
  
  # Compute prevalence of each feature, store as data.frame
  prevdf <- apply(X = otu_table(ps_taxa_prev),
                  MARGIN = ifelse(taxa_are_rows(ps_taxa_prev), yes = 1, no = 2),
                  FUN = function(x){sum(x > 0)})
  # Add taxonomy and total read counts to this data.frame
  prevdf <- data.frame(Prevalence = prevdf,
                       TotalAbundance = taxa_sums(ps_taxa_prev),
                       tax_table(ps_taxa_prev))
  
  # Subset to the remaining phyla
  prevdf1 <- subset(prevdf, phylum %in% get_taxa_unique(ps_taxa_prev, "phylum"))
  
  # Define prevalence threshold as N% of total samples
  prevalenceThreshold <- 0.02 * nsamples(ps_taxa_prev)
  
  # Execute prevalence filter, using `prune_taxa()` function
  keepTaxa <- rownames(prevdf1)[(prevdf1$Prevalence >= prevalenceThreshold)]
  prune_taxa(keepTaxa, ps_taxa_prev)
}