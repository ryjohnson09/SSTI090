get_sample_names <- function(){
  readd(raw_reads_F) %>% 
    basename() %>% 
    str_replace(pattern = "^(\\d+-.+-.)_.*", 
                replacement = "\\1")
}
  