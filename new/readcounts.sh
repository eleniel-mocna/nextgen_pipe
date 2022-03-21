#!/bin/bash
help(){
    echo "readcounts.sh: Prepare a pileup on all positions with variants..">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - pile.pileup">&2
    echo "      - varfile.txt">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - readcounts.pileup">&2
}
# shellcheck source=/dev/null
source new/input_reader.sh
N_ARGUMENTS=2
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
# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    pileup=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    varfile=$(realpath "${inputs[((N_ARGUMENTS*$i+1))]}")

    out_folder="$(dirname "$(realpath "$pileup")")" 
    output_file="$out_folder/$readcounts_OUT_FILENAME" 
    
    
    docker exec varScan_Samuel bash -c "java -Xmx5g -jar VarScan.jar readcounts $pileup \
    --min-coverage 0 --min-base-qual 15 --output-file  $output_file --variants-file $varfile"    

    echo "$output_file"
done