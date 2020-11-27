read_raw_reads <- function(read_ending){
  
  sort(list.files(raw_reads_dirs, pattern = read_ending, full.names = TRUE))
  
}