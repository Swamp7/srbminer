#!/bin/bash
# SRBMiner refuses to run under Docker for two reasons:
#
#  1. It checks for /.dockerenv on startup and silently exits (code 0) if it
#     finds one. Removing the marker before launch works around it.
#  2. It reads /proc/PPID/stat and appears to bail if the parent looks like
#     a container init (runc-init as PID 1). So we deliberately do NOT `exec`
#     the miner — bash stays as parent and the miner sees a normal shell PPID.
#
# It also refuses to write to stdout when stdout is not a TTY (Vast/HiveOS
# never pass -t) — but a PTY wrapper (`unbuffer`/`script`) re-triggers the
# container detection. So we run SRBMiner with --log-file on a FIFO and
# `cat` the FIFO in the background — the log lines land on OUR stdout, which
# is the pipe `docker logs` reads. Users can still override --log-file to
# capture to a mounted volume; we detect that and skip the FIFO.

rm -f /.dockerenv

# If the user already passed --log-file, honor it and skip the FIFO plumbing.
user_has_logfile=0
for a in "$@"; do
    [[ "$a" == "--log-file" || "$a" == "--log-file="* ]] && user_has_logfile=1
done

if [[ "$user_has_logfile" == "1" ]]; then
    ./SRBMiner-MULTI "$@"
    exit $?
fi

FIFO=/tmp/srb.log
rm -f "$FIFO"
mkfifo "$FIFO"
cat "$FIFO" &
CAT_PID=$!

./SRBMiner-MULTI --log-file "$FIFO" "$@"
STATUS=$?

# Let cat drain the last of the pipe before we exit.
kill "$CAT_PID" 2>/dev/null
wait "$CAT_PID" 2>/dev/null
exit "$STATUS"
