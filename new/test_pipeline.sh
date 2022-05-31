#!/bin/bash

{
    pileups_cache="MS_logs/cached_pileups"
    merged_p_cache="MS_logs/cached_m_pileup"
    vcf_cache="MS_logs/cached_vcf"
    bam_cache="MS_logs/cached_bam"
    varfile_cache="MS_logs/cached_varfile"
    rc_cache="MS_logs/cached_rc"
    new/prepare.sh new/config_file.sh \
    MS_CTRL_results MS_data/VFND19-CTRL-EXOM_S5_merged_R1.fastq.gz MS_data/VFND19-CTRL-EXOM_S5_merged_R2.fastq.gz \
    MS_DG_results   MS_data/VFND19-DG-EXOM_S6_merged_R1.fastq.gz   MS_data/VFND19-DG-EXOM_S6_merged_R1.fastq.gz \
        | new/bwa_align.sh \
        | new/mark_duplicates.sh\
        | new/sort_sam.sh \
        | new/read_groups.sh >"$bam_cache"
    <"$bam_cache" new/split_bam.sh \
        | new/pileup.sh > "$pileups_cache"
    <"$pileups_cache" new/merge_pileup.sh>"$merged_p_cache"
    <"$pileups_cache" new/call_variants.sh \
        | new/merge_vcf.sh \
        | new/filter_vcf.sh >"$vcf_cache"
    <"$vcf_cache" new/create_varfile.sh>"$varfile_cache"
    new/merge_outputs.sh new/config_file.sh "$merged_p_cache" 1 "$varfile_cache" 1 | new/readcounts.sh | new/call_positions.sh>"$rc_cache"
    new/merge_outputs.sh new/config_file.sh "$bam_cache" 1 "$rc_cache" 1 | new/merge_vcf_w_coverage.sh
}&>MS_logs/log

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
# cvc.sh