trim_and_filter <- function(sample_names, 
                            raw_reads_F, 
                            raw_reads_R, 
                            filt_reads_F, 
                            filt_reads_R, 
                            output){

  # Get directories and file names for filtered seqs
  if(!dir.exists(output)){
    dir.create(output)
  }
 
  # Filtering parameters
  filterAndTrim(raw_reads_F, 
                filt_reads_F, 
                raw_reads_R, 
                filt_reads_R, 
                truncLen = c(263, 248), # based on raw read quality plots
                maxN = 0, 
                maxEE = c(2, 3), 
                truncQ = 2, 
                rm.phix = TRUE,
                compress = TRUE, 
                multithread = FALSE)
}