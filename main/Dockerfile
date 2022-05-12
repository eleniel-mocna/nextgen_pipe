FROM rocker/rstudio
LABEL NAME="NGSmain" Version="1.1"
LABEL author="Samuel Soukup"
LABEL contact="soukup.sam(at)gmail.com"

RUN apt-get update && apt-get install curl -y
RUN curl -fsSL https://get.docker.com | sh
RUN mkdir /DockerBuildInfo
COPY Dockerfile /DockerBuildInfo
COPY scripts /scripts

COPY README.md /README.md

CMD ["/init"]
