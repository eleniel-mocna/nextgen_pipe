#!/bin/bash
help(){
    echo "merge_pileup.sh: Take paths to pileup files,">&2
    echo "          merge all of them that are in the same directiory.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each pileup">&2
    echo "      - file.pileup">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each directory from INPUT">&2
    echo "      - merged.pileup">&2
}

# This merges all ';'-separated pileup files (all should be in the same folder)
# By taking the header from the frist one and then ignoring headers.
merge(){
    unset first
    unset pileups
    # Split given string by ;
    for input_pileup in $(echo "$1" | tr ";" "\n")
    do
        out_folder="$(dirname "$(realpath "$input_pileup")")"
        # shellcheck disable=SC2154
        output_file="$out_folder/$merge_pileup_OUT_FILENAME"
        ((i+=1))
        pileups[i]="$input_pileup"   
    done
    cat "${pileups[@]}">"$output_file"
    # shellcheck disable=SC2154
    if [ "$merge_pileup_DELETE_INPUT" == "true" ]; then
        rm "${pileups[@]}"
    fi
    log "OUT: $output_file"
    echo "$output_file"
}

# This takes all given files, separates them by folders
# and then merges them folderwise

# shellcheck source=/dev/null
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"
N_ARGUMENTS=1
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
is_done=$(is_already_done "$0" "${inputs[@]}")

declare -A folders
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    given_pileup=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$given_pileup")")"
    folders[$out_folder]+="$given_pileup;"
done
if [ "$is_done" == false ]; then    
    for files_in_folder in "${folders[@]}"
    do
        {
            threads=$(get_threads 1)
            merge "$files_in_folder"
            give_back_threads "$threads"
        }&
    done
fi
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait

# This removes some warning lines which are for whatever reason
# sometimes generated with the cat command.
# (Maybe todo)
# mv "$output_file" "${output_file}_tmp" 
# < "${output_file}_tmp" sed '/\[/d'>"$output_file"
# rm "${output_file}_tmp"