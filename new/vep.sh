#!/bin/bash

########################
# HELP AND DESCRIPTION #
########################

help(){
    echo "vep.sh: ensembl variant effect predictor.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - merged_w_coverage.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - merged_ann.txt ">&2
}

#################
# INPUT READING #
#################

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
is_done=$(is_already_done "$0" "${inputs[@]}")

###############
# APPLICATION #
###############

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    vcf_in=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")    
    out_folder="$(dirname "$(realpath "$vcf_in")")"
    output_file="$out_folder/$vep_OUT_FILENAME"
    if [ "$is_done" == false ]; then            
        {
            threads=$(get_threads "$vep_THREADS")
            docker exec vep_oneDNA2pileup bash -c \
            "/opt/vep/src/ensembl-vep/vep -i $vcf_in -o $output_file \
            -offline -merged --dir_cache $vep_dir_cache --assembly GRCh37\
            --fasta $vep_fasta --everything --force_overwrite"
            if [ "$vep_DELETE_INPUT" == "true" ]; then
                rm "$vcf_in"
            fi
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