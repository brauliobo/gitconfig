#!/bin/bash

if [[ $(lsmod | grep vfio) ]]; then
  sudo rmmod vfio-pci
  sudo modprobe nvidia
  sudo nvidia-smi -pm 1
  sudo nvidia-smi -pl 100
fi

systemctl --user enable --now swayidle

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock

