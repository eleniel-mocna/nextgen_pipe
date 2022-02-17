#!/bin/bash
# Takes a path as an argument 
function realpath {
    echo $(cd $(dirname $1); pwd)/$(basename $1);
    }
reads1=$( realpath "$1" )
reads2=$( realpath "$2" )
out=$( realpath "$3" )
reference="/reference/ucsc.hg19.fasta"
currentdir=${PWD}

echo "allignement of paired-end $1 $2"

#############
# ALIGNMENT #
#############

# @In: 
#   - $reads1 (fastq)
#   - $reads2 (fastq)
#   - $reference (fasta)
# @Out:
#   - $out.1.sam

echo "allignement of paired-end $fastqin1 $fastqin2"
echo "reference $reference"
docker exec bwa_oneDNA2pileup bash -c "bwa mem -t 12 -M -R \"@RG\tID:exomeID\tLB:exomeLB\tSM:$samp\tPL:illumina\tPU:exomePU\" $reference $reads1 $reads2" > "$out.1.sam"

########
# GATK #
########

# @In:
#   - $out.1.sam
# @Out:
#   - $out.bam
#   - $out.bai

echo "Picard stuff"
docker exec gatk_oneDNA2pileup bash -c "gatk MarkDuplicatesSpark -I $out.1.sam -O $out.fixed1.sam"
rm $out.1.sam

echo "GATK stuff"
docker exec gatk_oneDNA2pileup bash -c "gatk SortSam -I $out.fixed1.sam -SO coordinate -O $out.bam --VALIDATION_STRINGENCY SILENT --CREATE_INDEX true"
rm $out.fixed1.sam

docker exec gatk_oneDNA2pileup bash -c "gatk AddOrReplaceReadGroups -I $out.bam -O $out.1.bam -ID Nazev1 -LB nazev2 -PL illumina -PU HiSeq2000 -SM Nazev3 --VALIDATION_STRINGENCY SILENT --TMP_DIR $currentdir"
mv $out.1.bam $out.bam

docker exec gatk_oneDNA2pileup bash -c "gatk MarkDuplicates -I $out.bam -O $out.1.bam --METRICS_FILE metricsFile --CREATE_INDEX true --VALIDATION_STRINGENCY SILENT --REMOVE_DUPLICATES true --TMP_DIR $currentdir"
mv $out.1.bam $out.bam
mv $out.1.bai $out.bai

############
# SAMTOOLS #
############

# @In:
#   - $out.bam
#   - $out.bai
# @Out:
#   - $out.pileup

echo "calling variants in $out.bam"
docker exec samtools_oneDNA2pileup bash -c "samtools mpileup -f $reference -B $out.bam" > $out.pileup