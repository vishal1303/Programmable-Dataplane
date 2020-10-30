#!/bin/bash

opt=$1

if [ $# != 1 ]
then
    echo "Wrong number of arguments. Usage -- ./create_vms.sh [linux/twizzler]"
    exit
fi

if [[ $opt = "linux" ]]
then
    echo "Starting 1 linux VM.."
    sudo qemu-system-x86_64 -nographic -kernel images/bzImage -hda images/wheezy.img -append "root=/dev/sda console=ttyS0" -netdev user,id=net0,hostfwd=tcp::2222-:22 -device e1000,netdev=net0 -netdev tap,id=net1,ifname=b4-tap1,script=no,downscript=no -device e1000,netdev=net1,mac='08:00:00:00:04:44' -name vm4

elif [[ $opt = "twizzler" ]]
then
    echo "Starting 3 twizzler VMs.."
    cd /home/vshrivastav/twizzler  #location of twizzler folder on the system
    sudo PROJECT=x86_64 QEMU_FLAGS='-display none' make all test INSTANCES="t,b1-tap1,08:00:00:00:01:11 t,b2-tap1,08:00:00:00:02:22 t,b3-tap1,08:00:00:00:03:33"

else
    echo "Unrecognized command line argument. It must be linux or twizzler"
fi
