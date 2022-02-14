#!/bin/bash
# Takes a path as an argument 
function realpath {
    echo $(cd $(dirname $1); pwd)/$(basename $1);
    }
reads1=$( realpath "$1" )
reads2=$( realpath "$2" )
out=$( realpath "$3" )
reference="/data/Samuel_workdir/cvc/data/reference/ucsc.hg19.fasta"
tmpfile=$(mktemp /tmp/oneDNA.XXXXXX)
exec 3>"$tmpfile"
exec 4<"$tmpfile"
rm "$tmpfile"
# let "nsamp=narg/2"
# PICARD=/Users/diagnostika/nextgen-bin/picard-tools-1/picard-tools-1.114/
# NEXTGEN=/home/vidofnir/nextgen-bin/
currentdir=${PWD}
# TMP_DIR=`pwd`/tmp

echo "allignement of paired-end $s1 $s2"

echo "allignement of paired-end $fastqin1 $fastqin2"
echo "reference $reference"
docker exec bwa_Samuel bash -c "bwa mem -t 12 -M -R \"@RG\tID:exomeID\tLB:exomeLB\tSM:$samp\tPL:illumina\tPU:exomePU\" $reference $reads1 $reads2" > "$out.1.sam"

echo "Picard stuff"
docker exec gatk_Samuel bash -c "gatk MarkDuplicatesSpark -I $out.1.sam -O $out.fixed1.sam"
rm $out.1.sam

docker exec gatk_Samuel bash -c "gatk SortSam -I $out.fixed1.sam -SO coordinate -O $out.bam --VALIDATION_STRINGENCY SILENT --CREATE_INDEX true"
rm $out.fixed1.sam

docker exec gatk_Samuel bash -c "gatk AddOrReplaceReadGroups -I $out.bam -O $out.1.bam -ID Nazev1 -LB nazev2 -PL illumina -PU HiSeq2000 -SM Nazev3 --VALIDATION_STRINGENCY SILENT --TMP_DIR $currentdir"
mv $out.1.bam $out.bam

docker exec gatk_Samuel bash -c "gatk MarkDuplicates -I $out.bam -O $out.1.bam --METRICS_FILE metricsFile --CREATE_INDEX true --VALIDATION_STRINGENCY SILENT --REMOVE_DUPLICATES true --TMP_DIR $currentdir"
mv $out.1.bam $out.bam
mv $out.1.bai $out.bai

echo "calling variants in $out.bam"
docker exec samtools_Samuel bash -c"samtools mpileup -f $NEXTGEN/hg19/hg19.fa -B $out.bam" > $out.pileup
