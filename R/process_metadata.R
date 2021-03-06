process_metadata <- function(raw_metadata) {
  
  # Filter and clean
  metadata_filter <- raw_metadata %>% 
    dplyr::filter(Study != c("Convergence")) %>% 
    separate(col = Study, into = c("Study", "Sample_Group"), sep = ", ")
  
  # Extract all fastq.gz files
  raw_reads <- list.files(raw_reads_dirs) %>% 
    str_subset(pattern = "fastq.gz$") %>% 
    str_replace_all(pattern = "_R[12]\\.fastq.gz$", replacement = "") %>% 
    unique()
  
  # Remove undetermined files
  raw_reads <- raw_reads[!grepl("^Undetermined", raw_reads)]
  
  # Create read tibble
  raw_reads_info <- tibble("Read_Name" = raw_reads) %>% 
    # Day Column
    mutate(Day = str_replace(string = Read_Name, 
                             pattern = ".*-D(\\d+)-.*", 
                             replacement = "\\1")) %>% 
    mutate(Day = ifelse(str_detect(string = Day, 
                                   pattern = "SSTI|Mock|NA|Neg|EMPTY"), NA, Day)) %>% 
    # Sample Type
    mutate(Sample_Type = case_when(
      str_detect(string = Read_Name, pattern = "^\\d") ~ "Patient_Sample",
      str_detect(string = Read_Name, pattern = "^Mock") ~ "Mock",
      str_detect(string = Read_Name, pattern = "_NA_|_NA2_") ~ "No_ID",
      str_detect(string = Read_Name, pattern = "EMPTY") ~ "Empty"
    )) %>% 
    
    # Body Site
    mutate(Body_Site = case_when(
      str_detect(string = Read_Name, pattern = "-N_") ~ "Nares",
      str_detect(string = Read_Name, pattern = "-P_") ~ "Perianal",
      str_detect(string = Read_Name, pattern = "-I_") ~ "Inguinal",
      str_detect(string = Read_Name, pattern = "-O_") ~ "Oropharynx",
      str_detect(string = Read_Name, pattern = "-A_") ~ "Abscess"
    )) %>% 
    # Add Study_ID
    mutate(Study_ID = case_when(
      str_detect(Read_Name, "^\\d") ~ str_replace(string = Read_Name,
                                                  pattern = "(^\\d{4}).*",
                                                  replacement = "\\1"),
      str_detect(Read_Name, "^\\D") ~ str_replace(string = Read_Name,
                                                  pattern = "(^.*)_S.*",
                                                  replacement = "\\1")))
  
  # Merge raw_read_info into metadata_filter
  full_metadata <- raw_reads_info %>% 
    left_join(metadata_filter, by = "Study_ID") %>% 
    select(-Study) %>% 
    select(Read_Name, Study_ID, everything())
  
  # Add Sample Names
  full_metadata_names <- full_metadata %>% 
    mutate(
      sample_name = basename(Read_Name) %>%
        str_replace(pattern = "^(\\d+-.+-.)_.*",
                    replacement = "\\1") %>%
        str_replace(pattern = "_.{2,3}_534R.*B$",
                    replacement = "")) %>% 
    relocate(sample_name)
  
  # Return cleaned tibble
  full_metadata_names
}
