#!/bin/bash
help(){
    echo "split_bam.sh: Split a bam into smaller bams by chromosome">&2
    echo "  INPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file: file.bam">&2
    echo "  OUTPUT:">&2
    echo "    - Config file">&2
    echo "    - For each file:">&2
    echo "      - file_chr1.bam">&2
    echo "      - file_chr2.bam">&2
    echo "      - ...">&2
}
# shellcheck source=/dev/null
source new/input_reader.sh
N_ARGUMENTS=1 
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
# shellcheck disable=SC2154 disable=SC1090
for input_bam in "${inputs[@]}"; do
    realpath_input_bam=$(realpath "$input_bam")
    out_folder="$(dirname "$(realpath "$input_bam")")"
    for chr in $(docker exec samtools_oneDNA2pileup bash -c "samtools idxstats $realpath_input_bam" | cut -f 1 | head -n -1); do
        output_file="$out_folder/${split_OUT_FILENAME}${chr}$split_OUT_EXTENSION"
        docker exec samtools_oneDNA2pileup bash -c "samtools view -h -b $realpath_input_bam $chr">"$output_file" &
        echo "$output_file"
    done
done
wait