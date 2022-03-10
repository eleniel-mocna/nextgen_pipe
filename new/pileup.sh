#!/bin/bash
# Input:
#   - path to the config file
#   - path to the sam file.

help(){
    echo "pileup.sh: Does a pileup using samtools mpileup">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .bam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: pile.pileup file">&2
}
# shellcheck source=/dev/null
source "new/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

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
