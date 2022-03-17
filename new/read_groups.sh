#!/bin/bash
# Input:
#   - path to the config file
#   - path to the sam file.

help(){
    echo "read_groups.sh: Adds or replaces read groups using gatk.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .bam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: read_groups.bam file">&2
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
log "STARTED"
# shellcheck disable=SC2154 disable=SC1090
for input_sam in "${inputs[@]}"; do
    realpath_input_sam=$(realpath "$input_sam")
    out_folder="$(dirname "$(realpath "$input_sam")")"
    output_file="$out_folder/${i}_$readGroups_OUT_FILENAME"
    
    docker exec gatk_oneDNA2pileup bash -c \
        "gatk AddOrReplaceReadGroups -I $realpath_input_sam -O $output_file -ID Nazev1 \
        -LB nazev2 -PL illumina -PU HiSeq2000 -SM Nazev3 \
        --VALIDATION_STRINGENCY SILENT --TMP_DIR $out_folder">/dev/null
        # This /\ for some reason prints some of the debug lines to stdout...
    
    echo "$output_file"
    log "ENDED"
done
