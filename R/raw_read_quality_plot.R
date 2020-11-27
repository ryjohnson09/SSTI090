raw_read_quality_plot <- function(read_ending){
  
  # Get list of raw reads
  raw_reads <- sort(list.files(raw_reads_dirs, pattern = read_ending, full.names = TRUE))
  
  # Remove undetermined files
  raw_reads <- raw_reads[!grepl("Undetermined", raw_reads)]
  
  # Plot random subset of reads
  set.seed(1234)
  plotQualityProfile(raw_reads[sample(length(raw_reads), 20)])
}
