track_reads <- function(trim_filt_out, infered_seqs_F, infered_seqs_R, 
                        merged_seqs, seqtab_nochim, sample_names){
  
  getN <- function(x) sum(getUniques(x))
  
  track <- cbind(
    trim_filt_out,
    sapply(infered_seqs_F, getN),
    sapply(infered_seqs_R, getN),
    sapply(merged_seqs, getN),
    rowSums(seqtab_nochim)
  )
  
  colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
  rownames(track) <- sample_names
  
  as_tibble(track, rownames = "Read_Name")
}