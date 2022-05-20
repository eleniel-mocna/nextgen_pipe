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
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"
N_ARGUMENTS=1
# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length"/"$N_ARGUMENTS"); i++ )); do
    input_sam=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$input_sam")")"
    output_file="$out_folder/${i}_$sortSam_OUT_FILENAME"
    if [ "$is_done" == false ]; then        
        {
            threads=$(get_threads "$sortSam_THREADS")
            docker exec gatk_oneDNA2pileup bash -c "gatk SortSamSpark -I $input_sam -O $output_file"        
            if [ "$sort_sam_DELETE_INPUT" == "true" ]; then
                rm "$input_sam"
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