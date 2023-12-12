FROM nvidia/cuda:12.1.0-runtime-ubuntu18.04

RUN rm /etc/apt/sources.list.d/cuda.list

RUN apt update \
    && apt -y install wget \
    && apt -y install xz-utils \
    && wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.4.3/SRBMiner-Multi-2-4-3-Linux.tar.xz \
    && mkdir SRBMiner-Multi-2-4-3 \
    && tar xvf SRBMiner-Multi-2-4-3-Linux.tar.xz -C SRBMiner-Multi-2-4-3 \
    && rm SRBMiner-Multi-2-4-3-Linux.tar.xz

WORKDIR /SRBMiner-Multi-2-4-3

ENTRYPOINT ["./SRBMiner-MULTI"]
