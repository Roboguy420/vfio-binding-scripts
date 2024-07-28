#!/bin/bash

set -v -x

# Override devices drivers with vfio-pci ones
echo "vfio-pci" > /sys/bus/pci/devices/0000:01:00.0/driver_override
echo "vfio-pci" > /sys/bus/pci/devices/0000:01:00.1/driver_override

# Unbind devices from NVIDIA drivers
echo "0000:01:00.0" > /sys/bus/pci/drivers/nvidia/unbind
echo "0000:01:00.1" > /sys/bus/pci/drivers/snd_hda_intel/unbind

# Load vfio drivers and bind them to card
modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1
echo "0000:01:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
echo "0000:01:00.1" > /sys/bus/pci/drivers/vfio-pci/bind

# Detach devices from host
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1

# End

