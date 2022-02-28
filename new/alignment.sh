#!/bin/bash

# Input:
#   - path to config file
#   - path to the first file
#   - path to the second file
#   - ...

i=0
while read -r line
do    
    if [ -n "$line" ]; then
        inputs[i]="$line"
    fi
    (( i++ ))
done<"/dev/stdin"

inputs_length="${#inputs[@]}"
if [ $(( "$inputs_length"%2 )) -ne 1 ]; then
    echo "Invalid input type!" >&2
    exit 1
fi
config_file="${inputs[0]}"

source "$config_file"

for (( i=0; i<("$inputs_length"-1)/2; i++ )); do
    fastqin1="${inputs[((2*$i+1))]}"
    fastqin2="${inputs[((2*$i+2))]}"
    echo "allignement of paired-end $fastqin1 $fastqin2"
    echo "reference $reference" 
    docker exec bwa_oneDNA2pileup bash -c "bwa mem -t 12 -M -R \"@RG\tID:exomeID\tLB:exomeLB\tSM:$samp\tPL:illumina\tPU:exomePU\" $reference $reads1 $reads2" > "$out.1.sam"    
done
