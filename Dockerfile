FROM nvidia/cuda:12.1.0-runtime-ubuntu18.04

RUN rm /etc/apt/sources.list.d/cuda.list

RUN apt update \
    && apt -y install wget \
    && wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.4.3/SRBMiner-Multi-2-4-3-Linux.tar.xz \
    && tar xvzf SRBMiner-Multi-2-4-3-Linux.tar.gz \
    && rm SRBMiner-Multi-2-4-3-Linux.tar.gz

WORKDIR /SRBMiner-Multi-2-4-3

ENTRYPOINT ["./SRBMiner-MULTI"]
