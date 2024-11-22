#!/bin/bash

set -v -x

# Set these to your dGPU drivers and buses
DRIVERSVIDEO='nvidia'
DRIVERSAUDIO='snd_hda_intel'

BUSVIDEO='0000:01:00.0'
BUSAUDIO='0000:01:00.1'

# Unload NVIDIA DRM driver to prevent hangs
modprobe -r nvidia_drm

# Override devices drivers with vfio-pci ones
echo 'vfio-pci' > "/sys/bus/pci/devices/$BUSVIDEO/driver_override"
echo 'vfio-pci' > "/sys/bus/pci/devices/$BUSAUDIO/driver_override"

# Unbind devices from dGPU drivers
echo $BUSVIDEO > "/sys/bus/pci/drivers/$DRIVERSVIDEO/unbind"
echo $BUSAUDIO > "/sys/bus/pci/drivers/$DRIVERSAUDIO/unbind"

# Load vfio drivers and bind them to card
modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1
echo $BUSVIDEO > /sys/bus/pci/drivers/vfio-pci/bind
echo $BUSAUDIO > /sys/bus/pci/drivers/vfio-pci/bind

# End

