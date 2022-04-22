#!/bin/bash

{
    pileups_cache="test_folder/cached_pileups"
    merged_p_cache="test_folder/cached_m_pileup"
    vcf_cache="test_folder/cached_vcf"
    sam_cache="test_folder/cached_sam"
    varfile_cache="test_folder/cached_varfile"
    fastqs_cache="test_folder/cached_fastqs"
    new/prepare.sh new/config_file.sh test_folder data/CRISPR-DNA_S2_merged_R1.fastq.gz data/CRISPR-DNA_S2_merged_R2.fastq.gz>"$fastqs_cache"
    <"$fastqs_cache" new/bwa_align.sh \
        | new/mark_duplicates.sh\
        | new/sort_sam.sh>"$sam_cache"
    <"$sam_cache" new/sam2bam.sh
    <"$sam_cache" new/read_groups.sh \
        | new/split_bam.sh \
        | new/pileup.sh > "$pileups_cache"
    <"$pileups_cache" new/merge_pileup>"$merged_p_cache"
    <"$pileups_cache" new/call_variants.sh \
        | new/merge_vcf.sh \
        | new/filter_vcf.sh>"$vcf_cache"
    <"$vcf_cache" new/snpSift.sh\
        | new/snpEff.sh
    <"$vcf_cache" new/create_varfile.sh>"$varfile_cache"
    <"$fastqs_cache" new/star_align.sh
    new/merge_outputs.sh new/config_file.sh "$merged_p_cache" 1 "$varfile_cache" 1 | new/readcounts.sh | new/call_positions.sh
}&>log220422

# DONE    bwa_align.sh
# DONE    call_positions.sh
# DONE    call_variants.sh
# NONV    config_file.sh
# DONE    create_varfile.sh
# DONE    filter_vcf.sh
# NONV    input_reader.sh
# DONE    mark_duplicates.sh
# DONE    merge_outputs.sh
# DONE    merge_pileup.sh
# DONE    merge_vcf.sh
# DONE    pileup.sh
# NONV    pipe_example.sh
# DONE    prepare.sh
# DONE    read_groups.sh
# DONE    readcounts.sh
# DONE    sam2bam.sh
# NONV    setupOneDNA2pileup.sh
# DONE    snpEff.sh
# DONE    snpSift.sh
# DONE    sort_sam.sh
# DONE    split_bam.sh
# DONE    star_align.sh
# NONV    template.sh
# NONV    test_pipeline.sh