#!/bin/bash

set -xe

sudo ip tuntap add b1-tap1 mode tap
sudo ip tuntap add b2-tap1 mode tap
sudo ip tuntap add b3-tap1 mode tap
sudo ip tuntap add b4-tap1 mode tap

sudo ip link set b1-tap1 master b1
sudo ip link set b2-tap1 master b2
sudo ip link set b3-tap1 master b3
sudo ip link set b4-tap1 master b4

sudo ip link set dev b1-tap1 up
sudo ip link set dev b2-tap1 up
sudo ip link set dev b3-tap1 up
sudo ip link set dev b4-tap1 up
