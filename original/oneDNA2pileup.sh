#!/bin/bash

fastqin1=$1
fastqin2=$2
out=$3
let "nsamp=narg/2"
# PICARD=/Users/diagnostika/nextgen-bin/picard-tools-1/picard-tools-1.114/
# NEXTGEN=/home/vidofnir/nextgen-bin/
currentdir=${PWD}
TMP_DIR=`pwd`/tmp

echo "allignement of paired-end $s1 $s2"

echo "allignement of paired-end $fastqin1 $fastqin2"
bwa mem -t 12 -M -R "@RG\tID:exomeID\tLB:exomeLB\tSM:$samp\tPL:illumina\tPU:exomePU" $NEXTGEN/hg19/hg19.fa $fastqin1 $fastqin2 > $out.1.sam

echo "Picard stuff"
picard-tools FixMateInformation I=$out.1.sam O=$out.fixed1.sam SO=coordinate VALIDATION_STRINGENCY=SILENT TMP_DIR=$currentdir
rm $out.1.sam

picard-tools SortSam I=$out.fixed1.sam SO=coordinate O=$out.bam VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true TMP_DIR=$currentdir
rm $out.fixed1.sam

picard-tools AddOrReplaceReadGroups I=$out.bam O=$out.1.bam SO=coordinate ID=Nazev1 LB=nazev2 PL=illumina PU=HiSeq2000 SM=Nazev3 VALIDATION_STRINGENCY=SILENT TMP_DIR=$currentdir
mv $out.1.bam $out.bam

picard-tools MarkDuplicates I=$out.bam O=$out.1.bam METRICS_FILE=metricsFile CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true  TMP_DIR=$currentdir
mv $out.1.bam $out.bam
mv  $out.1.bai $out.bai

echo "calling variants in $out.bam"
samtools mpileup -f $NEXTGEN/hg19/hg19.fa -B $out.bam > $out.pileup
