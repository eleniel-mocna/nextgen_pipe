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
    output_file="$out_folder/$pileup_OUT_FILENAME"

    for i in $(samtools idxstats "$input_sam" | cut -f 1 | grep chr); do echo "zde -> $i"; done
    echo "$output_file"
done
