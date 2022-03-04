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
    output_file="$out_folder/$sortSam_OUT_FILENAME"
    docker exec gatk_oneDNA2pileup bash -c \
    "gatk AddOrReplaceReadGroups -I $input_sam -O $output_file -ID Nazev1\
    -LB nazev2 -PL illumina -PU HiSeq2000 -SM Nazev3\
    --VALIDATION_STRINGENCY SILENT --TMP_DIR $out_folder"
    echo "$output_file"
done
