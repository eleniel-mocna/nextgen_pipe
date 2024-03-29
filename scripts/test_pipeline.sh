#!/bin/bash

{   
    time 
    {
        pileups_cache="MS_logs/cached_pileups"
        merged_p_cache="MS_logs/cached_m_pileup"
        vcf_cache="MS_logs/cached_vcf"
        bam_cache="MS_logs/cached_bam"
        varfile_cache="MS_logs/cached_varfile"
        rc_cache="MS_logs/cached_rc"
        scripts/prepare.sh scripts/config_file.sh \
        MS_CTRL_results1 MS_data/VFND19-CTRL-EXOM_S5_merged_R1.fastq.gz MS_data/VFND19-CTRL-EXOM_S5_merged_R2.fastq.gz \
        MS_DG_results1   MS_data/VFND19-DG-EXOM_S6_merged_R1.fastq.gz   MS_data/VFND19-DG-EXOM_S6_merged_R2.fastq.gz \
            | scripts/bwa_align.sh \
            | scripts/mark_duplicates.sh\
            | scripts/sort_sam.sh \
            | scripts/read_groups.sh >"$bam_cache"
        <"$bam_cache" scripts/split_bam.sh \
            | scripts/pileup.sh > "$pileups_cache"
        <"$pileups_cache" scripts/merge_pileup.sh>"$merged_p_cache"
        <"$pileups_cache" scripts/call_variants.sh \
            | scripts/merge_vcf.sh \
            | scripts/filter_vcf.sh >"$vcf_cache"
        <"$vcf_cache" scripts/create_varfile.sh>"$varfile_cache"
        scripts/merge_outputs.sh scripts/config_file.sh "$merged_p_cache" 1 "$varfile_cache" 1 | scripts/readcounts.sh | scripts/call_positions.sh>"$rc_cache"
        scripts/merge_outputs.sh scripts/config_file.sh "$bam_cache" 1 "$rc_cache" 1 | scripts/merge_vcf_w_coverage.sh
    }
}&>MS_logs/log2

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