FROM openjdk:oraclelinux8
LABEL NAME="varScam" Version="1.0"
LABEL author="Samuel Soukup"
LABEL contact="soukup.sam(at)gmail.com"

COPY "VarScan.v2.4.2.jar" "/VarScan.jar"

RUN mkdir /DockerBuildInfo
COPY Dockerfile /DockerBuildInfo

COPY README.md /README.md

CMD ["/bin/bash"]
