FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

LABEL maintainer "pr0d1r2@gmail.com"
LABEL update "2022/02/23"

RUN apt-get update

COPY . /tmp/linux-systemd-amdgpu-adaptive-thermal-limiter
COPY docker/command-stub.sh /usr/bin/systemctl

WORKDIR /tmp/linux-systemd-amdgpu-adaptive-thermal-limiter
RUN bash ./setup.sh

RUN test -e /etc/systemd/system/amdgpu_adaptive_thermal_limiter.service
RUN test -x /usr/local/bin/amdgpu_adaptive_thermal_limiter
RUN test -x /usr/local/bin/amdgpu_adaptive_thermal_limiter_power_cap
RUN test -x /usr/local/bin/temp_percentage
