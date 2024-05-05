#!/bin/bash

echo 0 > /sys/devices/system/cpu/cpufreq/boost

if [ `systemd-run -qP --user -M $SUDO_UID@.host playerctl status` != Stopped ]; then
  for device in $(bluetoothctl devices Connected | awk '{print $2}'); do bluetoothctl disconnect $device; done
fi

#sudo systemctl start nbminer

