#!/usr/bin/env bash

set -e -x

find /sys/devices/ -type f -name power1_cap | parallel -v adaptive_limit_amd_power_cap

exit $?
