#!/bin/bash

if [[ $(lsmod | grep vfio) ]]; then
  sudo rmmod vfio-pci
  sudo modprobe nvidia
  sudo nvidia-smi -pm 1
  sudo nvidia-smi -pl 100
  sudo systemctl restart nbminer
fi

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock

