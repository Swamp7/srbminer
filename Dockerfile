FROM nvidia/cuda:12.2.2-devel-ubuntu20.04

RUN rm -f /etc/apt/sources.list.d/cuda.list

RUN apt-get update \
    && apt-get -y install --no-install-recommends wget ca-certificates libjansson4 \
    && wget -O /tmp/srbminer.tar.gz https://github.com/doktor83/SRBMiner-Multi/releases/download/3.4.1/SRBMiner-Multi-3-4-1-Linux.tar.gz \
    && tar -xzf /tmp/srbminer.tar.gz \
    && rm /tmp/srbminer.tar.gz \
    && ln -sf libnvidia-ml.so.1 /lib/x86_64-linux-gnu/libnvidia-ml.so \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /SRBMiner-Multi-3-4-1

ENTRYPOINT ["./SRBMiner-MULTI"]
