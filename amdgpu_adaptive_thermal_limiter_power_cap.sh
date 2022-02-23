#!/usr/bin/env bash

source /etc/miner.env
test -n "$AMDGPU_BEST_OPERATIONAL_TEMPERATURE" || exit 1

test -d /var/amdgpu_adaptive_thermal_limiter || mkdir -p /var/amdgpu_adaptive_thermal_limiter

case $1 in
  /sys/devices/pci0000:00/0000:00:[0-9a-f][0-9a-f].[0-9a-f]/0000:[0-9a-f][0-9a-f]:00.0/hwmon/hwmon1/power1_cap)
    CARD_PCIE_ID="$(dirname "$(dirname "$1")")"
    ;;
  /sys/devices/pci0000:00/0000:00:[0-9a-f][0-9a-f].[0-9a-f]/0000:[0-9a-f][0-9a-f]:00.0/0000:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f].0/0000:[0-9a-f][0-9a-f]:00.0/hwmon/hwmon[0-9]/power1_cap)
    CARD_PCIE_ID="$(basename "$(dirname "$(dirname "$(dirname "$1")")")")"
    ;;
  *)
    echo "Invalid power cap file name: '$1'"
    exit 101
    ;;
esac

POWER_CAP="$1"
POWER_DIR="$(dirname "$POWER_CAP")"
POWER_MIN="$(cat "$POWER_DIR/power1_cap_min")"
POWER_MAX="$(cat "$POWER_DIR/power1_cap_max")"
POWER_NOW="$(cat "$POWER_CAP")"
# Can be used to calcuilate relative stepping scale
POWER_MIN_PLUS_MAX=$(( POWER_MIN + POWER_MAX ))
POWER_PERCENTAGE=$(( POWER_NOW / POWER_MIN_PLUS_MAX / 2 * 100 ))

# NOTE: re-run last adjustment as this may be first run after restart - so we have continuity
LAST_ADJUSTMENT="/var/amdgpu_adaptive_thermal_limiter/$CARD_PCIE_ID.last_adjustment"
if [ -f "$LAST_ADJUSTMENT" ]; then
  cat "$LAST_ADJUSTMENT" > "$POWER_CAP"
fi

TEMP_NOW="$(cat "$POWER_DIR/temp1_input")"
TEMP_PERCENTAGE="$(temp_percentage "$TEMP_NOW")"

if [ $TEMP_NOW -ne $AMDGPU_BEST_OPERATIONAL_TEMPERATURE ]; then
  POWER_ADJUSTMENT_PERCENTAGE=$(( TEMP_PERCENTAGE + -100 ))
else
  POWER_ADJUSTMENT_PERCENTAGE=0
fi

X_TEMP_NOW=$(
  echo "
    scale=2;
    a = $TEMP_NOW / 1000;
    if (a > -1 && a < 0) { print "'"-0"'"; a*=-1; }
    else if (a < 1 && a > 0) print 0;
    a" | bc 2>/dev/null | cut -f 1 -d .
)

if [ $POWER_ADJUSTMENT_PERCENTAGE -ne 0 ]; then

  X_POWER_NOW=$(
    echo "
      scale=2;
      a = $POWER_NOW / 1000000;
      if (a > -1 && a < 0) { print "'"-0"'"; a*=-1; }
      else if (a < 1 && a > 0) print 0;
      a" | bc 2>/dev/null | cut -f 1 -d .
  )
  POWER_ADJUSTMENT=$(( $POWER_NOW * $(( 100 - $POWER_ADJUSTMENT_PERCENTAGE)) / 100 ))
  X_POWER_ADJUSTMENT=$(
    echo "
      scale=2;
      a = $POWER_ADJUSTMENT / 1000000;
      if (a > -1 && a < 0) { print "'"-0"'"; a*=-1; }
      else if (a < 1 && a > 0) print 0;
      a" | bc 2>/dev/null | cut -f 1 -d .
  )
  X_POWER_ADJUSTMENT_PERCENTAGE=$(
    echo "
      scale=2;
      a = $POWER_ADJUSTMENT_PERCENTAGE * -1;
      if (a > -1 && a < 0) { print "'"-0"'"; a*=-1; }
      else if (a < 1 && a > 0) print 0;
      a" | bc 2>/dev/null | cut -f 1 -d .
  )

  echo "$CARD_PCIE_ID: Temperature was '${X_TEMP_NOW}C' ($TEMP_PERCENTAGE%), adjusting power by '$X_POWER_ADJUSTMENT_PERCENTAGE%' from '${X_POWER_NOW}W' to '${X_POWER_ADJUSTMENT}W'"
  echo "$POWER_ADJUSTMENT" > "$POWER_CAP"
  echo "$POWER_ADJUSTMENT" > "$LAST_ADJUSTMENT"
else
  echo "$CARD_PCIE_ID: Temperature now is '${X_TEMP_NOW}C' ($TEMP_PERCENTAGE%), no adjustment needed..."
fi
