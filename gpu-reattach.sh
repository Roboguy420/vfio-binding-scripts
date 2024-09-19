#!/bin/bash

set -v -x

# Set these to your dGPU drivers and buses
DRIVERSVIDEO='nvidia'
DRIVERSAUDIO='snd_hda_intel'

BUSVIDEO='0000:01:00.0'
BUSAUDIO='0000:01:00.1'

BUSVIDEOVIRSH='pci_0000_01_00_0'
BUSAUDIOVIRSH='pci_0000_01_00_1'

# Override drivers with the dGPU ones
echo $DRIVERSVIDEO > "/sys/bus/pci/devices/$BUSVIDEO/driver_override"
echo $DRIVERSAUDIO > "/sys/bus/pci/devices/$BUSAUDIO/driver_override"

# Reattach devices to host
virsh nodedev-reattach $BUSVIDEOVIRSH
virsh nodedev-reattach $BUSAUDIOVIRSH

# Unbind devices from vfio-pci driver
echo $BUSVIDEO > /sys/bus/pci/drivers/vfio-pci/unbind
echo $BUSAUDIO > /sys/bus/pci/drivers/vfio-pci/unbind

# Load dGPU drivers and bind them to card
modprobe -i $DRIVERSVIDEO $DRIVERSAUDIO
echo $BUSVIDEO > "/sys/bus/pci/drivers/$DRIVERSVIDEO/bind"
echo $BUSAUDIO > "/sys/bus/pci/drivers/$DRIVERSAUDIO/bind"

# Keep these lines uncommented if you are on NVIDIA
# Comment these lines out otherwise
modprobe -i nvidia-uvm
modprobe -i nvidia-modeset
modprobe -i nvidia-drm

# End

