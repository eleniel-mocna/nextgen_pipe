#!/bin/bash
# Input:
#   - path to the config file
#   - paths to the sam files.
help(){
    echo "mark_duplicates.sh: Marks duplicates using spark.">&2
    echo "      Multithreading is provided by gatk spark.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .sam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: marked_duplicates.sam file">&2
}

# shellcheck source=/dev/null
source "/scripts/input_reader.sh"

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154
for input_sam in "${inputs[@]}"; do
    realpath_input_sam=$(realpath "$input_sam")
    out_folder="$(dirname "$(realpath "$realpath_input_sam")")"
    output_file="$out_folder/${i}_$markDuplicates_OUT_FILENAME"
    # docker exec gatk_oneDNA2pileup bash -c "java -jar /gatk/gatk.jar MarkDuplicatesSpark -I $realpath_input_sam -O $output_file --tmp-dir /ramdisk"
    if [ "$is_done" == false ]; then    
        {
            threads=$(get_threads "$filter_vcf_THREADS")        
            docker exec gatk_oneDNA2pileup bash -c "gatk MarkDuplicatesSpark -I $realpath_input_sam -O $output_file"
            log "EXIT STATUS ($?) for: gatk MarkDuplicatesSpark -I $realpath_input_sam -O $output_file"
            give_back_threads "$threads"
            if [ "$markDuplicates_DELETE_INPUT" == "true" ]; then
                rm "$realpath_input_sam"
            fi
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