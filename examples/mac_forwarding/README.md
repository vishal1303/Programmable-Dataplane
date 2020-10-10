# MAC Forwarding

In this example we implement packet forwarding in P4 based on mac addresses. The hosts can either be mininet hosts or virtual machines (VMs). Below is the network topology used in this example:

![pod-topo](https://github.com/vishal1303/Programmable-Dataplane/blob/master/examples/mac_forwarding/pod-topo/pod-topo.png)

## Note

To work with linux bridges, add the following lines to the file `/etc/sysctl.conf`
```shell
net.bridge.bridge-nf-call-arptables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-ip6tables = 0
```
Then run the following command
```shell
$ sudo sysctl -p
```

These settings ensure that the packets traversing the bridge are not sent to host iptables for processing.

**Note:** These settings might not persist after a rebbot. So re-run `sudo sysctl -p` after a reboot.


## Using mininet hosts

1. Change the line 2 in `Makefile` to `TOPO = pod-topo/topology-with-hosts.json`

2. `sudo make run` This will start the mininet netowrk and return a mininet CLI

3. To exit, type `exit` in mininet CLI, followed by `sudo make clean`

## Using virtual machines (VMs)

1. Change the line 2 in `Makefile` to `TOPO = pod-topo/topology-with-vms.json`

2. `sudo make run` This will start the mininet netowrk and return a mininet CLI

3. In a separate terminal, run `./create_taps.sh` followed by `./create_vms.sh [linux/twizzler]`. If `linux` option is selected, this will start 4 Qemu-KVM VMs, and if `twizzler` option is selected, this will start 4 Twizzler VMs (remember to modify the script with the location of the twizzler folder on your system). It will then connect the VMs to the mininet network via the tap interfaces as shown in the diagram above.

4. [For linux VMs] Configure the IP address and ARP entries in each VM according to the respective commands for hosts mentioned in file `pod-topo/topology-with-hosts.json`

5. To exit, type `exit` in mininet CLI, followed by `./clean.sh`

**Tip:** To add new formats for match field entries, look into /home/vshrivastav/Programmable-DataPlane/utils/p4runtime_lib/convert.py
