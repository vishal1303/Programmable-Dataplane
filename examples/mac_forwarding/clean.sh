#!/bin/bash

#clean mininet
sudo make clean

#destroy taps
sudo ip link del b1-tap1
sudo ip link del b2-tap1
sudo ip link del b3-tap1
sudo ip link del b4-tap1

#destroy vms
sudo vagrant destroy --force vm1
sudo vagrant destroy --force vm2
sudo vagrant destroy --force vm3
sudo vagrant destroy --force vm4
