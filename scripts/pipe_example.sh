#!/bin/bash

{
    time {
        scripts/prepare.sh scripts/config_file.sh CRISPR data/CRISPR-DNA_S2_merged_R1.fastq.gz data/CRISPR-DNA_S2_merged_R2.fastq.gz \
        | scripts/bwa_align.sh | scripts/mark_duplicates.sh\
        | scripts/sort_sam.sh | scripts/read_groups.sh | scripts/split_bam.sh | scripts/pileup.sh | scripts/call_variants.sh | scripts/merge_vcf.sh \
        | scripts/filter_vcf.sh
        # | tee \
        #     >(scripts/create_varfile.sh>/dev/null)\
        #     | scripts/snpSift.sh | scripts/snpEff.sh
    } }&>log.txt

{
time {
    scripts/split_bam.sh scripts/config_file.sh /data/Samuel_workdir/nextgen_pipe/CRISPR/1_sorted.bam | scripts/pileup.sh | scripts/call_variants.sh | scripts/merge_vcf.sh \
        | scripts/filter_vcf.sh \
        | tee \
            >(scripts/create_varfile.sh | scripts/readcounts.sh>/dev/null)\
            | scripts/snpSift.sh | scripts/snpEff.sh
    } }&>log.txt

{
time {
    find . | grep 'CRISPR/[0-9]*_variants.vcf' | scripts/merge_vcf.sh scripts/config_file.sh\
    | scripts/filter_vcf.sh \
        | tee \
            >(scripts/create_varfile.sh>/dev/null)\
            | scripts/snpSift.sh | scripts/snpEff.sh
} }&>log.txt

{
    time {
        scripts/sort_sam.sh scripts/config_file.sh /data/Samuel_workdir/nextgen_pipe/CRISPR/1_marked_duplicates.sam | scripts/read_groups.sh | scripts/split_bam.sh | scripts/pileup.sh | scripts/call_variants.sh | scripts/merge_vcf.sh \
        | scripts/filter_vcf.sh \
        | tee \
            >(scripts/create_varfile.sh>/dev/null)\
            | scripts/snpSift.sh | scripts/snpEff.sh
    } }&>log.txt