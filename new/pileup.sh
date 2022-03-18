#!/bin/bash
help(){
    echo "pileup.sh: Does a pileup using samtools mpileup">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: .bam file">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For every sample: pile.pileup file">&2
}
# shellcheck source=/dev/null
source "new/input_reader.sh"

# shellcheck disable=SC2154
if [ "$config_file" = "-h" ] \
    || [ "$config_file" = "--help" ]; then
    help
    exit 1
fi

# shellcheck disable=SC2154 disable=SC1090
source "$config_file"
echo "$config_file"
log "Started"
# shellcheck disable=SC2154 disable=SC1090
for (( i=0; i<("${#inputs[@]}"); i++ )); do
    {
    input_bam=${inputs[i]}
    realpath_input_bam=$(realpath "$input_bam")
    out_folder="$(dirname "$(realpath "$input_bam")")"
    output_file="$out_folder/${i}_$pileup_OUT_FILENAME"
    log "docker exec samtools_oneDNA2pileup bash -c samtools mpileup -f $reference -B $realpath_input_bam > $output_file"
    docker exec samtools_oneDNA2pileup bash -c "samtools mpileup -f $reference -B $realpath_input_bam" > "$output_file"

    # for i in $(samtools idxstats "$realpath_input_bam" | cut -f 1 | grep chr); do echo "zde -> $i"; done
    echo "$output_file"
    }&
done
wait
log "ENDED"
