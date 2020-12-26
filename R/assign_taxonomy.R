assign_taxonomy <- function(seqtab_nochim, silva_file){
  # Create a DNAStringSet from the ASVs
  dna <- DNAStringSet(getSequences(seqtab_nochim)) 
  
  # Load Silva training set
  load(silva_file) 
  
  
  ids <- IdTaxa(dna, trainingSet, strand="both", processors = NULL, verbose = FALSE) 
  ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species")
  
  # Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
  taxid <- t(sapply(ids, function(x) {
    m <- match(ranks, x$rank)
    taxa <- x$taxon[m]
    taxa[startsWith(taxa, "unclassified_")] <- NA
    taxa
  }))
  colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab_nochim)
  
  taxid
}
