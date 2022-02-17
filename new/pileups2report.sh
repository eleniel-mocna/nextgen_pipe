#!/bin/bash
arg=( "$@" )
narg=$#
let "nsamp=narg"
ord=""
out=""
for (( c=0; c<$nsamp; c++ ))
do
    let ind=c
    let ind2=$ind+1
    samp=("${arg[@]:$ind:$ind2}")
    pileupfiles[$c]=$samp
    samp=${samp##*\/}
    samp=${samp//\.pileup/}
    samples[$c]=$samp

done

echo $samples