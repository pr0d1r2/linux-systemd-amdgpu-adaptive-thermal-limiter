#!/usr/bin/env bash

source /etc/miner.env

case $1 in
  [1-9][0-9] | [1-9][0-9][0-9])
    AMDGPU_BEST_OPERATIONAL_TEMPERATURE="$(echo "$AMDGPU_BEST_OPERATIONAL_TEMPERATURE" | cut -b1-2)"
    ;;
  [1-9][0-9][0-9][0-9][0-9] | [1-9][0-9][0-9][0-9][0-9][0-9])
    ;;
  *)
    echo "Invalid temperature: '$1'"
    exit 101
    ;;
esac

TEMP_NOW=$1

echo "
  scale=2;
  a = $TEMP_NOW * 100 / $AMDGPU_BEST_OPERATIONAL_TEMPERATURE;
  if (a > -1 && a < 0) { print "'"-0"'"; a*=-1; }
  else if (a < 1 && a > 0) print 0;
  a" | bc 2>/dev/null | cut -f 1 -d .
