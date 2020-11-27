# Variables
raw_reads_dirs <- c("data/raw/SSTI/191127_M00623/samples/",
                    "data/raw/SSTI/191203_M02218/samples/",
                    "data/raw/SSTI/191203_M02282/samples/",
                    "data/raw/SSTI/191216_M02218/samples/")

# Drake Plan --------------------
plan <- drake_plan(
    
    # Sample Metadata
    raw_metadata = read_xls(file_in("data/raw/FB_090MetadataRequest_15JUL2019 update.xls")),
    ssti_metadata = process_metadata(raw_metadata),
    raw_reads_F = read_raw_reads(read_ending = "R1.fastq.gz"),
    raw_reads_R = read_raw_reads(read_ending = "R2.fastq.gz"),
    sample_names = get_sample_names(),
    raw_read_count = count_raw_reads(),
    
    # Raw read quality images
    raw_read_qual_plot_F = raw_read_quality_plot(read_ending = "R1.fastq.gz"),
    raw_read_qual_plot_R = raw_read_quality_plot(read_ending = "R2.fastq.gz")
    
    # Filter and trim reads
    

)

plan
