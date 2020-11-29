trim_and_filter <- function(sample_names, raw_reads_F, raw_reads_R, output){

  # Get directories and file names for filtered seqs
  if(!dir.exists(output)){
    dir.create(output)
  }
  
  filt_reads_F <- paste0("data/processed/filtered_reads/", sample_names, "_F_filt.fastq.gz")
  filt_reads_R <- paste0("data/processed/filtered_reads/", sample_names, "_R_filt.fastq.gz")
  
  names(filt_reads_F) <- sample_names
  names(filt_reads_R) <- sample_names
 
  # Filtering parameters
  filterAndTrim(raw_reads_F, 
                filt_reads_F, 
                raw_reads_R, 
                filt_reads_R, 
                truncLen = c(264, 258), # based on raw read quality plots
                maxN = 0, 
                maxEE = c(2, 2), 
                truncQ = 2, 
                rm.phix = TRUE,
                compress = TRUE, 
                multithread = FALSE)
}