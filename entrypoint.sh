#!/bin/sh
echo "Init..."
exec multirun derper_run.sh tailscale_run.sh
echo "Exited..."