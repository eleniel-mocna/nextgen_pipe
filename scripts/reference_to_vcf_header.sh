#! /bin/bash

# Usage: reference_to_vcf_header.sh [reference.dict] > reference_header.vcf
<"$1" awk -F '[\t,:]' '{if($1=="@SQ");{print ("##contig=<ID="$3",length="$5">")} }'