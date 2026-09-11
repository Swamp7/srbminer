FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ARG SRB_VERSION=3.6.5
ARG SRB_DASH_VERSION=3-6-5
ARG TARBALL_URL=https://github.com/doktor83/SRBMiner-Multi/releases/download/${SRB_VERSION}/SRBMiner-Multi-${SRB_DASH_VERSION}-Linux.tar.gz

RUN rm -f /etc/apt/sources.list.d/cuda.list

# ocl-icd-libopencl1 + /etc/OpenCL/vendors/nvidia.icd: SRBMiner uses OpenCL
#         even on NVIDIA. The container runtime mounts libnvidia-opencl.so.1
#         but does NOT register the ICD; without this the miner reports
#         "Found 1 OpenCL platforms, but none is AMD, NVIDIA OR INTEL".
# libjansson4: SRBMiner runtime dependency.
RUN apt-get update \
    && apt-get -y install --no-install-recommends wget ca-certificates libjansson4 ocl-icd-libopencl1 \
    && mkdir -p /etc/OpenCL/vendors \
    && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd \
    && wget -O /tmp/srbminer.tar.gz "$TARBALL_URL" \
    && tar -xzf /tmp/srbminer.tar.gz \
    && mv /SRBMiner-Multi-${SRB_DASH_VERSION} /srbminer \
    && rm /tmp/srbminer.tar.gz \
    && ln -sf libnvidia-ml.so.1 /lib/x86_64-linux-gnu/libnvidia-ml.so \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /srbminer

# entrypoint.sh removes /.dockerenv and keeps bash as SRBMiner's PPID. Both
# steps are required — without them the miner silently exits code 0 after
# printing "Detecting GPU devices...", which is why Vast/HiveOS deployments
# of SRBMiner have historically been unusable.
ENTRYPOINT ["/entrypoint.sh"]
