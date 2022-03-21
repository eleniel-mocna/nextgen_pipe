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
        if [ -z "$first" ]; then       
            first='false'
            out_folder="$(dirname "$(realpath "$input_pileup")")"
            # shellcheck disable=SC2154 # From config file
            output_file="$out_folder/$merge_pileup_OUT_FILENAME"
            cp "$input_pileup" "$output_file"  
        else
            ((i+=1))
            pileups[i]="$input_pileup"   
        fi
    done
    cat "${pileups[@]}">>"$output_file"
    echo "$output_file"
}

# This takes all given files, separates them by folders
# and then merges them folderwise

# shellcheck source=/dev/null
source new/input_reader.sh
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
echo "$config_file"
# shellcheck disable=SC2154 disable=SC1090
declare -A folders
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    given_pileup=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$given_pileup")")"
    folders[$out_folder]+="$given_pileup;"
done
for files_in_folder in "${folders[@]}"
do
    merge "$files_in_folder"
done

# This removes some warning lines which are for whatever reason
# sometimes generated with the cat command.
# (Maybe todo)
# mv "$output_file" "${output_file}_tmp" 
# < "${output_file}_tmp" sed '/\[/d'>"$output_file"
# rm "${output_file}_tmp"