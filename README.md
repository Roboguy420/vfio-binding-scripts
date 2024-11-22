# vfio-binding-scripts
These are the scripts I use for binding and unbinding my GPU to the vfio drivers so that it can be passed through to a VM.

~~Unlike most other vfio scripts that I've seen, this one should work even if your other non-passthrough card uses the same drivers as the passthrough card, since the binding is per-device. The scripts never unload the kernel modules. The modules are only probed in case they had been unloaded while not bound to any specific device.~~

As of the most recent commit, in the case of a NVIDIA dGPU, the primary GPU (connected to your actual display) must have different drivers, thanks to a bug discovered where the detach script hangs if the nvidia_drm kernel module is loaded. nvidia_drm must be unloaded in order for the script to not hang, however this will very likely cause issues and breakages if the primary GPU is also NVIDIA. Unless someone tests this and proves otherwise (I cannot as I don't have an extra NVIDIA GPU to test with), **you can no longer use these scripts if you require NVIDIA drivers on both the dGPU and the primary GPU.**

## To-do
* Convert these into POSIX-compliant shell scripts rather than Bash scripts (they might already be POSIX-compliant but I'm too much of a Bash user to detect if I've used any Bashisms)
