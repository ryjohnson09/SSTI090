plan <- drake_plan(
    
    # Sample Metadata
    raw_metadata = read_xls(file_in("data/raw/FB_090MetadataRequest_15JUL2019 update.xls")),
    ssti_metadata = process_metadata(raw_metadata),
    
    # Raw read quality images
    raw_read_qual_plot_F = raw_read_quality_plot(read_ending = "R1.fastq.gz"),
    raw_read_qual_plot_R = raw_read_quality_plot(read_ending = "R2.fastq.gz"),

)

plan
