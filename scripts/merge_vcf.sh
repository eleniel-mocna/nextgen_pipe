#!/bin/bash
help(){
    echo "merge_vcf.sh: Take paths to vcf files,">&2
    echo "          merge all of them that are in the same directiory.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each vcf">&2
    echo "      - file.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each directory from INPUT">&2
    echo "      - merged.vcf">&2
}

# This merges all ';'-separated vcf files (all should be in the same folder)
# By taking the header from the frist one and then ignoring headers.
merge(){
    unset first
    unset vcfs
    # Split given string by ;
    for input_vcf in $(echo "$1" | tr ";" "\n")
    do
        if [ -z "$first" ]; then       
            first='false'
            out_folder="$(dirname "$(realpath "$input_vcf")")"
            # shellcheck disable=SC2154 # From config file
            output_file="$out_folder/$merge_vcf_OUT_FILENAME"
            cp "$input_vcf" "$output_file"  
        else
            ((i+=1))
            vcfs[i]="$input_vcf"   
        fi
    done
    cat "${vcfs[@]}" | awk '$1 ~ /^#/ {next} {print $0}'>>"$output_file"    
    log "EXIT STATUS ($?) for: cat ${vcfs[*]} | awk '$1 ~ /^#/ {next} {print $0}'>>$output_file"
    # shellcheck disable=SC2154
    if [ "$merge_vcf_DELETE_INPUT" == "true" ]; then
        rm "${vcfs[@]}"
    fi
    log "OUT: $output_file"
    echo "$output_file"
}

# This takes all given files, separates them by folders
# and then merges them folderwise

# shellcheck source=/dev/null
source "/scripts/input_reader.sh"
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
is_done=$(is_already_done "$0" "${inputs[@]}")

declare -A folders
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    given_vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")    
    out_folder="$(dirname "$(realpath "$given_vcf")")"
    folders[$out_folder]+="$given_vcf;"
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