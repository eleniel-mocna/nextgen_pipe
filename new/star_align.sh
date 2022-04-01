#!/bin/bash
help(){
    echo "star_align.sh: Aligns fastq files using the star aligner.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - Pairs of:">&2
    echo "      - sample_fastq1.fq">&2
    echo "      - sample_fastq2.fq">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every pair:">&2
    echo "      - star_aligned.sam">&2
}
# shellcheck source=/dev/null
source new/input_reader.sh
N_ARGUMENTS=2
# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"
# shellcheck disable=SC2154
if [ $(( "$inputs_length"%"$N_ARGUMENTS" )) -ne 0 ] || [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    echo "Invalid input type! (Or help)">&2
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"
log  "OUT: $config_file"
# shellcheck disable=SC2154 disable=SC1090
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    fastq1=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    fastq2=$(realpath "${inputs[((N_ARGUMENTS*$i+1))]}")    
    out_folder="$(dirname "$(realpath "$fastq1")")"
    output_file="$out_folder/$star_align_OUT_FILENAME"    
    if [ "$is_done" == false ]; then            
        {            
            threads=$(get_threads "$star_THREADS")
            tmp_dir=$(docker exec star_oneDNA2pileup bash -c "mktemp -d star.XXXXXXXXX")
            docker exec star_oneDNA2pileup bash -c "cd $tmp_dir && /STAR/source/STAR --genomeDir\
                $star_align_REFERENCE --readFilesIn $fastq1 $fastq2"
            docker exec star_oneDNA2pileup bash -c "cd $tmp_dir && mkdir 2ndpass"
            docker exec star_oneDNA2pileup bash -c "cd $tmp_dir && /STAR/source/STAR --runMode genomeGenerate \
                --genomeDir 2ndpass/ --genomeFastaFiles $reference --sjdbFileChrStartEnd SJ.out.tab \
                --sjdbOverhang 75 --runThreadN $threads"
            docker exec star_oneDNA2pileup bash -c "cd $tmp_dir && /STAR/source/STAR --genomeDir 2ndpass/ --readFilesIn $fastq1 $fastq2 \
                --runThreadN $threads --chimJunctionOverhangMin 15 --chimSegmentMin 15 --outStd SAM">"$output_file"
            docker exec star_oneDNA2pileup bash -c "rm -r $tmp_dir"
            give_back_threads "$threads"
        }&          
    fi
    echo "$output_file"
    log "OUT: $output_file"
done
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi
wait