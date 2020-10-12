#!/bin/bash

opt=$1

if [ $# != 1 ]
then
    echo "Wrong number of arguments. Usage -- ./create_vms.sh [linux/twizzler]"
    exit
fi

if [[ $opt = "linux" ]]
then
    echo "Starting 4 linux VMs.."
    sudo vagrant up
#    qemu-system-x86_64 -m 1024 -cdrom ~/Downloads/archlinux.iso -boot d -netdev tap,id=net0,ifname=b1-tap1,script=no,downscript=no -device e1000,netdev=net0,mac='08:00:00:00:01:11' -name vm1 -daemonize
#
#    qemu-system-x86_64 -m 1024 -cdrom ~/Downloads/archlinux.iso -boot d -netdev tap,id=net0,ifname=b2-tap1,script=no,downscript=no -device e1000,netdev=net0,mac='08:00:00:00:02:22' -name vm2 -daemonize
#
#    qemu-system-x86_64 -m 1024 -cdrom ~/Downloads/archlinux.iso -boot d -netdev tap,id=net0,ifname=b3-tap1,script=no,downscript=no -device e1000,netdev=net0,mac='08:00:00:00:03:33' -name vm3 -daemonize
#
#    qemu-system-x86_64 -m 1024 -cdrom ~/Downloads/archlinux.iso -boot d -netdev tap,id=net0,ifname=b4-tap1,script=no,downscript=no -device e1000,netdev=net0,mac='08:00:00:00:04:44' -name vm4 -daemonize

elif [[ $opt = "twizzler" ]]
then
    echo "Starting 4 twizzler VMs.."
    cd /home/vshrivastav/twizzler  #location of twizzler folder on the system
    sudo PROJECT=x86_64 QEMU_FLAGS='-display none' make all test INSTANCES="t,b1-tap1,08:00:00:00:01:11 t,b2-tap1,08:00:00:00:02:22 t,b3-tap1,08:00:00:00:03:33 t,b4-tap1,08:00:00:00:04:44"

else
    echo "Unrecognized command line argument. It must be linux or twizzler"
fi
