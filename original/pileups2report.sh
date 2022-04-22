#!/bin/bash
arg=( "$@" )
narg=$#

let "nsamp=narg"
# PICARD=/Users/diagnostika/nextgen-bin/picard-tools-1/picard-tools-1.114/
# NEXTGEN=/home/vidofnir/nextgen-bin/
ord=""
out=""
# I don't know what was this supposed to do. But definitely not what it does...
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

# Why print the first element?
echo "${samples[@]}"

rm varfile.txt
for (( c=0; c<"$nsamp"; c++ ))
do
    # call_variants.sh
    echo "reporting variants in sample ${pileupfiles[$c]} using Varscan.v2.4.0"
    file=${samples[$c]}.cns.call
    echo "$file"
    java -Xmx5g -jar "$NEXTGEN"/VarScan.v2.4.0.jar mpileup2cns "${pileupfiles[$c]}" --p-value 1  --min-coverage 7 --min-reads2 2 --min-var-freq 0.05 --output-vcf 1 --strand-filter 0 --variants 1 > "$file".vcf
    
    # filter_vcf.sh
    bcftools filter -e "(AD/(AD+RD))<0.15" "$file".vcf > "$file".FREQ15.vcf

    # create_varfile.sh
    skip=$(grep -n -m 1 '#CHR' "$file".vcf | cut -d: -f1)
    ((skip="$skip"+1))

    tail -n +$skip "$file".vcf | awk  'BEGIN  {FS="\t";OFS = "\t";ORS="\n"}  {print $1,$2,$4,$4}'   >> varfile.txt

done

sort varfile.txt | uniq  > vf.txt
rm varfile.txt
# readcounts.sh
for (( c=0; c<"$nsamp"; c++ ))
do
    echo "reporting reads count at called positions in sample ${samples[$c]} using Varscan.v2.4.0"

    file=${samples[$c]}
    echo "$file"
    echo "creating local copy of non-zero call s in $file.pileup"
    awk 'BEGIN {OFS = "\t";ORS="\n"} {if ($4>0) print $1,$2,$3,$4,$5,$6}' "$file".pileup > "$file".1.pileup
    echo "reporting reads count..."
    java -Xmx5g  -jar "$NEXTGEN"/VarScan.v2.4.0.jar readcounts "$file".1.pileup --min-coverage 0 --min-base-qual 15 --output-file  "$file".var.readcounts.txt --variants-file vf.txt
    # rm $file.1.pileup
    # -----------
    
    echo "building called position vcf"
    # call_positions.sh 
    eval  "R CMD BATCH  --no-save --no-restore '--args rc_in=\"$file.var.readcounts.txt\"\
    vcf_out=\"$file.rc.vcf\" pathRscript=\"$NEXTGEN/finish_rc_dev.R\"' $NEXTGEN/create.vcf.R diag.out"

    #snpsift.sh
    java -Xmx5g -jar "$NEXTGEN"/snpEff/SnpSift.jar annotate "$NEXTGEN"/snpEff/00-All.vcf "$file".rc.vcf > "$file".callannotated.vcf
    #snpeff.sh
    java  -Xmx5g -jar "$NEXTGEN"/snpEff/snpEff.jar hg19 -v "$file".callannotated.vcf  > "$file".callannotated_eff.vcf
    outord[$c]=$file.callannotated_eff.vcf
    ((ind="$nsamp"+"$c"))
    outord[$ind]=$file.var.readcounts.txt
done
echo "${outord[@]}"
echo "${outord[@]}" > Rorders.dat
