# Variables
raw_reads_dirs <- c("data/raw/SSTI/191127_M00623/samples",
                    "data/raw/SSTI/191203_M02218/samples",
                    "data/raw/SSTI/191203_M02282/samples",
                    "data/raw/SSTI/191216_M02218/samples")

# Drake Plan --------------------
plan <- drake_plan(
    
    # Sample Metadata
    raw_metadata = read_xls(file_in("data/raw/FB_090MetadataRequest_15JUL2019 update.xls")),
    ssti_metadata = process_metadata(raw_metadata),
    raw_reads_F = read_raw_reads(read_ending = "R1.fastq.gz"),
    raw_reads_R = read_raw_reads(read_ending = "R2.fastq.gz"),
    sample_names = get_sample_names(raw_reads_F),
    raw_read_count = count_raw_reads(sample_names, raw_reads_F),
    
    # Raw read quality images
    raw_read_qual_plot_F = raw_read_quality_plot(read_ending = "R1.fastq.gz"),
    raw_read_qual_plot_R = raw_read_quality_plot(read_ending = "R2.fastq.gz"),
    
    # Trim and filter
    trim_filt_out = trim_and_filter(sample_names, raw_reads_F, raw_reads_R,
                                    output = file_out("data/processed/filtered_reads")),
    
    # Error rates
    error_F = learnErrors(fls = paste0("data/processed/filtered_reads/", 
                                       sample_names, 
                                       "_F_filt.fastq.gz")),
    error_R = learnErrors(fls = paste0("data/processed/filtered_reads/", 
                                       sample_names, 
                                       "_R_filt.fastq.gz")),
    
    # Sample Inference
    infered_seqs_F = dada(paste0("data/processed/filtered_reads/", 
                                 sample_names, 
                                 "_F_filt.fastq.gz"), err = error_F),
    infered_seqs_R = dada(paste0("data/processed/filtered_reads/", 
                                 sample_names, 
                                 "_R_filt.fastq.gz"), err = error_R),
    
    # Merge Sequences
    merged_seqs = mergePairs(infered_seqs_F, 
                             paste0("data/processed/filtered_reads/", 
                                    sample_names, 
                                    "_F_filt.fastq.gz"),
                              infered_seqs_R,
                              paste0("data/processed/filtered_reads/", 
                                     sample_names, 
                                     "_R_filt.fastq.gz"), 
                              verbose = TRUE),
    
    
    # Report
    report = rmarkdown::render(
        knitr_in("SSTI090_report.Rmd"),
        output_file = file_out("SSTI090_report.html"),
        quiet = TRUE)
)

plan
