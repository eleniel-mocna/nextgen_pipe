FROM rocker/rstudio:4.0.5

LABEL NAME="Rocker1DNA2P" Version="1.0"
LABEL author="Samuel Soukup"
LABEL contact="soukup.sam(at)gmail.com"


COPY RFiles /RFiles

RUN apt-get update && \
    apt-get install -y zlib1g-dev libbz2-dev liblzma-dev libxml2 && \
    apt-get clean

RUN r -e "install.packages('BiocManager')"
RUN r -e 'BiocManager::install("VariantAnnotation")'
