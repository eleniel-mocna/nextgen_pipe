#!/bin/bash
help(){
    echo "merge_outputs.sh: Interlace two or more outputs from pipeline together.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Pairs of:">&2
    echo "      - File with a pipeline output.">&2
    echo "      - number of outputs per sample">&2
    echo "      - ...">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - Pipeline output">&2
}
# shellcheck source=/dev/null
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"
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

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
realpath "$config_file"
log  "OUT: $config_file"

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    output_file=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    lines_per_sample="${inputs[((N_ARGUMENTS*$i+1))]}"
    (( n_samples=($( wc -l "$output_file" | cut -f 1 -d' ' ) -1 )/"$lines_per_sample" ))
    if [ -z "$old_n_samples" ]; then
        old_n_samples=$n_samples
    else
        if [ ! "$old_n_samples" -eq "$n_samples" ]; then
            log "Warning: number of samples in files are different! ($old_n_samples X $n_samples)"
        fi
    fi
    args+=" $output_file $lines_per_sample "
    log "USED: $output_file, $lines_per_sample"
done

docker exec python_oneDNA2pileup bash -c "python python-scripts/merge_outputs.py $args"
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    output_file=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    lines_per_sample="${inputs[((N_ARGUMENTS*$i+1))]}"
    
    # shellcheck disable=SC2154 
    if [ "$merge_outputs_DELETE_INPUT" == "true" ]; then
        rm "$output_file"
    fi
done

wait