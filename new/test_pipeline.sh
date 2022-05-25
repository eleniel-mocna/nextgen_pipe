#!/bin/bash

{
    pileups_cache="new_test_folder/cached_pileups"
    merged_p_cache="new_test_folder/cached_m_pileup"
    vcf_cache="new_test_folder/cached_vcf"
    sam_cache="new_test_folder/cached_sam"
    bam_cache="new_test_folder/cached_bam"
    varfile_cache="new_test_folder/cached_varfile"
    fastqs_cache="new_test_folder/cached_fastqs"
    rc_cache="new_test_folder/cached_rc"
    new/split_bam.sh new/config_file.sh new_test_folder/sorted.bam\
        | new/pileup.sh > "$pileups_cache"
    <"$pileups_cache" new/merge_pileup.sh>"$merged_p_cache"
    <"$pileups_cache" new/call_variants.sh \
        | new/merge_vcf.sh \
        | new/filter_vcf.sh >"$vcf_cache"
    # <"$vcf_cache" new/snpSift.sh\
    #     | new/snpEff.sh
    <"$vcf_cache" new/create_varfile.sh>"$varfile_cache"
    # <"$fastqs_cache" new/star_align.sh
    new/merge_outputs.sh new/config_file.sh "$merged_p_cache" 1 "$varfile_cache" 1 | new/readcounts.sh | new/call_positions.sh>"$rc_cache"
    new/merge_vcf_w_coverage.sh new_test_folder/sorted.bam new_test_folder/rc.vcf | new/vep.sh
    # <"$sam_cache" new/read_groups.sh \
    #     | new/split_bam.sh| new/mutect2.sh
}&>log220520

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