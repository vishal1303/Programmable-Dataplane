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

## Using virtual machines (VMs) as hosts

1. Check the line 2 in `Makefile` is set to `TOPO = pod-topo/topology-with-vms.json`

2. Run the following command to start the mininet network
```shell
$ sudo make run
```

3. In a separate terminal, run 
```shell
$ ./create_taps.sh
$ ./create_vms.sh [linux/twizzler]
```
If `linux` option is selected, this will start 4 Virtualbox VMs (the setup has also been tested and works with Qemu-KVM VMs). Instead, if `twizzler` option is selected, this will start 4 Twizzler VMs (remember to modify the script with the location of the twizzler folder on your system). It will then connect the VMs to the mininet network via the tap interfaces as shown in the diagram above.

4. **[For twizzler VMs]** Before running Step 3, make sure you have the following 4 commands running in 4 separate terminals,
```shell
$ sudo socat UNIX-LISTEN:twz_serial_1.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_2.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_3.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_4.sock,fork -,cfmakeraw
```

5. To exit, type `exit` in mininet CLI, followed by `./clean.sh`

**Tip:** To add new formats for match field entries, look into /home/vshrivastav/Programmable-Dataplane/utils/p4runtime_lib/convert.py

## Running Experiments

### Inside Mininet hosts

Refer to mininet documentation [https://github.com/mininet/mininet/wiki/Documentation] for instructions on how to run various experiments.

### Inside Linux VMs

1. Access the linux VMs using the following commands:
```shell
$ sudo vagrant ssh vm1
$ sudo vagrant ssh vm2
$ sudo vagrant ssh vm3
$ sudo vagrant ssh vm4
```

2. Run connectivity tests inside each VM, e.g., inside vm3 run
```shell
$ ping 10.0.0.1
```
to test connectivity between vm3 and vm1

3. Once the connectivity test passes, you are ready to run your custom applications!

**Troubleshooting:** Sometimes running `vagrant ssh` and `vagrant destroy` (inside `clean.sh`) with VM names as arguments from a terminal different to the one where `vagrant up` (inside `create_vms.sh`) was run, gives a namespace error. To get around the error, run `vagrant global-status` which returns a sample output like
```shell
id       name        provider       state   directory                             
----------------------------------------------------------------------------------
927f73e  vm1         virtualbox     running /Users/vishal/VM Images/virtualbox vm 
43a31be  vm2         virtualbox     running /Users/vishal/VM Images/virtualbox vm 
```
Then use the VM id instead of VM name as the argument for `vagrant ssh` and `vagrant destroy`

### Inside Twizzler VMs

1. To access twizzler VMs, go to the terminals started in Step 4 in the above section **Using virtual machines (VMs)**

2. Run connectivity tests inside each VM using the following command,
```shell
$ network <host ip address> ipv4 <dst ip address>
```
This will set the IP address of the host VM to `host ip address` and start sending IPV4 packets from the host VM to the destination VM

**Note:** This is a work in progress!
