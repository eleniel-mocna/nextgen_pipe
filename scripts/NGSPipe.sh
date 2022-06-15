#!/bin/bash

########################
# HELP AND DESCRIPTION #
########################

help(){ # TODO Rewrite these help prints.
    echo "NGSPipe.sh: the whole pipeline for NGS.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Triplets of:">&2
    echo "      - sample_name">&2
    echo "      - sample_fastq1.fq">&2
    echo "      - sample_fastq2.fq">&2
}

# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe//scripts/input_reader.sh
source "/scripts/input_reader.sh"
name="${inputs[0]}"
mkdir -p "$name"
{   
    time {
        pileups_cache="$name/cached_pileups"
        merged_p_cache="$name/cached_m_pileup"
        vcf_cache="$name/cached_vcf"
        bam_cache="$name/cached_bam"
        varfile_cache="$name/cached_varfile"
        rc_cache="$name/cached_rc"
        /scripts/prepare.sh "$config_file" "${inputs[@]}" \
            | /scripts/bwa_align.sh \
            | /scripts/mark_duplicates.sh\
            | /scripts/sort_sam.sh \
            | /scripts/read_groups.sh >"$bam_cache"
        <"$bam_cache" /scripts/split_bam.sh \
            | /scripts/pileup.sh > "$pileups_cache"
        <"$pileups_cache" /scripts/merge_pileup.sh>"$merged_p_cache"
        <"$pileups_cache" /scripts/call_variants.sh \
            | /scripts/merge_vcf.sh >"$vcf_cache"
        <"$vcf_cache" /scripts/create_varfile.sh>"$varfile_cache"
        /scripts/merge_outputs.sh /scripts/config_file.sh "$merged_p_cache" 1 "$varfile_cache" 1 | /scripts/readcounts.sh | /scripts/call_positions.sh>"$rc_cache"
        /scripts/merge_outputs.sh /scripts/config_file.sh "$bam_cache" 1 "$rc_cache" 1 | /scripts/merge_vcf_w_coverage.sh
    }
}&>"$name/log"