#!/bin/bash

# Set these to your dGPU drivers and buses
DRIVERSVIDEO='nvidia'
DRIVERSAUDIO='snd_hda_intel'

BUSVIDEO='0000:01:00.0'
BUSAUDIO='0000:01:00.1'

# Override drivers with the dGPU ones
echo -n "Echoing graphics card drivers into driver_override... "
echo $DRIVERSVIDEO > "/sys/bus/pci/devices/$BUSVIDEO/driver_override"
echo $DRIVERSAUDIO > "/sys/bus/pci/devices/$BUSAUDIO/driver_override"
echo Done!

# Unbind devices from vfio-pci driver
echo -n "Unbinding video and audio buses from vfio drivers... "
echo $BUSVIDEO > /sys/bus/pci/drivers/vfio-pci/unbind
echo $BUSAUDIO > /sys/bus/pci/drivers/vfio-pci/unbind
echo Done!

# Load dGPU drivers and bind them to card
echo -n "Probing graphics card drivers... "
modprobe -i $DRIVERSVIDEO $DRIVERSAUDIO
echo Done!
echo -n "Binding graphics card drivers to card... "
echo $BUSVIDEO > "/sys/bus/pci/drivers/$DRIVERSVIDEO/bind"
echo $BUSAUDIO > "/sys/bus/pci/drivers/$DRIVERSAUDIO/bind"
echo Done!

# Keep these lines uncommented if you are on NVIDIA
# Comment these lines out otherwise
echo -n "Probing additional graphics card drivers... "
modprobe -i nvidia-uvm
modprobe -i nvidia-modeset
modprobe -i nvidia-drm
echo Done!

# End
echo Graphics card successfully attached, you can now use the card on bare metal

