#!/bin/bash
help(){
    echo "readcounts.sh: Prepare a pileup on all positions with variants..">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - pile.pileup">&2
    echo "      - varfile.txt">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - readcounts.txt">&2
}
# shellcheck source=/dev/null
source "/scripts/input_reader.sh"
N_ARGUMENTS=2
# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ $(( "$inputs_length"%"$N_ARGUMENTS" )) -ne 0 ] || [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    echo "Invalid input type! (Or help)">&2
    help
    exit 1
fi

is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    pileup=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    varfile=$(realpath "${inputs[((N_ARGUMENTS*$i+1))]}")

    out_folder="$(dirname "$(realpath "$pileup")")" 
    output_file="$out_folder/$readcounts_OUT_FILENAME" 
    
    
    if [ "$is_done" == false ]; then    
        {
            threads=$(get_threads "$readcounts_THREADS")
            docker exec varScan_oneDNA2pileup    bash -c "java $readcounts_memory -jar VarScan.jar readcounts $pileup \
                --min-coverage $readcounts_min_coverage --min-base-qual $readcounts_min_base_qual \
                 --output-file  $output_file --variants-file $varfile">/dev/null
            log "EXIT STATUS ($?) for: java $readcounts_memory -jar VarScan.jar readcounts $pileup \
                --min-coverage $readcounts_min_coverage --min-base-qual $readcounts_min_base_qual \
                 --output-file  $output_file --variants-file $varfile"
            if [ "$readcounts_DELETE_INPUT" == "true" ]; then
                rm "$pileup" "$varfile"
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