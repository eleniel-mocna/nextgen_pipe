#!/bin/bash

{
    time {
        new/prepare.sh new/config_file.sh CRISPR data/CRISPR-DNA_S2_merged_R1.fastq.gz data/CRISPR-DNA_S2_merged_R2.fastq.gz \
        | new/bwa_align.sh | new/mark_duplicates.sh\
        | new/sort_sam.sh | new/read_groups.sh | new/split_bam.sh | new/pileup.sh | new/call_variants.sh | new/merge_vcf.sh \
        | new/filter_vcf.sh \
        | tee \
            >(new/create_varfile.sh>/dev/null)\
            | new/snpSift.sh | new/snpEff.sh
    } }&>log.txt

{
time {
    new/split_bam.sh new/config_file.sh /data/Samuel_workdir/nextgen_pipe/CRISPR/1_sorted.bam | new/pileup.sh | new/call_variants.sh | new/merge_vcf.sh \
        | new/filter_vcf.sh \
        | tee \
            >(new/create_varfile.sh | new/readcounts.sh>/dev/null)\
            | new/snpSift.sh | new/snpEff.sh
    } }&>log.txt

{
time {
    find . | grep 'CRISPR/[0-9]*_variants.vcf' | new/merge_vcf.sh new/config_file.sh\
    | new/filter_vcf.sh \
        | tee \
            >(new/create_varfile.sh>/dev/null)\
            | new/snpSift.sh | new/snpEff.sh
} }&>log.txt