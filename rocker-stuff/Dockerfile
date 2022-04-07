FROM rocker/rstudio

RUN apt-get update && \
    apt-get install -y zlib1g-dev && \
    apt-get clean

RUN r -e "install.packages('BiocManager')"
RUN r -e 'BiocManager::install("VariantAnnotation")'