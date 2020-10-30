#!/bin/bash

#clean mininet
sudo make clean

#destroy taps
sudo ip link del b1-tap1
sudo ip link del b2-tap1
sudo ip link del b3-tap1
sudo ip link del b4-tap1

#remove the executable
rm controller/controller_client
