#!/bin/bash

new/prepare.sh new/config_file.sh CRISPR data/CRISPR-DNA_S2_merged_R1.fastq.gz data/CRISPR-DNA_S2_merged_R2.fastq.gz \
    | new/bwa_align.sh | new/mark_duplicates.sh\
    | new/sort_sam.sh | new/read_groups.sh | new/split_bam.sh | new/pileup.sh | new/call_variants.sh | new/merge_vcf.sh


new/read_groups.sh new/config_file.sh 2843_Bc_F1/sorted.bam 