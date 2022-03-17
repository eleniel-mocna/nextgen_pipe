#!/bin/bash
# shellcheck disable=SC2034
# /\ "variable not used" - this is a file for sourcing so this
# warning makes no sence.

# This script reads from stdin and command line arguments (CLA)

if [ $# -eq 0 ]; then # Everything in stdin
    i=-1
    while read -r line
    do    

        if [ -n "$line" ]; then
            if [ $i -eq -1 ]; then
                config_file="$line"    
            else
                inputs[i]="$line"
            fi
        fi
        (( i++ ))
    done<"/dev/stdin"

    inputs_length="${#inputs[@]}"
    # if [ $(( "$inputs_length"%2 )) -ne 0 ]; then
    #     echo "Invalid input type!" >&2
    #     exit 1
    # fi

elif [ $# -eq 1 ]; then # Config as CLA, input as stdin
    config_file="$1"
    if [ "$config_file" != "-h" ] && [ "$config_file" != "--help" ]; then
        i=0
        while read -r line
        do    

            if [ -n "$line" ]; then
                inputs[i]="$line"
            fi
            (( i++ ))
        done<"/dev/stdin"
    fi

else # Everything as CLA
    config_file="$1"
    i=-1
    for var in "$@"; do
        if [ $i -ne -1 ]; then
            inputs[i]="$var"
        fi
        (( i++ ))
        
    done
fi

if [ "$config_file" = "--test" ]; then
    this_is_just_a_test=1
    config_file=${inputs[0]}
    inputs=("${inputs[@]:1}")
    echo "this_is_just_a_test: $this_is_just_a_test">&2
    echo "config_file: $config_file">&2
    echo "inputs: ${inputs[*]}">&2
else
    this_is_just_a_test=0
fi