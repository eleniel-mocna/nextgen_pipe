#!/bin/bash
help(){ #
    echo "snpEff.sh: Annotate a vcf file.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each sample:">&2
    echo "      - file.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - annotated.vcf">&2
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
# shellcheck disable=SC2154 disable=SC1090
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf_in=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$vcf_in")")"
    output_file="$out_folder/$snpEff_OUT_FILENAME" 
    if [ "$is_done" == false ]; then           
        {
            threads=$(get_threads "$snpEff_THREADS")
            docker exec SnpEff_oneDNA2pileup bash -c "java  $snpEff_maxMemory -jar /home/biodocker/bin/snpEff/snpEff.jar $snpEff_REFERENCE -v $vcf_in"  > "$output_file"        
            if [ "$snpEff_DELETE_INPUT" == "true" ]; then
                rm "$vcf_in"
            fi
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