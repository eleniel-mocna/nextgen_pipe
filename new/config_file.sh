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
bwa_DELETE_INPUT="false"

star_align_DELETE_INPUT="false"
star_align_sjdbOverhang=75
star_align_chimJunctionOverhangMin=15
star_align_chimSegmentMin=15
star_align_OUT_FILENAME="star_aligned.sam"
star_align_REFERENCE="/star_genome"
star_THREADS=12

markDuplicates_OUT_FILENAME="marked_duplicates.sam"
markDuplicates_DELETE_INPUT="false"

sortSam_DELETE_INPUT="false"
sortSam_OUT_FILENAME="sorted.bam"
sortSam_THREADS=1

read_groups_ID="Nazev1"
read_groups_LB="nazev2"
read_groups_PL="illumina"
read_groups_PU="HiSeq2000"
read_groups_SM="Nazev3"
read_groups_VALIDATION_STRINGENCY="SILENT"
read_groups_DELETE_INPUT="false"
read_groups_OUT_FILENAME="read_groups.bam"
read_groups_THREADS=1

pileup_DELETE_INPUT="false"
pileup_OUT_FILENAME="pile.pileup"
pileup_THREADS=1

call_variants_DELETE_INPUT="false"
call_variants_p_value=1
call_variants_min_coverage=7
call_variants_min_reads=2
call_variants_min_var_freq=0.05
call_variants_strand_filter=0
call_variants_variants=1
call_variants_THREADS=1
call_variants_OUT_FILENAME="variants.vcf"

split_bam_DELETE_INPUT="false"
split_bam_OUT_FILENAME="split_"
split_bam_OUT_EXTENSION=".bam"

merge_vcf_DELETE_INPUT="false"
merge_vcf_OUT_FILENAME="merged.vcf"

filter_vcf_DELETE_INPUT="false"
filter_vcf_OUT_FILENAME="filtered.vcf"
filter_vcf_TMP_FILENAME="header.vcf"
filter_vcf_THREADS=1

create_varfile_DELETE_INPUT="false"
create_varfile_OUT_FILENAME="varfile.txt"

readcounts_memory="-Xmx5g" #In format `-Xmx[amount]` e.g `-Xmx5g`
readcounts_min_coverage=0
readcounts_min_base_qual=0
readcounts_DELETE_INPUT="false"
readcounts_OUT_FILENAME="readcounts.txt"
readcounts_THREADS=1

merge_pileup_DELETE_INPUT="false"
merge_pileup_OUT_FILENAME="merged.pileup"

merge_outputs_DELETE_INPUT="false"

merge_vcf_w_coverage_MINQUAL=0
merge_vcf_w_coverage_MINBASEQ=0
merge_vcf_w_coverage_DELETE_INPUT="false"
merge_vcf_w_coverage_BEDTMP="tmp.bed"
merge_vcf_w_coverage_DEPTHSTMP="tmp.depths"
merge_vcf_w_coverage_OUT_FILENAME="merged_w_coverage.vcf"

snpEff_maxMemory="-Xmx5g" #In format `-Xmx[amount]` e.g `-Xmx5g`
snpEff_REFERENCE="hg19"
snpEff_DELETE_INPUT="false"
snpEff_OUT_FILENAME="annotated.vcf"
snpEff_THREADS=1

snpSift_DELETE_INPUT="false"
snpSift_OUT_FILENAME="sifted.vcf"
snpSift_DATABASE="/scripts/00-All.vcf"
snpSift_THREADS=1

sam2bam_DELETE_INPUT="false"
sam2bam_THREADS=1

mutect2_DELETE_INPUT="false"
mutect2_OUT_FILENAME="mutect_variants.vcf"
mutect2_THREADS=16

call_positions_OUT_FILENAME="rc.vcf"
call_positions_THREADS=1
call_positions_DELETE_INPUT="false"

merge_vcf_w_coverage_MINBASEQ=0
merge_vcf_w_coverage_MINQUAL=0
merge_vcf_w_coverage_DEPTHSTMP="tmp.depths"
merge_vcf_w_coverage_BEDTMP="tmp.bed"
merge_vcf_w_coverage_OUT_FILENAME="merged_w_coverage.vcf"
merge_vcf_w_coverage_THREADS=1

cvc_DELETE_INPUT="false"
cvc_THREADS=1
cvc_OUT_FILENAME="cvc_variants.vcf"

get_folder(){
    basename "$(dirname "$1")"
}

get_sample_name(){
    get_folder "$1"
}

log(){
    echo "[$0]: $1">&2
    echo "[$0]: $1">"NGS.log"
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

multi_threader="/multi_threader/multi_threader.sh"
# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/new/multi_threading/multi_threader.sh
source "$multi_threader"
