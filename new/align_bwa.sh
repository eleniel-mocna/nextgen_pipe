#!/bin/bash

# Input:
#   - path to the config file
#   - path to the first fastq file
#   - path to the second fastq file
#   - ...

# shellcheck source=/dev/null
source "new/input_reader.sh"

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# echo "${inputs[@]}"
# echo "$inputs_length"
if [ $(( "$inputs_length"%2 )) -ne 0 ]; then
    echo "Invalid input type!" >&2
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"

for (( i=0; i<("$inputs_length")/2; i++ )); do
    reads1="${inputs[((2*$i))]}"
    reads2="${inputs[((2*$i+1))]}"
    sample_name=$(get_folder "$reads1")
    out=$(dirname "$reads1")

    # echo "reads1: $reads1, reads2: $reads2"
    echo "allignement of paired-end $reads1 $reads2">&2

    # Reference is loaded in $config_file
    # shellcheck disable=SC2154
    echo "reference $reference">&2

    # echo "docker exec bwa_oneDNA2pileup bash -c bwa mem -t $bwa_threads -M -R $( bwa_readGroupHeader "$out") $reference $reads1 $reads2" > "$out/$bwa_OUT_FILENAME"
    # shellcheck disable=SC2154
    docker exec bwa_oneDNA2pileup bash -c "bwa mem -t $bwa_threads -M -R $( bwa_readGroupHeader "$sample_name") $reference $reads1 $reads2" > "$out/$bwa_OUT_FILENAME"
    echo "$out/$bwa_OUT_FILENAME"
done
