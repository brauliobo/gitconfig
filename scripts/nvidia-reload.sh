#!/usr/bin/env bash
# Reload the NVIDIA kernel modules without rebooting on a headless machine.
# Only works when the new NVIDIA kernel module is built for the currently
# running kernel (uname -r). If the kernel itself was upgraded too, a reboot
# is required because loading a module built for a different kernel vermagic
# is unsafe.
#
# Usage:
#   nvidia-reload.sh [--kill] [--upgrade-utils] [--force]
#
# Options:
#   --kill           Send SIGTERM (then SIGKILL) to processes using /dev/nvidia*
#   --upgrade-utils  Upgrade nvidia-utils via pacman right before reloading
#   --force          Reload modules even if loaded and on-disk versions already match

set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SUDO=""
[[ "$EUID" -ne 0 ]] && SUDO="sudo"

KILL_PROCS=0
UPGRADE_UTILS=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --kill) KILL_PROCS=1 ;;
    --upgrade-utils) UPGRADE_UTILS=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

KVER="$(uname -r)"
LOADED_VER="$(cat /sys/module/nvidia/version 2>/dev/null || echo 'not-loaded')"
DISK_VER="$(modinfo -k "$KVER" -F version nvidia 2>/dev/null || echo 'missing')"
UTILS_VER="$(pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}' | cut -d- -f1 || echo 'unknown')"

echo "Running kernel : $KVER"
echo "Loaded module  : $LOADED_VER"
echo "On-disk module : $DISK_VER (for $KVER)"
echo "nvidia-utils   : $UTILS_VER"

if [[ "$DISK_VER" == "missing" ]]; then
  echo "Error: No nvidia kernel module found for running kernel $KVER." >&2
  echo "If the kernel was upgraded, reboot into the new kernel instead." >&2
  exit 1
fi

if [[ "$UPGRADE_UTILS" -eq 0 && "$UTILS_VER" != "unknown" && "$DISK_VER" != "$UTILS_VER" ]]; then
  echo "Error: On-disk module for $KVER is $DISK_VER, but nvidia-utils is $UTILS_VER." >&2
  echo "This usually means the kernel was also upgraded and the new $UTILS_VER module" >&2
  echo "lives under a newer /usr/lib/modules/<new-kernel>/ directory. A reboot is required." >&2
  exit 1
fi

if [[ "$UPGRADE_UTILS" -eq 1 ]]; then
  # Check what version pacman would install before touching anything
  CANDIDATE_VER="$(pacman -Sp --print-format '%v' nvidia-utils 2>/dev/null | head -n1 | cut -d- -f1 || true)"
  if [[ -n "$CANDIDATE_VER" && "$CANDIDATE_VER" != "$DISK_VER" ]]; then
    echo "Error: Repo nvidia-utils is $CANDIDATE_VER, but on-disk module for $KVER is $DISK_VER." >&2
    echo "A kernel upgrade is needed to load $CANDIDATE_VER; reboot instead." >&2
    exit 1
  fi
fi

if [[ "$FORCE" -eq 0 && "$LOADED_VER" == "$DISK_VER" && ( "$UPGRADE_UTILS" -eq 0 || "$UTILS_VER" == "$DISK_VER" ) ]]; then
  echo "Already up to date (loaded $LOADED_VER matches on-disk $DISK_VER and nvidia-utils $UTILS_VER). Nothing to do."
  exit 0
fi

# Check processes holding /dev/nvidia*
if $SUDO fuser /dev/nvidia* >/dev/null 2>&1; then
  echo "Processes currently using /dev/nvidia*:"
  $SUDO fuser -v /dev/nvidia* || true
  if [[ "$KILL_PROCS" -eq 0 ]]; then
    echo "Refusing to unload modules while GPUs are in use. Stop them or re-run with --kill." >&2
    exit 1
  fi
  echo "Terminating GPU processes..."
  $SUDO fuser -k -TERM /dev/nvidia* || true
  sleep 2
  if $SUDO fuser /dev/nvidia* >/dev/null 2>&1; then
    $SUDO fuser -k -KILL /dev/nvidia* || true
    sleep 1
  fi
fi

# Remember persistence state
PERSIST_ACTIVE=0
if systemctl is-active --quiet nvidia-persistenced 2>/dev/null; then
  PERSIST_ACTIVE=1
  echo "Stopping nvidia-persistenced..."
  $SUDO systemctl stop nvidia-persistenced
fi

# Disable kernel persistence mode if nvidia-smi works
PM_WAS_ON=0
if nvidia-smi --query-gpu=persistence_mode --format=csv,noheader 2>/dev/null | grep -qi "Enabled"; then
  PM_WAS_ON=1
  echo "Disabling persistence mode..."
  $SUDO nvidia-smi -pm 0 >/dev/null || true
fi

if [[ "$UPGRADE_UTILS" -eq 1 ]]; then
  echo "Upgrading nvidia-utils..."
  $SUDO pacman -S --noconfirm nvidia-utils
fi

echo "Unloading NVIDIA kernel modules..."
for mod in nvidia_drm nvidia_modeset nvidia_uvm nvidia_peermem nvidia; do
  if lsmod | awk '{print $1}' | grep -qx "$mod"; then
    $SUDO modprobe -r "$mod"
  fi
done

echo "Loading NVIDIA kernel modules for $KVER..."
$SUDO modprobe nvidia
$SUDO modprobe nvidia_uvm
$SUDO modprobe nvidia_modeset
$SUDO modprobe nvidia_drm

if [[ "$PERSIST_ACTIVE" -eq 1 ]]; then
  echo "Restarting nvidia-persistenced..."
  $SUDO systemctl start nvidia-persistenced
fi

if [[ -x /etc/nvidia-setup.sh ]]; then
  echo "Restoring GPU settings via /etc/nvidia-setup.sh..."
  $SUDO /etc/nvidia-setup.sh
elif [[ -r /etc/rc.local ]] && grep -qE '^[[:space:]]*(sudo[[:space:]]+)?nvidia-smi([[:space:]]|$)' /etc/rc.local; then
  echo "Restoring GPU settings from /etc/rc.local (nvidia-smi lines only)..."
  grep -E '^[[:space:]]*(sudo[[:space:]]+)?nvidia-smi([[:space:]]|$)' /etc/rc.local | $SUDO sh -e
elif [[ "$PERSIST_ACTIVE" -eq 0 && "$PM_WAS_ON" -eq 1 ]]; then
  echo "Re-enabling persistence mode..."
  $SUDO nvidia-smi -pm 1 >/dev/null || true
fi

echo "Verifying with nvidia-smi:"
nvidia-smi
