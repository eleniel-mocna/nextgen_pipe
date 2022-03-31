#!/bin/bash
help(){
    echo "pileup.sh: Calls variants using Varscan mpileup2cns">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .pileup file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: variants.vcf file">&2
}
# shellcheck source=/dev/null
source "new/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"
log  "OUT: $config_file"

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("${#inputs[@]}"); i++ )); do
    {
        input_pileup="${inputs[i]}"
        realpath_input_pileup=$(realpath "$input_pileup")
        out_folder="$(dirname "$(realpath "$input_pileup")")"
        output_file="$out_folder/${i}_$callVariants_OUT_FILENAME"
        if [ "$is_done" == false ]; then        
            {
                threads=$(get_threads "$callVariants_THREADS")
                docker exec varScan_Samuel bash -c "java -jar VarScan.jar mpileup2cns $realpath_input_pileup --p-value 1  --min-coverage 7 --min-reads2 2 --min-var-freq 0.05 --output-vcf 1 --strand-filter 0 --variants 1" > "$output_file"
                mv "$output_file" "${output_file}_tmp"
                < "${output_file}_tmp" sed '/\[/d'>"$output_file"
                rm "${output_file}_tmp"
                give_back_threads "$threads"
            }&
        fi
        echo "$output_file"
        log  "OUT: $output_file"
    }&
done
wait
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
for (( i=0; i<("${#inputs[@]}"); i++ )); do
    input_pileup="${inputs[i]}"
    realpath_input_pileup=$(realpath "$input_pileup")
    
    # shellcheck disable=SC2154 
    if [ "$is_done" == false ] && [ "$remove_after_done" == true ]; then                    
        rm "$realpath_input_pileup"
    fi
done