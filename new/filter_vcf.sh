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

# shellcheck disable=SC2154
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf")")" # TODO: Is this right?
    output_file="$out_folder/${i}_$filter_vcf_OUT_FILENAME" #TODO Change this, add to the config file
    header="$out_folder/${i}_$filter_vcf_TMP_FILENAME"

    if [ "$is_done" == false ]; then    
        {                        
            threads=$(get_threads "$filter_vcf_THREADS")
            cat \
                <(docker exec bcftools_oneDNA2pileup bash -c "bcftools view -h $vcf" | grep '^##') \
                <(docker exec bcftools_oneDNA2pileup bash -c "cat $reference_vcf_header") \
                <(docker exec bcftools_oneDNA2pileup bash -c "bcftools view -h $vcf" | grep -v '^##') \
                > "$header"
            docker exec bcftools_oneDNA2pileup bash -c "bcftools reheader --header $header $vcf | bcftools filter -e \"(AD/(AD+RD))<0.15\"" > "$output_file"
            give_back_threads "$threads"
            if [ "$filter_vcf_DELETE_INPUT" == "true" ]; then
                rm "$vcf"
            fi
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