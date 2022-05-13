#!/bin/bash

# This is a script for setup of oneDNA2pileup.sh pipe.
# Because this should be run only once and by someone who knows what they are
# doing, it doesn't try to be runnable anywhere and any time.
# Instead if something breaks, take a look at the script and 
# try debugging yourself.
#
# REQUIREMENTS:
#   - Any unix system
#   - Running docker daemon with a connection to the dockerHub
#       or the needed images.
# SWITCHING TOOLS:
# The main beauty of this pipeline should be the ease of switching in/out
# Every tool should be enclosed in one docker that is called using the main docker.
#
# For more detailed description for switching in/out steps from this pipeline,
# see README.

help () {
    echo
    echo 'This is a script which prepares the oneDNA2pileup pipeline'
    echo 'It is not bulletproof, so if something breaks, just try running'
    echo 'the script line by line. Also there are more comments in the code'
    echo 'for better debugging.'
    echo 
    echo 'USAGE:'
    echo './setupOneDNA2pileup.sh <mount directory> <reference directory> <max CPUs per docker> <max memory per docker>'
    echo '  <mount directory>: directory of your file system where you want the dockers to be mounted.'
    # shellcheck disable=SC2016
    echo '  <reference directory>: directory with the `ucsc.hg19.fasta` reference file'
    echo '  <max CPUs per docker>: limit on the cpu usage of every docker (e.g. 12)'
    # shellcheck disable=SC2016
    echo '      for more info see docker documentation on flag `--cpus`'
    echo '  <max memory per docker>: limit on the memory usage of every docker (e.g. 200g)'
    # shellcheck disable=SC2016
    echo '      for more info see docker documentation on flag `-m`'
    echo
    exit 0
}

if [ $# -ne 4 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
help
fi

#########
# SETUP #
#########

mount_directory="$1"
reference_directory="$2"
max_CPU="$3"
max_memory="$4"
password="$5"
port="$6"

########
# MAIN #
########
docker run --name NGSMainSamuel \
    -d -it --cpus="$max_CPU" -m="$max_memory"  \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data \
    -e PASSWORD="$password" -p "$port":8787 \
    -e ROOT=TRUE \
    -v /var/run/docker.sock:/var/run/docker.sock ngs_main_samuel # UNIX
    # -v //var/run/docker.sock:/var/run/docker.sock # WINDOWS

#############
# ALIGNMENT #
#############

docker run --name bwa_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data biocontainers/bwa:v0.7.17_cv1    

########
# GATK #
########

docker run --name gatk_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data broadinstitute/gatk:4.2.5.0

############
# SAMTOOLS #
############

docker run --name samtools_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data biocontainers/samtools:v1.7.0_cv4

############
# BAMTOOLS #
############

docker run --name bamtools_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data biocontainers/bamtools:v2.4.0_cv4

###########
# VarScan #
###########

docker run --name varScan_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data varscan_samuel

############
# BCFTOOLS #
############

docker run --name bcftools_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data biocontainers/bcftools:v1.9-1-deb_cv1

##########
# SnpEff #
##########
docker run --name SnpEff_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data biocontainers/snpeff:v4.1k_cv3
# docker run --name CellCNN_new_Samuel \
# -d -it --cpus="$max_CPU" -m="$max_memory" \
# -v "$mount_directory":/data cellcnn_samuel

################
# STAR aligner #
################

docker run --name star_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data star_samuel

################
# ROCKER stuff #
################

docker run --name rocker_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data rocker_1dna2p_samuel

################
# PYTHON stuff #
################

docker run --name python_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data python_1dna2p_samuel
max_CPU=20
max_memory="200g"
reference_directory="/mnt/storage/clip/Samuel_workdir/cvc/data/reference/"
mount_directory="/mnt/storage/clip/"
password=pass1234
port=9009