FROM gcc

LABEL NAME="starAligner" Version="1.0"
LABEL author="Samuel Soukup"
LABEL contact="soukup.sam(at)gmail.com"

RUN mkdir /DockerBuildInfo
COPY Dockerfile /DockerBuildInfo
COPY STAR-2.7.10a STAR
RUN cd STAR/source && make

COPY README.md /README.md

CMD ["/bin/bash"]
