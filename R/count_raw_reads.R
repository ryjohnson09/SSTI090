count_raw_reads <- function(sample_names, raw_reads_F){
  # Initialize empty tibble
  init_read_count <- tibble(sample_id = character(0), num_reads = numeric(0))
  
  # Count reads per sample for each read
  for (i in seq_along(raw_reads_F)){
    seq_row <- tibble(sample_id = sample_names[i],
                      num_reads = length(readFastq(raw_reads_F[i])))
    
    init_read_count <- init_read_count %>% 
      full_join(seq_row, by = c("sample_id", "num_reads"))
    rm(seq_row)
  }
  init_read_count
}
