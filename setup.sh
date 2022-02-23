#!/usr/bin/env bash

set -e -x

cd "$(dirname "$0")"

function cp_bin() {
  cp "$1.sh" "/usr/local/bin/$1" && chmod 755 "/usr/local/bin/$1"
  return $?
}

cp amdgpu_adaptive_thermal_limiter.service /etc/systemd/system/
cp_bin amdgpu_adaptive_thermal_limiter
cp_bin amdgpu_adaptive_thermal_limiter_power_cap
cp_bin temp_percentage

systemctl enable amdgpu_adaptive_thermal_limiter
systemctl start amdgpu_adaptive_thermal_limiter
