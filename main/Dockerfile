FROM rocker/rstudio
LABEL NAME="NGSmain" Version="1.1"
LABEL author="Samuel Soukup"
LABEL contact="soukup.sam(at)gmail.com"

RUN apt-get update && apt-get install curl -y
RUN curl -fsSL https://get.docker.com | sh
RUN mkdir /DockerBuildInfo
COPY Dockerfile /DockerBuildInfo
COPY scripts /scripts
COPY RInterface /RInterface

COPY README.md /README.md
RUN r -e 'install.packages(c("glue", "stringr", "magrittr"))'
RUN R CMD BATCH /RInterface/commands.R
RUN echo 'source("/scripts/RInterface.R")' >> /usr/local/lib/R/etc/Rprofile.site
CMD ["/init"]
