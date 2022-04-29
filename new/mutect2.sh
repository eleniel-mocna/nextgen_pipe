#!/bin/bash
help(){ 
    echo "mutect2.sh: variant calling from gatk.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .bam/cram file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: mutect_variants.vcf file">&2
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
    input_bam=$(realpath "${inputs[((N_ARGUMENTS*$i))]}") #
    out_folder="$(dirname "$(realpath "$input_bam")")"
    output_file="$out_folder/$mutect2_OUT_FILENAME"
    # TODO: If more files are produced, put them here
    if [ "$is_done" == false ]; then            
        {
            threads=$(get_threads "$mutect2_THREADS") # TODO: Rename this
            docker exec samtools_oneDNA2pileup bash -c "samtools index $input_bam"
            docker exec gatk_oneDNA2pileup bash -c "gatk Mutect2 -I $input_bam -O $output_file -R $reference"
            give_back_threads "$threads"
        }&          
    fi
    # TODO: Add the remaining output files!
    echo "$output_file"
    log "OUT: $output_file"
done
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait