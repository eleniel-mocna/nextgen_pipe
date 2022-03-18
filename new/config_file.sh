#!/bin/bash
# shellcheck disable=SC2034
# /\ "variable not used" - this is a file for sourcing so this
# warning makes no sence.


reference="/reference/hg19.fa"
out="out"
bwa_threads=12
bwa_readGroupHeader(){
    # shellcheck disable=SC2028 # Yes, that's the point :-)
    echo "\"@RG\tID:exomeID\tLB:exomeLB\tSM:$1\tPL:illumina\tPU:exomePU\""
}
bwa_OUT_FILENAME="bwa_aligned.sam"

markDuplicates_OUT_FILENAME="marked_duplicates.sam"

sortSam_OUT_FILENAME="sorted.bam"

readGroups_OUT_FILENAME="read_groups.bam"

pileup_OUT_FILENAME="pile.pileup"

callVariants_OUT_FILENAME="variants.vcf"


split_OUT_FILENAME="split_"
split_OUT_EXTENSION=".bam"

merge_vcf_OUT_FILENAME="merged.vcf"
# get_filename(){    
#     filename=$(basename -- "$1")
#     filename="${filename%.*}"
#     mkdir -p "$filename"
#     echo "$filename"
# }

get_folder(){
    basename "$(dirname "$1")"
}

get_sample_name(){
    get_folder "$1"
}

log(){
    echo "[$0]: $1">&2
}
trap 'kill $(jobs -p)' EXIT
# echo "Config loaded">&2
