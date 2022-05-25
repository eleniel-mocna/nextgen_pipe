#!/bin/bash
# Input:
#   - path to the config file
#   - path to the sam file.

# shellcheck source=/dev/null
source "/data/Samuel_workdir/nextgen_pipe/new/input_reader.sh"

# shellcheck disable=SC2154
inputs_length="${#inputs[@]}"

# shellcheck disable=SC2154 disable=SC1090
is_done=$(is_already_done "$0" "${inputs[@]}")

# shellcheck disable=SC2154
for (( i=0; i<("$inputs_length"); i++ )); do
    input_sam=$(realpath "${inputs[$i]}")
    out_folder="$(dirname "$(realpath "$input_sam")")"
    filename=$(basename -- "$input_sam")
    filename="${filename%.*}"
    output_file="$out_folder/${i}_$filename.bam"
    if [ "$is_done" == false ]; then    
            {
            threads=$(get_threads "$sam2bam_THREADS")
            docker exec samtools_oneDNA2pileup bash -c "samtools view -h -b $input_sam" > "$output_file"
            log "EXIT STATUS ($?) for: samtools view -h -b $input_sam $output_file"
            docker exec samtools_oneDNA2pileup bash -c "samtools index $output_file"
            log "EXIT STATUS ($?) for: samtools index $output_file"
            if [ "$sam2bam_DELETE_INPUT" == "true" ]; then
                rm "$input_sam"
            fi
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