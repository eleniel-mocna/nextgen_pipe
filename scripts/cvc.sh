#!/bin/bash

########################
# HELP AND DESCRIPTION #
########################

# TODO: check if this works
help(){
    echo "cvc.sh: Run pair read variant calling on a given sam/bam file.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - aligned.bam">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - cvc_variants.vcf">&2
}

#################
# INPUT READING #
#################

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

###############
# APPLICATION #
###############

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    input_bam=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    out_folder="$(dirname "$(realpath "$input_bam")")"
    output_file="$out_folder/$cvc_OUT_FILENAME"
    if [ "$is_done" == false ]; then            
        {
            threads=$(get_threads "$cvc_THREADS")
            docker exec cvc_oneDNA2pileup bash -c "samtools view $input_bam\
                    | /cvc/VariantCaller.out --mapq $cvc_MIN_MAPQ --qual $cvc_MIN_BASEQ --reference $reference --vcf-file $output_file -">/dev/null
            log "EXIT STATUS ($?) for: samtools view $input_bam\
                    | /cvc/VariantCaller.out --mapq $cvc_MIN_MAPQ --qual $cvc_MIN_BASEQ --reference $reference --vcf-file $output_file -"
            if [ "$cvc_DELETE_INPUT" == "true" ]; then
                rm "$input_bam" # "$argument2" # "$argument3"
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