#!/usr/bin/env bash

set -e -x

cd "$(dirname "$0")/.."

docker build . -t pr0d1r2/linux-systemd-amdgpu-adaptive-thermal-limiter
