# ID Forwarding

In this example we implement packet forwarding in P4 based on custom ids. The hosts are Twizzler VMs. Below is the network topology used in this example:

![pod-topo](https://github.com/vishal1303/Programmable-Dataplane/blob/master/examples/id_forwarding/pod-topo/pod-topo.png)

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

## Using Twizzler VMs as hosts

1. Check the line 2 in `Makefile` is set to `TOPO = pod-topo/topology-with-vms.json`

2. Run the following command to start the mininet network
```shell
$ sudo make run
```

3. In a separate terminal, run 
```shell
$ ./create_taps.sh
$ ./create_vms.sh
```
This will start 4 Twizzler VMs (remember to modify the script with the location of the twizzler folder on your system) and connect them to the mininet network via the tap interfaces as shown in the diagram above.

4. Before running Step 3, make sure you have the following 4 commands running in 4 separate terminals,
```shell
$ sudo socat UNIX-LISTEN:twz_serial_1.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_2.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_3.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_4.sock,fork -,cfmakeraw
```

5. To exit, type `exit` in mininet CLI, followed by `./clean.sh`

**Tip:** To add new formats for match field entries, look into /home/vshrivastav/Programmable-Dataplane/utils/p4runtime_lib/convert.py

## Running Experiments

### Inside Twizzler VMs

1. To access twizzler VMs, go to the terminals started in Step 4 in the above section **Using virtual machines (VMs)**

2. Run connectivity tests inside each VM using the following command,
```shell
$ network <host ip address> twz
```
This will set the IP address of the host VM to `host ip address` and start sending twizzler packets with custom object ids in the packet header. The mapping of object ids to VMs is currently hard-coded.

**Note:** This is a work-in-progress!
