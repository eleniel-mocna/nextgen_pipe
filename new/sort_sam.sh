#!/bin/bash
help(){
    echo "sort_sam.sh: Sorts the sam file using spark.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .sam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: sorted.bam file">&2
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
    output_file="$out_folder/$sortSam_OUT_FILENAME"
    docker exec gatk_oneDNA2pileup bash -c "gatk SortSamSpark -I $input_sam -O $output_file"
    echo "$output_file"
done