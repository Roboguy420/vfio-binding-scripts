#!/bin/bash

set -v -x

# Override drivers with the NVIDIA ones
echo "nvidia" > /sys/bus/pci/devices/0000:01:00.0/driver_override
echo "snd_hda_intel" > /sys/bus/pci/devices/0000:01:00.1/driver_override

# Reattach devices to host
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

# Unbind devices from vfio-pci driver
echo "0000:01:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "0000:01:00.1" > /sys/bus/pci/drivers/vfio-pci/unbind

# Load NVIDIA drivers and bind them to card
modprobe -i nvidia nvidia-uvm snd_hda_intel
echo "0000:01:00.0" > /sys/bus/pci/drivers/nvidia/bind
echo "0000:01:00.1" > /sys/bus/pci/drivers/snd_hda_intel/bind

# Load additional kernel modules, these seem to only load properly if they're on separate lines
modprobe -i nvidia-modeset
modprobe -i nvidia-drm

# End

