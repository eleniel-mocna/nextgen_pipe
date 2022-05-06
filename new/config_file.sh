#!/bin/bash
# shellcheck disable=SC2034
# /\ "variable not used" - this is a file for sourcing so this
# warning makes no sence.

redo_all=true

remove_after_done=false

reference="/reference/hg19.fa"
reference_vcf_header="/reference/hg19_header.vcf" # See reference_to_vcf_header.sh
out="out"

bwa_threads=12
bwa_timeout_per_sample=7200
bwa_readGroupHeader(){
    # shellcheck disable=SC2028 # Yes, that's the point :-)
    echo "\"@RG\tID:exomeID\tLB:exomeLB\tSM:$1\tPL:illumina\tPU:exomePU\""
}
bwa_OUT_FILENAME="bwa_aligned.sam"

star_align_OUT_FILENAME="star_aligned.sam"
star_align_REFERENCE="/data/Samuel_workdir/starRNA/star_genome" #TODO
star_THREADS=12

markDuplicates_OUT_FILENAME="marked_duplicates.sam"

sortSam_OUT_FILENAME="sorted.bam"
sortSam_THREADS=1

readGroups_OUT_FILENAME="read_groups.bam"
readGroups_THREADS=1

pileup_OUT_FILENAME="pile.pileup"
pileup_THREADS=1

callVariants_THREADS=1
callVariants_OUT_FILENAME="variants.vcf"


split_OUT_FILENAME="split_"
split_OUT_EXTENSION=".bam"

merge_vcf_OUT_FILENAME="merged.vcf"

filter_vcf_OUT_FILENAME="filtered.vcf"
filter_vcf_TMP_FILENAME="header.vcf"
filter_vcf_THREADS=1

create_varfile_OUT_FILENAME="varfile.txt"

readcounts_OUT_FILENAME="readcounts.txt"
readcounts_THREADS=1

merge_pileup_OUT_FILENAME="merged.pileup"

snpEff_OUT_FILENAME="annotated.vcf"
snpEff_THREADS=1

snpSift_OUT_FILENAME="sifted.vcf"
snpSift_DATABASE="/scripts/00-All.vcf"
snpSift_THREADS=1

sam2bam_THREADS=1

mutect2_OUT_FILENAME="mutect_variants.vcf"
mutect2_THREADS=16

call_positions_OUT_FILENAME="rc.vcf"
call_positions_THREADS=1
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

rerun_pipe=0

last_run_file="/scripts/last_run"

is_already_done(){
    tool_name="$1"
    arguments="$2"
    last_line_done=$(grep "#$tool_name# DONE:" "$last_run_file")
    # This has already been done.
    if [ -n "$last_line_done" ] && [ $redo_all != true ]; then
        echo true
    else # This hasn't been done.
        echo false
        last_line=$(grep "#$tool_name#" "$last_run_file")
        new_line="#$tool_name# started... $arguments"
        if [ -z "$last_line" ];then
            printf "\n%s\n" "$new_line">>$last_run_file
        else
            sed -i "s~$last_line~$new_line~" "$last_run_file"
            false
        fi
    fi    
}

mark_done(){
    tool_name="$1"
    arguments="$2"
    last_line="#$tool_name# started... $arguments"
    new_line="#$tool_name# DONE: $last_run_file"
    sed -i "s~$last_line~$new_line~" "$last_run_file"
}

multi_threader="/scripts/multi_threading/multi_threader.sh"
# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/new/multi_threading/multi_threader.sh
source "$multi_threader"
