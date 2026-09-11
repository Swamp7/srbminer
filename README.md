# srbminer

Dockerized [SRBMiner-Multi](https://github.com/doktor83/SRBMiner-Multi) that
**actually runs under Vast / HiveOS / plain `docker run`** — most SRBMiner
images silently do nothing under a container runtime because upstream
SRBMiner refuses to run when it detects Docker. This one works around that.

Image: [`swamp7/srbminer`](https://hub.docker.com/r/swamp7/srbminer)

## Tags

| Tag | SRBMiner-Multi version | Notes |
|---|---|---|
| `swamp7/srbminer:latest` | 3.6.5 | rolls forward with each release |
| `swamp7/srbminer:3.6.5` | 3.6.5 | `quantus` perf bumps on all supported NVIDIA GPUs; removed `neuromorph` algorithm |
| `swamp7/srbminer:3.6.4` | 3.6.4 | NEW algorithm `quantus` (Quantus Network) for NVIDIA + AMD RDNA (2.5% fee); QUIC/stratum pool support via new `--tls-cert-sha256`; pools: `eu.lproute.com:5660` / `quantus.suprnova.cc:7072`; use driver 580+ on RTX 5000 |
| `swamp7/srbminer:3.6.5` | 3.6.3 | NEW algorithm `noid` (Parano1d) for RTX 3000/4000/5000 + H100/B200/B300 and AMD RDNA 2/3/4 (3% fee, driver 580+ on NVIDIA, pool: `noid.suprnova.cc:3337`); randomx family minor perf; new `--noid-no-pause` flag |
| `swamp7/srbminer:3.6.2` | 3.6.2 | pearlhash bumps on H100/H200/B200/RTX 4000; minor CMP 70HX/90HX/170HX/A100 bumps; progpow fix on newer ROCM; new `--cpu-threads-percent` flag |
| `swamp7/srbminer:3.6.1` | 3.6.1 | **NEW B300 pearlhash support** (~706 TH/s @ 920W with `--gpu-cclock 1600`); B200 + unlocked CMP 70HX bumps; minor RTX 5000 bump |
| `swamp7/srbminer:3.6.0` | 3.6.0 | AMD RDNA pearlhash, RTX 2000/CMP 40HX/50HX pearlhash speed+efficiency, optional `--pearl-k2` kernel for 2080Ti/50HX. First build with container-detection fix. |
| `swamp7/srbminer:3.4.1` | 3.4.1 | previous build — has the container-detection problem, prefer `:3.6.0+` |

## Usage

```bash
docker run --gpus all swamp7/srbminer:3.6.5 \
    --algorithm pearlhash \
    --pool prl-us.kryptex.network:7048 \
    --wallet YOUR_KRYPTEX_ID \
    --worker rig01
```

`docker logs <container>` streams the miner's full output (hashrate, shares,
errors) — no volume mount required.

To capture the log to a file on the host as well, mount a directory and pass
`--log-file`:

```bash
docker run --gpus all -v /var/log/srb:/log swamp7/srbminer:3.6.0 \
    --algorithm pearlhash --pool ... --wallet ... --worker ... \
    --log-file /log/srb.log
```

The entrypoint detects a user-supplied `--log-file` and skips its internal
plumbing in that case.

## Why the extra entrypoint

SRBMiner has two anti-analysis checks that make it silently exit (code 0)
in a container after printing only `Detecting GPU devices...`:

1. It probes `/.dockerenv` and refuses to run if it exists.
2. It reads its parent process's `/proc/PPID/stat` and appears to bail if
   the parent looks like a container init (runc-init as PID 1).

The entrypoint removes `/.dockerenv` and keeps `bash` as SRBMiner's parent
process (no `exec` replacement). It also pipes SRBMiner's `--log-file` output
through a FIFO to bash's stdout so `docker logs` isn't blank — SRBMiner's
console output is `isatty()`-gated and would otherwise be invisible in a
non-TTY container. A PTY wrapper (`unbuffer`, `script`) re-triggers the
container-detection abort, so the FIFO is what actually works.

Everything else in the image is just glue: OpenCL ICD registration for
NVIDIA (nvidia-container-runtime doesn't install it), `libjansson4`, and
`ln -sf libnvidia-ml.so.1 libnvidia-ml.so` so NVML resolves.
