fastqs_cache<-prepare("- test_folder data/CRISPR-DNA_S2_merged_R1.fastq.gz data/CRISPR-DNA_S2_merged_R2.fastq.gz")
sam_cache <-(bwa_align(fastqs_cache) %>% mark_duplicates %>% sort_sam)
bam_cache <-read_groups(sam_cache)
pileups_cache <- split_bam(bam_cache) %>% pileup
merged_p_cache <- merge_pileup(pileups_cache)
vcf_cache <- call_variants(pileups_cache) %>% merge_vcf %>% filter_vcf
snpSift(vcf_cache) %>% snpEff(vcf_cache)
varfile_cache <- create_varfile(vcf_cache)
star_align(fastqs_cache)
rc_cache <- merge_output_lists("-", merged_p_cache, varfile_cache) %>% readcounts %>% call_positions
merge_output_lists("-", bam_cache, rc_cache) %>% merge_vcf_w_coverage 
read_groups(sam_cache) %>% split_bam %>% mutect2
