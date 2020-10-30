#!/bin/bash

set -xe

ssh root@localhost -p 2222 'ifconfig eth2 10.0.0.4'
cc -o controller/controller_client controller/controller_client.c
scp -P 2222 controller/controller_client root@localhost:~/
sudo python controller/controller_server.py
