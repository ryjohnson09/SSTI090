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
    filt_reads_F = setNames(paste0("data/processed/filtered_reads/", sample_names, "_F_filt.fastq.gz"),
                            sample_names),
    filt_reads_R = setNames(paste0("data/processed/filtered_reads/", sample_names, "_R_filt.fastq.gz"),
                            sample_names),
    raw_read_count = count_raw_reads(sample_names, raw_reads_F),
    
    # Raw read quality images
    raw_read_qual_plot_F = raw_read_quality_plot(read_ending = "R1.fastq.gz"),
    raw_read_qual_plot_R = raw_read_quality_plot(read_ending = "R2.fastq.gz"),
    
    # Trim and filter
    trim_filt_out = trim_and_filter(sample_names, raw_reads_F, raw_reads_R, filt_reads_F, filt_reads_R,
                                    output = file_out("data/processed/filtered_reads")),
    
    # Error rates
    error_F = target(command = learnErrors(fls = filt_reads_F),
                     trigger = trigger(condition = file_in("data/processed/filtered_reads"))),
    error_R = target(command = learnErrors(fls = filt_reads_R),
                     trigger = trigger(condition = file_in("data/processed/filtered_reads"))),
    
    # Sample Inference
    infered_seqs_F = dada(filt_reads_F, err = error_F),
    infered_seqs_R = dada(filt_reads_R, err = error_R),
    
    # Merge Sequences
    merged_seqs = mergePairs(infered_seqs_F, 
                             filt_reads_F,
                             infered_seqs_R,
                             filt_reads_R, 
                             verbose = TRUE),
    
    # Make sequence table
    seqtab = makeSequenceTable(merged_seqs),
    
    # Trim sequence table to appropriate length
    seqtab_trim = seqtab[,nchar(colnames(seqtab)) %in% 450:510],
    
    # Remove Chimera
    seqtab_nochim = removeBimeraDenovo(seqtab_trim, method = "consensus"),
    
    # Track reads
    track_read_results = track_reads(
        trim_filt_out,
        infered_seqs_F,
        infered_seqs_R,
        merged_seqs,
        seqtab_nochim,
        sample_names
    ),
    
    # Assign Taxonomy (using DECIPHER)
    taxa = assign_taxonomy(seqtab_nochim, 
                           silva_file = file_in("data/raw/SILVA_SSU_r138_2019.rdata")),
    
    # Create Phyloseq Object
    ps = create_ps(seqtab_nochim, taxa, ssti_metadata),
    
    # Filter ps based on taxa (check report for phylum representation)
    ps_taxa = subset_taxa(ps, !is.na(phylum) & !phylum %in% c("", 
                                                          "Elusimicrobiota", 
                                                          "Fibrobacterota", 
                                                          "Nitrospirota",
                                                          "Dependentiae",
                                                          "Abditibacteriota",
                                                          "Armatimonadota",
                                                          "Bdellovibrionota",
                                                          "Verrucomicrobiota",
                                                          "WPS-2")),
    # Filter ps_taxa based on prevalence (check report for prevalence)
    ps_taxa_prev = subset_taxa(ps_taxa, !phylum %in% c("Myxococcota",
                                                       "Planctomycetota",
                                                       "Gemmatimonadota")),
    # Filter ASVs by prevalence threshold (check report for threshold)
    ps_filt = prev_threshold_filter(ps_taxa_prev),
    # Save final ps
    ps_out = saveRDS(ps_filt, file_out("data/processed/ps_filt.rds")),
    
    
    #############################################
    # Results #
    
    # Phylum Relative Abundance
    ps_phylum = tax_glom(ps_filt, "phylum", NArm = TRUE),
    ps_phylum_relabun = transform_sample_counts(ps_phylum, function(OTU) OTU/sum(OTU) * 100),
    
    # Genus Relative Abundance
    ps_genus = tax_glom(ps_filt, "genus", NArm = TRUE),
    ps_genus_relabun = transform_sample_counts(ps_genus, function(OTU) OTU/sum(OTU) * 100),
    
    # Alpha Diveristy Metrics
    ps_alpha = estimate_richness(ps_filt, measures = c("Observed", "Shannon", "Chao1",
                                                       "Simpson", "InvSimpson")),
    
    
    
    
    # Reports
    report_process = rmarkdown::render(
        knitr_in("SSTI090_processing.Rmd"),
        output_file = file_out("SSTI090_processing.html"),
        quiet = TRUE),
    report_results = rmarkdown::render(
        knitr_in("SSTI090_results.Rmd"),
        output_file = file_out("SSTI090_results.html"),
        quiet = TRUE)
)

plan
