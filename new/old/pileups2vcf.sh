#!/bin/bash
function realpath {
    echo "$(cd "$(dirname "$1")" || return ; pwd)/$(basename "$1")";
    }

arg=( "$@" )
narg=$#
(( nsamp=narg ))
for (( i=0; i<"$nsamp"; i++ ))
do
    samp="${arg[$i]}"
    
    # list of paths to all pileup files
    pileupfiles[$i]=$( realpath "$samp" )
    samp=${samp##*\/}
    samp=${samp//\.pileup/}
    
    #list of paths to all samples (without .pileup extension).
    samples[$i]=$samp
done

echo "${samples[@]}"

rm -f varfile.txt
###################
# Variant calling #
###################
# @In: 
#   - $file.pileup
# @Out:
#   - $file.vcf
for (( c=0; c<"$nsamp"; c++ ))
do
    file=${samples[$c]}.cns.call
    echo "reporting variants in sample ${pileupfiles[$c]} using Varscan.v2.4.0 into $file"
    echo "${pileupfiles[$c]}"
    docker exec varScan_Samuel bash -c "java -jar VarScan.jar mpileup2cns ${pileupfiles[$c]} --p-value 1  --min-coverage 7 --min-reads2 2 --min-var-freq 0.05 --output-vcf 1 --strand-filter 0 --variants 1" > "$file".vcf

done
