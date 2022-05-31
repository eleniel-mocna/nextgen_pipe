#!/bin/bash
# This takes config file as the first argument and then
# triplets of:
#   - sample_name
#   - sample-fastq1.fq
#   - sample-fastq2.fq
help(){
    echo "prepare.sh: Prepares a folder with linked fastq files.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Triplets of:">&2
    echo "      - sample_name">&2
    echo "      - sample_fastq1.fq">&2
    echo "      - sample_fastq2.fq">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - Pairs of:">&2
    echo "      - sample_fastq1.fq:">&2
    echo "      - sample_fastq2.fq:">&2
}
# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/new/input_reader.sh
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ $(( "$inputs_length"%3 )) -ne 0 ] || [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    echo "Invalid input type! (Or help)">&2
    help
    exit 1
fi

# shellcheck disable=SC2154 
if [ "$this_is_just_a_test" -eq 1 ]; then
    echo "--test"
fi
# log "${inputs[0]}"

# shellcheck disable=SC2154
set_threads "$prepare_NTHREADS"

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154
for (( i=0; i<("$inputs_length")/3; i++ )); do
    name=$(realpath "${inputs[((3*$i))]}")
    reads1=$(realpath "${inputs[((3*$i+1))]}")
    reads2=$(realpath "${inputs[((3*$i+2))]}")

    reads1_new="$name/$(basename -- "$reads1")"
    reads2_new="$name/$(basename -- "$reads2")"
    # shellcheck disable=SC2154 
    if [ "$is_done" == false ]; then    
        mkdir -p "$name"
        ln -f "$reads1" "$reads1_new"
        log "EXIT STATUS ($?) for: ln -f $reads1 $reads1_new"
        ln -f "$reads2" "$reads2_new"    
        log "EXIT STATUS ($?) for: ln -f $reads2 $reads2_new"
    fi
    echo "$reads1_new"    
    log "$reads1_new"
    echo "$reads2_new"
    log "$reads2_new"
done
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait