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
#   - $file.cns.call
for (( c=0; c<"$nsamp"; c++ ))
do
    file=${samples[$c]}.cns.call
    echo "reporting variants in sample ${pileupfiles[$c]} using Varscan.v2.4.0 into $file"
    echo "${pileupfiles[$c]}"
    docker exec varScan_Samuel bash -c "java -jar VarScan.jar mpileup2cns ${pileupfiles[$c]} --p-value 1  --min-coverage 7 --min-reads2 2 --min-var-freq 0.05 --output-vcf 1 --strand-filter 0 --variants 1" > "$file".vcf
    
    ## HERE END ------------
    docker exec bcftools_Samuel bash -c "bcftools filter -e \"(AD/(AD+RD))<0.15\" $file.vcf" > "$file".FREQ15.vcf

    skip=$(grep -n -m 1 '#CHR' "$file.vcf" | cut -d: -f1)
    (( skip="$skip"+1 ))

    tail -n +$skip "$file.vcf" | awk  'BEGIN  {FS="\t";OFS = "\t";ORS="\n"}  {print $1,$2,$4,$4}' >> varfile.txt

done

# sort varfile.txt | uniq  > vf.txt
# rm varfile.txt
# for (( c=0; c<"$nsamp"; c++ ))
# do
#     echo "reporting reads count at called positions in sample ${samples[$c]} using Varscan.v2.4.0"

#     file=${samples[$c]}
#     echo "$file"
#     echo "creating local copy of non-zero call s in $file.pileup"
#     awk 'BEGIN {OFS = "\t";ORS="\n"} {if ($4>0) print $1,$2,$3,$4,$5,$6}' "$file".pileup > "$file".1.pileup
#     echo "reporting reads count..."
#     docker exec varScan_Samuel bash -c "java -jar VarScan.jar readcounts $file.1.pileup --min-coverage 0 --min-base-qual 15 --output-file  $file.var.readcounts.txt --variants-file vf.txt"
#     # rm $file.1.pileup
#     echo "building called position vcf"
#     eval  "R CMD BATCH  --no-save --no-restore '--args rc_in=\"$file.var.readcounts.txt\" vcf_out=\"$file.rc.vcf\" pathRscript=\"$NEXTGEN/finish_rc_dev.R\"' $NEXTGEN/create.vcf.R diag.out"

#     docker exec snpeff_Samuel bash -c "java -jar /home/biodocker/bin/snpEff/SnpSift.jar annotate $NEXTGEN/snpEff/00-All.vcf $file.rc.vcf" > "$file".callannotated.vcf
#     docker exec snpeff_Samuel bash -c "java -jar /home/biodocker/bin/snpEff/snpEff.jar hg19 -v $file.callannotated.vcf" > "$file".callannotated_eff.vcf
#     outord[$c]=$file.callannotated_eff.vcf
#     (( i="$nsamp"+"$c" ))
#     outord[$i]=$file.var.readcounts.txt
# done
# echo "${outord[@]}"
# echo "${outord[@]}" > Rorders.dat
