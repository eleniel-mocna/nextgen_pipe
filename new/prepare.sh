#!/bin/bash
# This takes config file as the first argument and then
# triplets of:
#   - sample_name
#   - sample-fastq1.fq
#   - sample-fastq2.fq

# shellcheck source=/dev/null
source new/input_reader.sh

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"

# shellcheck disable=SC2154
if [ $(( "$inputs_length"%3 )) -ne 0 ]; then
    log "Invalid input type!"
    exit 1
fi
# shellcheck disable=SC2154 disable=SC1090
source "$config_file"

log "$config_file"
for (( i=0; i<("$inputs_length")/3; i++ )); do
    name=$(realpath "${inputs[((2*$i))]}")
    reads1=$(realpath "${inputs[((2*$i+1))]}")
    reads2=$(realpath "${inputs[((2*$i+2))]}")

    mkdir -p "$name"
    reads1_new="$name/$(basename -- "$reads1")"
    reads2_new="$name/$(basename -- "$reads2")"

    ln -sf "$reads1" "$reads1_new"
    ln -sf "$reads2" "$reads2_new"
    echo "$reads1_new"
    echo "$reads2_new"
done