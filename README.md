# srbminer

Dockerized [SRBMiner-Multi](https://github.com/doktor83/SRBMiner-Multi) that
**actually runs under Vast / HiveOS / plain `docker run`** — most SRBMiner
images silently do nothing under a container runtime because upstream
SRBMiner refuses to run when it detects Docker. This one works around that.

Image: [`swamp7/srbminer`](https://hub.docker.com/r/swamp7/srbminer)

## Tags

| Tag | SRBMiner-Multi version | Notes |
|---|---|---|
| `swamp7/srbminer:latest` | 3.6.0 | rolls forward with each release |
| `swamp7/srbminer:3.6.0` | 3.6.0 | AMD RDNA pearlhash, RTX 2000/CMP 40HX/50HX pearlhash speed+efficiency, optional `--pearl-k2` kernel for 2080Ti/50HX |
| `swamp7/srbminer:3.4.1` | 3.4.1 | previous build — has the container-detection problem, prefer `:3.6.0` |

## Usage

```bash
docker run --gpus all swamp7/srbminer:3.6.0 \
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
