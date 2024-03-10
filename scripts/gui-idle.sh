#!/bin/bash

echo 0 > /sys/devices/system/cpu/cpufreq/boost

for device in $(bluetoothctl devices Connected | awk '{print $2}'); do bluetoothctl disconnect $device; done

sudo systemctl start nbminer

