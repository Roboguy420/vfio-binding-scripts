#!/bin/bash

# Set these to your dGPU drivers and buses
DRIVERSVIDEO='nvidia'
DRIVERSAUDIO='snd_hda_intel'

BUSVIDEO='0000:01:00.0'
BUSAUDIO='0000:01:00.1'

probe_and_check_ret() {
  module=$1
  failval=$2
  modprobe -i $module
  RETVAL=$?
  if [ $RETVAL -ne 0 ]; then
    echo "Failed to probe $module with exit code $RETVAL."
    exit $failval
  fi
}

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
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
  echo "Failed to probe graphics card drivers with exit code $RETVAL."
  exit 1
fi
echo Done!
echo -n "Binding graphics card drivers to card... "
echo $BUSVIDEO > "/sys/bus/pci/drivers/$DRIVERSVIDEO/bind"
echo $BUSAUDIO > "/sys/bus/pci/drivers/$DRIVERSAUDIO/bind"
echo Done!

# Keep these lines uncommented if you are on NVIDIA
# Comment these lines out otherwise
echo -n "Probing additional graphics card drivers... "
probe_and_check_ret nvidia-uvm 2
probe_and_check_ret nvidia-modeset 2
probe_and_check_ret nvidia-drm 2
echo Done!

# End
echo Graphics card successfully attached, you can now use the card on bare metal

