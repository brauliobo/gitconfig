#!/bin/bash

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock

if [[ $(lsmod | grep vfio) ]]; then
  sudo rmmod vfio-pci
  sudo modprobe nvidia
  sudo nvidia-smi -pm 1
  sudo nvidia-smi -pl 100
  #sudo nvidia-settings -a "[gpu:0]/GPUFanControlState=1"
  #sudo nvidia-settings -a "[fan:0]/GPUTargetFanSpeed=90"
fi

if [ "$(loginctl show-session "$XDG_SESSION_ID" -p Type --value)" = "wayland" ]; then
  #systemctl --user enable --now swayidle
else
  #systemctl --user disable swayidle
fi
