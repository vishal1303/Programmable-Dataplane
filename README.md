# Programmable Dataplane Examples

This repository contains examples of P4 programmable network dataplane running inside
mininet.

## Environment setup

The setup assumes that you are running on an Ubuntu 16.04 machine with gcc version 5.

To check gcc version, run `gcc --version`

To install gcc 5, run
```shell
sudo apt install g++-5 gcc-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 2 --slave /usr/bin/g++ g++ /usr/bin/g++-5
sudo update-alternatives --config gcc
```
Then select gcc-5 as the default compiler.

Make sure `protobuf` and `thrift` are **not** installed. If they are installed, then uninstall them by entering into their respective source folders and running `sudo make uninstall`. Verify by running `protoc --version` and `thrift --version`; if uninstalled these commands should tell the same.

Next, go through the following steps:

1. First create a new user called p4 by running the command `sudo adduser p4`

2. Next, run `sudo visudo` and add the entry `p4 ALL=NOPASSWD: ALL` inside the file and exit.

3. Log in as the user p4 and copy the files `environment/root-bootstrap.sh` and `environment/user-bootstrap.sh` into your home folder `/home/p4/`

4. Go inside your home folder `/home/p4` and run
```shell
sudo ./root-bootstrap.sh
./user-bootstrap.sh
```
