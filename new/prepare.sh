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
# shellcheck source=/dev/null
source new/input_reader.sh

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ $(( "$inputs_length"%3 )) -ne 0 ] || [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    echo "Invalid input type! (Or help)">&2
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
# shellcheck disable=SC2154 
if [ "$this_is_just_a_test" -eq 1 ]; then
    echo "--test"
fi
echo "$config_file"
log "Loaded config file: $config_file"
# log "${inputs[0]}"
for (( i=0; i<("$inputs_length")/3; i++ )); do
    name=$(realpath "${inputs[((2*$i))]}")
    reads1=$(realpath "${inputs[((2*$i+1))]}")
    reads1_relative=$(realpath --relative-to="$name" "$reads1")
    reads2=$(realpath "${inputs[((2*$i+2))]}")
    reads2_relative=$(realpath --relative-to="$name" "$reads2")

    reads1_new="$name/$(basename -- "$reads1")"
    reads2_new="$name/$(basename -- "$reads2")"
    # shellcheck disable=SC2154 
    if [ "$this_is_just_a_test" -eq 0 ]; then
        mkdir -p "$name"
        ln -f "$reads1" "$reads1_new"
        ln -f "$reads2" "$reads2_new"
    else
        mkdir -p "$name"
        log "mkdir -p $name"
        cat>>"$reads1_new"<<<"ln -sf $reads1_relative" 
        log "ln -f $reads1_relative $reads1_new"
        cat>>"$reads2_new"<<<"ln -sf $reads2_relative" 
        log "ln -f $reads2_relative $reads2_new"
    fi
    echo "$reads1_new"
    echo "$reads2_new"
done