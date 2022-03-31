#!/bin/bash
# This takes config file as the first argument and then
# pairs of:
#   - sample-fastq1.fq
#   - sample-fastq2.fq
help(){
    echo "bwa_align.sh: Aligns fastq files using bwa mem.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Pairs of:">&2
    echo "      - sample_fastq1.fq">&2
    echo "      - sample_fastq2.fq">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every pair:">&2
    echo "      - bwa_aligned.sam">&2


}
# shellcheck source=/dev/null
source new/input_reader.sh

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/new/config_file.sh
source "$config_file"
echo  "$config_file"
log  "OUT: $config_file"
is_done=$(is_already_done "$0" "${inputs[@]}")
# shellcheck disable=SC2154 #$reference is loaded by the config file

(( timeout="$inputs_length"*"$bwa_timeout_per_sample"/2 ))
for (( i=0; i<("$inputs_length")/2; i++ )); do
    threads=$(get_threads $bwa_threads $timeout)
    reads1=$(realpath "${inputs[((2*$i))]}")
    reads2=$(realpath "${inputs[((2*$i+1))]}")
    log "allignement of paired-end $reads1 $reads2"
    name=$(get_sample_name "$reads1")
    # shellcheck disable=SC2154 #$bwa_OUT_FILENAME is loaded by the config file
    output_file="$(dirname "$reads1")/${i}_$bwa_OUT_FILENAME"
    
    # echo "docker exec bwa_oneDNA2pileup bash -c \
    #     bwa mem -t 12 -M -R $(bwa_readGroupHeader "$name") $reference $reads1 $reads2" > "$output_file"
    if [ "$is_done" == false ]; then        
        {
        threads=$(get_threads $bwa_threads $timeout)
        docker exec bwa_oneDNA2pileup bash -c \
            "bwa mem -t $threads -M -R $(bwa_readGroupHeader "$name") $reference $reads1 $reads2" > "$output_file"
        give_back_threads "$threads"
        }&
    fi
    echo "$output_file"
    log  "OUT: $output_file"
done
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait