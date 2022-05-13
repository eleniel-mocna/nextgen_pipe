#!/bin/bash
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
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
realpath "$config_file"
log  "OUT: $config_file"

# shellcheck disable=SC2154 
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 
for (( i=0; i<("${#inputs[@]}"); i++ )); do
    input_bam=${inputs[i]}
    realpath_input_bam=$(realpath "$input_bam")
    out_folder="$(dirname "$(realpath "$input_bam")")"
    output_file="$out_folder/${i}_$pileup_OUT_FILENAME"    
    if [ "$is_done" == false ]; then    
        {
            threads=$(get_threads "$pileup_THREADS")
            docker exec samtools_oneDNA2pileup bash -c "samtools mpileup -f $reference -B $realpath_input_bam" > "$output_file"
            sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$output_file" # This removes all but one newline at the end of the pileup.
            if [ "$pileup_DELETE_INPUT" == "true" ]; then
                rm "$realpath_input_bam"
            fi
            give_back_threads "$threads"
        }&
    fi
    # for i in $(samtools idxstats "$realpath_input_bam" | cut -f 1 | grep chr); do echo "zde -> $i"; done
    echo "$output_file"
    log "OUT: $output_file"
done
wait
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
log "ENDED"
