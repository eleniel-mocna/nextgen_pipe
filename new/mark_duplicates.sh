#!/bin/bash
# Input:
#   - path to the config file
#   - paths to the sam files.
help(){
    echo "mark_duplicates.sh: Marks duplicates using spark.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .sam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: marked_duplicates.sam file">&2
}

# shellcheck source=/dev/null
source "new/input_reader.sh"
# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"
log Started
# shellcheck disable=SC2154 disable=SC1090
for input_sam in "${inputs[@]}"; do
    realpath_input_sam=$(realpath "$input_sam")
    out_folder="$(dirname "$(realpath "$realpath_input_sam")")"
    output_file="$out_folder/${i}_$markDuplicates_OUT_FILENAME"
    # docker exec gatk_oneDNA2pileup bash -c "java -jar /gatk/gatk.jar MarkDuplicatesSpark -I $realpath_input_sam -O $output_file --tmp-dir /ramdisk"
    docker exec gatk_oneDNA2pileup bash -c "gatk MarkDuplicatesSpark -I $realpath_input_sam -O $output_file"
    echo "$output_file"
    log 'Ended'
done
