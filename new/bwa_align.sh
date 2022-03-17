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
# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo  "$config_file"

# shellcheck disable=SC2154 #$reference is loaded by the config file
log "Using reference in: $reference"
    
for (( i=0; i<("$inputs_length")/2; i++ )); do
    reads1=$(realpath "${inputs[((2*$i))]}")
    reads2=$(realpath "${inputs[((2*$i+1))]}")
    log "allignement of paired-end $reads1 $reads2"
    name=$(get_sample_name "$reads1")
    # shellcheck disable=SC2154 #$bwa_OUT_FILENAME is loaded by the config file
    output_file="$(dirname "$reads1")/${i}_$bwa_OUT_FILENAME"
    
    # echo "docker exec bwa_oneDNA2pileup bash -c \
    #     bwa mem -t 12 -M -R $(bwa_readGroupHeader "$name") $reference $reads1 $reads2" > "$output_file"

    docker exec bwa_oneDNA2pileup bash -c \
        "bwa mem -t 12 -M -R $(bwa_readGroupHeader "$name") $reference $reads1 $reads2" > "$output_file"
    echo "$output_file"
done