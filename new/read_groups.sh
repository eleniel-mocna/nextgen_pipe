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
source "new/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/new/config_file.sh
source "$config_file"
echo "$config_file"
log  "OUT: $config_file"

# shellcheck disable=SC2154 disable=SC1090
is_done=$(is_already_done "$0" "${inputs[@]}")

for (( i=0; i<("${#inputs[@]}"); i++ )); do
    input_sam=${inputs[i]}
    realpath_input_sam=$(realpath "$input_sam")
    out_folder="$(dirname "$(realpath "$input_sam")")"
    output_file="$out_folder/${i}_$readGroups_OUT_FILENAME"
    if [ "$is_done" == false ]; then        
        {
            threads=$(get_threads "$readGroups_THREADS")
            docker exec gatk_oneDNA2pileup bash -c \
            "gatk AddOrReplaceReadGroups -I $realpath_input_sam -O $output_file -ID Nazev1 \
            -LB nazev2 -PL illumina -PU HiSeq2000 -SM Nazev3 \
            --VALIDATION_STRINGENCY SILENT --TMP_DIR $out_folder">/dev/null
            # This /\ for some reason prints some of the debug lines to stdout...
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