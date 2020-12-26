create_ps <- function(seqtab_nochim, taxa, ssti_metadata){
  
  # Create Phyloseq Object
  ps <- phyloseq(otu_table(seqtab_nochim, taxa_are_rows = FALSE),
           sample_data(column_to_rownames(ssti_metadata, var = "sample_name")),
           tax_table(taxa))
  
  # Rename ASVs to "ASV1, ASV2..."
  dna <- Biostrings::DNAStringSet(taxa_names(ps))
  names(dna) <- taxa_names(ps)
  ps <- merge_phyloseq(ps, dna)
  taxa_names(ps) <- paste0("ASV", seq(ntaxa(ps)))
  ps
}