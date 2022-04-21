FROM rocker/rstudio:4.0.5

RUN apt-get update && \
    apt-get install -y zlib1g-dev libbz2-dev liblzma-dev libxml2 && \
    apt-get clean

RUN r -e "install.packages('BiocManager')"
RUN r -e 'BiocManager::install("VariantAnnotation")'