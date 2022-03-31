#!/bin/bash
help(){
    echo "filter_vcf.sh: Filter vcf by bcftools.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each vcf">&2
    echo "      - file.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - Nths of:">&2
    echo "    - For each vcf">&2
    echo "      - filtered.vcf">&2
}
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
log  "OUT: $config_file"

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf")")" # TODO: Is this right?
    output_file="$out_folder/${i}_$filter_vcf_OUT_FILENAME" #TODO Change this, add to the config file
    if [ "$is_done" == false ]; then    
        {
            threads=$(get_threads "$filter_vcf_THREADS")
            docker exec bcftools_oneDNA2pileup bash -c "bcftools filter -e \"(AD/(AD+RD))<0.15\" $vcf" > "$output_file"
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