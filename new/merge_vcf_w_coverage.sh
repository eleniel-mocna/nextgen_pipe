#!/bin/bash
help(){
    echo "merge_vcf_w_coverage.sh: Create a bed file spanning all locations from the vcf.">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - reads.bam">&2
    echo "      - variants.vcf">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - merged_w_coverage.vcf">&2
}
# shellcheck source=/dev/null
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"
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
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("$inputs_length")/"$N_ARGUMENTS"; i++ )); do
    in_bam=$(realpath "${inputs[((N_ARGUMENTS*$i))]}")
    in_vcf=$(realpath "${inputs[((N_ARGUMENTS*$i+1))]}")
    vcfs+=" $in_vcf"
    bams+=" $in_bam"
    out_folder="$(dirname "$(realpath "$in_vcf")")"
    bed_file="$out_folder/$merge_vcf_w_coverage_BEDTMP"
    depths_file="$out_folder/$merge_vcf_w_coverage_DEPTHSTMP"
    output_file="$out_folder/$merge_vcf_w_coverage_OUT_FILENAME"
    if [ "$is_done" == false ]; then            
            docker exec samtools_oneDNA2pileup bash -c "samtools index $in_bam"
    fi
done
docker exec python_oneDNA2pileup bash -c "/python-scripts/get_bed_from_vcf.py $vcfs $output_file $bed_file"
log "doing depths"
# shellcheck disable=SC2154
docker exec samtools_oneDNA2pileup bash -c "samtools depth -Q $merge_vcf_w_coverage_MINQUAL\
                        -q $merge_vcf_w_coverage_MINBASEQ -b $bed_file $bams">"$depths_file"
log "DONE depths"
docker exec python_oneDNA2pileup bash -c "/python-scripts/add_depths.py $output_file $depths_file"
# shellcheck disable=SC2154
if [ "$merge_vcf_w_coverage_DELETE_INPUT" == "true" ]; then
    rm "$bams" "$vcfs"
fi
echo "$output_file"
log "OUT: $output_file"
if [ "$is_done" == true ]; then
        log "Skipped - already done."
    else
        mark_done "$0" "${inputs[@]}"
fi