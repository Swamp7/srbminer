FROM nvidia/cuda:12.2.2-devel-ubuntu20.04

RUN rm /etc/apt/sources.list.d/cuda.list

RUN apt update \
    && apt -y install wget \
    && apt -y install libjansson4 \
    && apt -y install xz-utils \
    && wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.6.3/SRBMiner-Multi-2-6-3-Linux.tar.gz \
    && tar xvf SRBMiner-Multi-2-6-3-Linux.tar.gz \
    && rm SRBMiner-Multi-2-6-3-Linux.tar.gz \
    && ln -s libnvidia-ml.so.1 /lib/x86_64-linux-gnu/libnvidia-ml.so

WORKDIR /SRBMiner-Multi-2-6-3

ENTRYPOINT ["./SRBMiner-MULTI"]
