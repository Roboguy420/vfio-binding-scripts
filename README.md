# vfio-binding-scripts
These are the scripts I use for binding and unbinding my GPU to the vfio drivers so that it can be passed through to a VM.

Unlike most other vfio scripts that I've seen, this one should work even if your other non-passthrough card uses the same drivers as the passthrough card, since the binding is per-device. The scripts never unload the kernel modules. The modules are only probed in case they had been unloaded while not bound to any specific device.

## To-do
* Convert these into POSIX-compliant shell scripts rather than Bash scripts (they might already be POSIX-compliant but I'm too much of a Bash user to detect if I've used any Bashisms)
