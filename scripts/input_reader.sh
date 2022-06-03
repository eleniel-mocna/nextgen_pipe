#!/bin/bash
# shellcheck disable=SC2034
# /\ "variable not used" - this is a file for sourcing so this
# warning makes no sence.

# This script reads from stdin and command line arguments (CLA)
# First it reads all argumnets from stdin
# Then it reads all arguments from CLA
# All arguments in form of [var]=[integer value] or [var]="[string value]"
# are evaluated after the config file is loaded - herefore overwriting these
# variables.

default_config_file="/scripts/config_file.sh"

config_file="$1"
i=-1
while read -r line
do    

    if [ -n "$line" ]; then
        if [ $i -eq -1 ]; then
            config_file="$line"    
        else
            tmp_input[i]="$line"
        fi
    fi
    (( i++ ))
done<"/dev/stdin"
for var in "$@"; do
    if [ "$i" -ne -1 ]; then
        tmp_input[i]="$var"
    fi
    (( i++ ))        
done


if [ "$config_file" = "--test" ]; then
    this_is_just_a_test=1
    config_file=${tmp_input[0]}
    input=("${tmp_input[@]:1}")
    echo "this_is_just_a_test: $this_is_just_a_test">&2
    echo "config_file: $config_file">&2
    echo "tmp_input: ${input[*]}">&2
else
    this_is_just_a_test=0
fi

if [ "$config_file" = "-" ]; then
    config_file="$default_config_file"
fi

inputs_length="${#tmp_input[@]}"
i=0

# shellcheck source=/media/bioinfosrv/Samuel_workdir/nextgen_pipe/scripts/config_file.sh
source "$config_file"
log "$config_file"
realpath "$config_file"

for inp in "${tmp_input[@]}"; do
    if [[ "$inp" =~ ^[a-zA-Z_][a-zA-Z_0-9]*=(([0-9]*)|(\".*\"))$ ]]; then
        eval "$inp" # I know this is ugly and kinda dangerous... Be if someone has access to this input, then he probably has also access to bash...
    else
        inputs[i]=$inp
        (( i++ ))
    fi
done