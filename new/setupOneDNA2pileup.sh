#!/bin/bash

# This is a script for setup of oneDNA2pileup.sh pipe.
# Because this should be run only once and by someone who knows what they are
# doing, it doesn't try to be runnable anywhere and any time.
# Instead if something breaks, take a look at the script and 
# try debugging yourself.
# 
# Firstly set all the variables under the SETUP.
# Then run this script from the root folder.
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

#########
# SETUP #
#########

max_CPU=20 # Max CPU threads per docker
max_memory="200g" # Max memory usage per docker
reference_directory="/mnt/storage/clip/Samuel_workdir/cvc/data/reference/" # Folder in which the hg19 is stored
mount_directory="/mnt/storage/clip/" # Folder for the main mount
star_genome_directory="/mnt/storage/clip/Samuel_workdir/starRNA/star_genome"
# /\ Folder in which the reference for star aligner is stored
threads_folder="/mnt/storage/clip/Samuel_workdir/nextgen_pipe/new/multi_threading"
# /\ Folder, which contains available_threads with an integer in it, multi_threader.sh
password=pass1234
port=9009

########
# MAIN #
########

docker build -t ngs_main_samuel main

docker run --name NGSMainSamuel \
    -d -it --cpus="$max_CPU" -m="$max_memory"  \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data \
    -e PASSWORD="$password" -p "$port":8787 \
    -e ROOT=TRUE \
    -v "$threads_folder":/multi_threader \
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

docker build -t varscan_samuel varScan

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

docker build -t star_samuel starAligner

docker run --name star_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data \
    -v "$star_genome_directory":/star_genome star_samuel

################
# ROCKER stuff #
################

docker build -t rocker_1dna2p_samuel rocker-stuff

docker run --name rocker_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data rocker_1dna2p_samuel

################
# PYTHON stuff #
################

docker build -t python_1dna2p_samuel python-stuff

docker run --name python_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data python_1dna2p_samuel

#######
# cvc #
#######

# TODO add docker build

docker run --name cvc_oneDNA2pileup \
    -d -it --cpus="$max_CPU" -m="$max_memory" \
    -v "$reference_directory":/reference \
    -v "$mount_directory":/data cvc_eleniel