FROM nvidia/cuda:12.2.2-devel-ubuntu20.04

RUN rm /etc/apt/sources.list.d/cuda.list

RUN apt update \
    && apt -y install wget \
    && apt -y install libjansson4 \
    && apt -y install xz-utils \
    && wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.5.8/SRBMiner-Multi-2-5-8-Linux.tar.xz \
    && tar xvf SRBMiner-Multi-2-5-8-Linux.tar.xz \
    && rm SRBMiner-Multi-2-5-8-Linux.tar.xz \
    && ln -s libnvidia-ml.so.1 /lib/x86_64-linux-gnu/libnvidia-ml.so

WORKDIR /SRBMiner-Multi-2-5-8

ENTRYPOINT ["./SRBMiner-MULTI"]
