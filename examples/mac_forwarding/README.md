# MAC Forwarding

In this example we implement L2 forwarding in P4. The hosts can either be mininet hosts or virtual machines (VMs). Below is the network topology used in this example:

![pod-topo](https://github.com/vishal1303/Programmable-DataPlane/blob/master/examples/mac_forwarding/pod-topo/pod-topo.png)

## Using mininet hosts

1. Change the line 2 in `Makefile` to `TOPO = pod-topo/topology-with-hosts.json`

2. `sudo make run` This will start the mininet netowrk and return a mininet CLI

3. To exit, type `exit` in mininet CLI, followed by `sudo make clean`

## Using virtual machines (VMs)

1. Change the line 2 in `Makefile` to `TOPO = pod-topo/topology-with-vms.json`

2. `sudo make run` This will start the mininet netowrk and return a mininet CLI

3. In a separate terminal, run `./create_taps.sh` followed by `./create_vms.sh [linux/twizzler]`. If `linux` option is selected, this will start 4 Qemu-KVM VMs, and if `twizzler` option is selected, this will start 4 Twizzler VMs (remember to modify the script with the location of the twizzler folder on your system). It will then connect the VMs to the mininet network via the tap interfaces as shown in the diagram above.

4. Configure the IP address and ARP entries in each VM according to the respective commands for hosts mentioned in file `pod-topo/topology-with-hosts.json`

4. To exit, type `exit` in mininet CLI, followed by `./clean.sh`
