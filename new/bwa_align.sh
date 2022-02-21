#!/bin/bash

# Takes 2 fastq file paths on stdin and returns a path to a bam file.
# Can be configure via oneDNA2pileup settings file

reads1="$1"
reads2="$2"

>&2 echo "allignement of paired-end $reads1 $reads2"
samp="$reads1"
reference=$( python3 new/config_reader.py reference)
outputFile=$( python3 new/config_reader.py bwa.align.outputFile )
header=$( python3 new/config_reader.py bwa.align.header )
echo $reference
>&2 echo "reference $reference"

docker exec bwa_oneDNA2pileup bash -c \
    "bwa mem -t 12 -M -R \"@RG\tID:exomeID\tLB:exomeLB\tSM:$samp\tPL:illumina\tPU:exomePU\" $reference $reads1 $reads2 > $outputFile"
    
echo "$outputFile"