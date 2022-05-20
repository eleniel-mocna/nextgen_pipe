#!/bin/bash
help(){
    echo "create_varfile.sh: Appends variants to the varfile in given file's folder.">&2
    echo "    This runs only on a single thread.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - variants.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each folder:">&2
    echo "      - varfile.txt">&2
    echo "      - ...">&2
}
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

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf")")"
    output_file="$out_folder/$create_varfile_OUT_FILENAME"
    if [ "$is_done" == false ]; then    
        rm -f "$output_file"
        if [ "$create_varfile_DELETE_INPUT" == "true" ]; then
            rm "$vcf"
        fi
    fi
    
done

declare -a output_files
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf")")"
    output_file="$out_folder/$create_varfile_OUT_FILENAME"
    if [ "$is_done" == false ]; then    
        skip=$(grep -n -m 1 '#CHR' "$vcf" | cut -d: -f1)
        ((skip="$skip"+1))

        tail -n +$skip "$vcf" | awk  'BEGIN  {FS="\t";OFS = "\t";ORS="\n"}  {print $1,$2,$4,$4}'   >> "$output_file"    
    fi
    output_files[i]=$output_file    
done
# printf "%s\n" "${output_files[@]}" | sort -u

for varfile in "${output_files[@]}"; do
    if [ "$is_done" == false ]; then  
        mv "$varfile" "${varfile}_tmp"
        sort -u "${varfile}_tmp">"$varfile"
        rm "${varfile}_tmp"
    fi
    echo "$varfile"
    log "OUT: $varfile"
done


for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf")")"
    output_file="$out_folder/$create_varfile_OUT_FILENAME"
    # shellcheck disable=SC2154 
    if [ "$is_done" == false ] && [ "$remove_after_done" == true ]; then                     
        rm -f "$vcf"
    fi
    output_files[i]=$output_file    
done

if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait