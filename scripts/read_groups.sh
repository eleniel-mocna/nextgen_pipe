#!/bin/bash
# Input:
#   - path to the config file
#   - path to the sam file.
trap 'kill $(jobs -p)' EXIT

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
source "/scripts/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
is_done=$(is_already_done "$0" "${inputs[@]}")

for (( i=0; i<("${#inputs[@]}"); i++ )); do
    input_sam=${inputs[i]}
    realpath_input_sam=$(realpath "$input_sam")
    out_folder="$(dirname "$(realpath "$input_sam")")"
    output_file="$out_folder/${i}_$read_groups_OUT_FILENAME"
    if [ "$is_done" == false ]; then        
        {
            threads=$(get_threads "$read_groups_THREADS")
            docker exec gatk_oneDNA2pileup bash -c \
            "gatk AddOrReplaceReadGroups -I $realpath_input_sam -O $output_file -ID $read_groups_ID \
            -LB $read_groups_LB -PL $read_groups_PL -PU $read_groups_PU -SM $read_groups_SM \
            --VALIDATION_STRINGENCY $read_groups_VALIDATION_STRINGENCY --TMP_DIR $out_folder">/dev/null
            # This /\ for some reason prints some of the debug lines to stdout...
            log "EXIT STATUS ($?) for: gatk AddOrReplaceReadGroups -I $realpath_input_sam -O $output_file -ID $read_groups_ID \
            -LB $read_groups_LB -PL $read_groups_PL -PU $read_groups_PU -SM $read_groups_SM \
            --VALIDATION_STRINGENCY $read_groups_VALIDATION_STRINGENCY --TMP_DIR $out_folder"
            if [ "$read_groups_DELETE_INPUT" == "true" ]; then
                rm "$realpath_input_sam"
            fi
            give_back_threads "$threads"
        }&
        
    fi
    echo "$output_file"
    log "OUT: $output_file"
done
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait