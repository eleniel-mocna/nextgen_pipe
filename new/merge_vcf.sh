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
    given_vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$given_vcf")")"
    folders[$out_folder]+="$given_vcf;"
done
for files_in_folder in "${folders[@]}"
do
    merge "$files_in_folder"
done

# This removes some warning lines which are for whatever reason
# sometimes generated with the cat command.
# (Maybe todo)
mv "$output_file" "tmp_$output_file" 
< "tmp_$output_file" sed '/\[/d'>"$output_file"
rm "tmp_$output_file"

