get_sample_names <- function(raw_reads_F){
  raw_reads_F %>% 
    basename() %>% 
    str_replace(pattern = "^(\\d+-.+-.)_.*", 
                replacement = "\\1") %>% 
    str_replace(pattern = "_.{2,3}_534R.*.fastq.gz",
                replacement = "")
}
  