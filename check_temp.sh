#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_temp.sh
# Nagios plugin to check temperature from specified /sys entry.
#
# v0.0.2 - 2018/05/20 divide by 1000 when temp is 5 chars long
# v0.0.1 - 2018/05/20 initial check_temp.sh script written
#
# shellcheck disable=SC2194
# SC2194: This word is constant. Did you forget the $ on a variable?

usage() {
  echo "Usage: $0 -d [DEVICE] -w [WARN] -c [CRIT]"
  echo "Nagios plugin to check temperature from specified /sys entry."
  echo ""
  echo "Options:"
  echo "-d path to /sys entry"
  echo "-w warning temperature"
  echo "-c critical temperature"
  echo ""
  echo "ex: ./check_temp.sh -d /sys/class/thermal/thermal_zone0/temp -w 50 -c 55"
  echo "Temp OK: 32.593ºC /sys/class/thermal/thermal_zone0/temp | temp=32.593;;;"
  exit 1
}

while getopts d:w:c: option
do
  case "${option}" in
  d) DEVICE=${OPTARG};;
  w) WARN=${OPTARG};;
  c) CRIT=${OPTARG};;
  *)
    usage
    ;;
  esac
done

if [ -z "$1" ]; then
  usage
elif [ ! -f "$DEVICE" ]; then
  echo "UNKNOWN: $DEVICE does not exist."
  exit 1
elif [ -z "$WARN" ] && [ -z "$CRIT" ]; then
  echo "UNKNOWN: Missing warning and critical temperature."
  exit 1
elif [ -z "$WARN" ]; then
  echo "UNKNOWN: No warning temperature specified."
  exit 1
elif [ -z "$CRIT" ]; then
  echo "UNKNOWN: No critical temperature specified."
  exit 1
elif [ "$WARN" -gt "$CRIT" ]; then
  echo "UNKNOWN: Warning temperature cannot be greater than critical temperature."
  exit 1
elif [ "$WARN" -eq "$CRIT" ]; then
  echo "UNKNOWN: Warning temperature cannot equal critical temperature."
  exit 1
fi

# if temperature is 2 chars (ex: 56'C), make it look like (ex: 56.000C), else divide by 1000
LEN_DEV="$(cat "$DEVICE")"
if [ "${#LEN_DEV}" == "2" ]; then
  TEMP_SHORT="$(cat "$DEVICE")"
  TEMP_LONG="$(echo "scale=3; $(cat "$DEVICE") " | bc)"
elif [ "${#LEN_DEV}" == "3" ]; then
  echo "UNKNOWN: $(cat "$DEVICE") is out of bounds or extremely warm."
  exit 1
else
  TEMP_SHORT="$(echo "$(cat "$DEVICE") / 1000" | bc)"
  TEMP_LONG="$(echo "scale=3; $(cat "$DEVICE") / 1000" | bc)"
fi

# TEMP_SHORT is an integer, TEMP_LONG is a float
# XXX add ability to check float, i.e. is 32.583 <= 50.000?
case 1 in
  $((TEMP_SHORT>= CRIT )))
    STATE=CRITICAL
    ;;
  $((TEMP_SHORT>= WARN )))
    STATE=WARNING
    ;;
  *)
    STATE=OK
esac

echo "Temp ${STATE}: ${TEMP_LONG}ºC $DEVICE | temp=${TEMP_LONG};;;"
