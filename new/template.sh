#!/bin/bash

########################
# HELP AND DESCRIPTION #
########################

help(){ # TODO Rewrite these help prints.
    echo "NAME.sh: Short summary of this script's functionality.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Nths of:">&2
    echo "      - first_file.ext">&2
    echo "      - second_file.ext">&2
    echo "      - ...">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - Nths of:">&2
    echo "      - first_file.ext">&2
    echo "      - second_file.ext">&2
    echo "      - ...">&2
}

#################
# INPUT READING #
#################

# shellcheck source=/dev/null
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"
N_ARGUMENTS=1 #TODO: Number of arguments per sample
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

###############
# APPLICATION #
###############

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    argument1=$(realpath "${inputs[((N_ARGUMENTS*$i))]}") # TODO Pick how many arguments are used, rename variables
    # argument2=$(realpath "${inputs[((N_ARGUMENTS*$i+1))]}")
    # argument3=$(realpath "${inputs[((N_ARGUMENTS*$i+2))]}")    
    out_folder="$(dirname "$(realpath "$argument1")")" # TODO: Is this right?
    output_file="$out_folder/$name_OUT_FILENAME" #TODO Change this, add to the config file
    # TODO: If more files are produced, put them here
    if [ "$is_done" == false ]; then            
        {
            threads=$(get_threads "$NAME_THREADS") # TODO: Rename this
            : # TODO: Do your magic!
            if [ "$NAME_DELETE_INPUT" == "true" ]; then # TODO: Rename, pick how many arguments
                rm "$argument1" # "$argument2" # "$argument3"
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