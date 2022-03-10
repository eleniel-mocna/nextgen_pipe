#!/bin/bash
# Input:
#   - path to the config file
#   - path to the sam file.

# shellcheck source=/dev/null
source "new/input_reader.sh"
# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"

# shellcheck disable=SC2154 disable=SC1090
for input_sam in "${inputs[@]}"; do
    out_folder="$(dirname "$(realpath "$input_sam")")"
    filename=$(basename -- "$input_sam")
    filename="${filename%.*}"
    output_file="$out_folder/$filename.bam"
    docker exec samtools_oneDNA2pileup bash -c "samtools view -h -b $input_sam" > "$output_file"
    docker exec samtools_oneDNA2pileup bash -c "samtools index $output_file"
    echo "$output_file"    
done