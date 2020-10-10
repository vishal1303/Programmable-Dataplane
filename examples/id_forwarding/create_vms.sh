#!/bin/bash

echo "Starting 4 twizzler VMs.."
cd /home/vshrivastav/twizzler  #location of twizzler folder on the system
sudo PROJECT=x86_64 QEMU_FLAGS='-display none' make all test INSTANCES="t,b1-tap1,08:00:00:00:01:11 t,b2-tap1,08:00:00:00:02:22 t,b3-tap1,08:00:00:00:03:33 t,b4-tap1,08:00:00:00:04:44"
