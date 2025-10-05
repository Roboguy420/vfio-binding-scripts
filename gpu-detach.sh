#!/bin/bash

# Set this to the number of times you want to check if GPU is in use
# Err on the side of caution, as any uncaught processes could lead to the script hanging and forcing you to restart
NUM_GPU_CHECKS=20
CHECK_INTERVAL=0.02

# Set these to your dGPU drivers and buses
DRIVERSVIDEO='nvidia'
DRIVERSAUDIO='snd_hda_intel'

BUSVIDEO='0000:01:00.0'
BUSAUDIO='0000:01:00.1'
GPUIDX='0'


check_gpu_use () {
  # Check if any processes are accessing them
  PIDS=$(cat \
    <(lsof -t "/dev/dri/by-path/pci-$BUSVIDEO-card") \
    <(lsof -t "/dev/dri/by-path/pci-$BUSVIDEO-render") \
    <(lsof -t "/dev/nvidia$GPUIDX") | sort -n | uniq \
  )

  if [ -n "$PIDS" ]; then
    return 1
  fi

  return 0
}


# Check if the GPU is in use
echo -n 'Checking if GPU is in use by other processes... '
for i in $(seq $NUM_GPU_CHECKS); do
  check_gpu_use
  if [ $? -ne 0 ]; then
    echo -e "\nCannot detach GPU as it is still in use by the following processes:\n$PIDS"
    exit 1
  fi
  sleep $CHECK_INTERVAL
done
echo Done!

# Unload NVIDIA DRM driver to prevent hangs
echo -n 'Unloading nvidia_drm... '
modprobe -r nvidia_drm
echo Done!

# Override devices drivers with vfio-pci ones
echo -n 'Echoing vfio-pci drivers into driver_override... '
echo 'vfio-pci' > "/sys/bus/pci/devices/$BUSVIDEO/driver_override"
echo 'vfio-pci' > "/sys/bus/pci/devices/$BUSAUDIO/driver_override"
echo Done!

# Unbind devices from dGPU drivers
echo -n 'Unbinding video and audio buses from drivers... '
echo $BUSVIDEO > "/sys/bus/pci/drivers/$DRIVERSVIDEO/unbind"
echo $BUSAUDIO > "/sys/bus/pci/drivers/$DRIVERSAUDIO/unbind"
echo Done!

# Load vfio drivers and bind them to card
echo -n 'Probing vfio drivers... '
modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1
echo Done!
echo -n 'Binding vfio drivers to card... '
echo $BUSVIDEO > /sys/bus/pci/drivers/vfio-pci/bind
echo $BUSAUDIO > /sys/bus/pci/drivers/vfio-pci/bind
echo Done!

# End
echo Graphics card successfully detached, you can now pass the card through to a VM

