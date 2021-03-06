# ID Forwarding

In this example we implement packet forwarding in P4 based on either destination mac address or a custom id. The default forwarding is done based on the destination mac address in the Ethernet header. However, if the destination mac address of a packet is set to broadcast and the packet also contains a custom header (twizzler header) with a custom id, then forwarding is done based on the custom id. The default forwarding action is broadcast. The entire forwarding logic is implemented in `id_forwarding.p4`. Below is the network topology used in this example:

![pod-topo](https://github.com/vishal1303/Programmable-Dataplane/blob/master/examples/id_forwarding/pod-topo/pod-topo.png)

## Hosts

The hosts in the network are twizzler VMs. In this example, there are 3 hosts (vm1-vm3).

## Controller

The network controller comprises a linux VM (vm4) running `controller/controller_client.c` which receives control messages from the twizzler VMs over the mininet network, and relays those control messages to the controller server code (`controller/controller_server.py`) running on the host machine. The controller server then configures all the switches in the mininet network.

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

## Starting up the network

0. In three separate terminals, cd into the twizzler directory and run the following commands
```shell
$ sudo socat UNIX-LISTEN:twz_serial_1.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_2.sock,fork -,cfmakeraw
$ sudo socat UNIX-LISTEN:twz_serial_3.sock,fork -,cfmakeraw
```

1. For the remaining steps, our working directory is
```shell
$ cd Programmable-Dataplane/examples/id_forwarding
```
Inside this directory, first download the `images` folder from [here](https://drive.google.com/drive/folders/1QlC_Rd6sf64L5HsCGGKyChDBhqVFNzkd?usp=sharing). This folder contains the linux VM image for vm4.

**Important:** Make sure the folder name is `images` and it has two files `images/bzImage` and `images/wheezy.img`

2. Check the line 2 in `Makefile` is set to `TOPO = pod-topo/topology-with-vms.json`

3. Run the following command to start the mininet network
```shell
$ sudo make run
```

4. In a separate terminal, run 
```shell
$ ./create_taps.sh
$ ./create_vms.sh twizzler
```
This will start 3 twizzler VMs (remember to modify the script with the location of the twizzler folder on your system) and connect them to the mininet network via the tap interfaces as shown in the diagram above.

5. Next, in a separate terminal, run
```shell
$ ./create_vms.sh linux
```
This will start the linux VM acting as the network controller. Login credentials: username **root** password **root**

6. Next, start the controller server in a separate terminal
```
$ ./run_controller.sh
```
When prompted for `root@localhost's password:` enter **root**

This configures the controller VM (vm4) and starts the controller server (`controller/controller_server.py`) on the host machine

7. Finally, start the controller client inside vm4 by running the following command,
```shell
$ ./controller_client eth2
```
This opens up a raw socket on vm4 and binds it to the interface `eth2` (connected to the mininet network) to receive control messages from twizzler VMs. It then relays those messages to the controller server (on host) over the interface `eth0` via a UDP socket

**At this point, the network should be up and running!!**

8. To shutdown the network,
  - Type `exit` in the terminal running mininet CLI, followed by `./clean.sh` 
  - Next, shutdown the linux VM by running `shutdown -h now`
  - All other terminals can be terminated by simply pressing `cntrl + C`


## Running Experiments

**Note:** This is a work in progress!

1. To access twizzler VMs, go to the terminals started in Step 0

2. Run the follwong command inside each VM,
```shell
$ network <host_ip_address> <broadcast_ip_address> twz [0/1]
```
e.g., inside vm3 run
```shell
network 10.0.0.3 10.0.0.255 twz 0
```
This will set the IP and broadcast address of the host VM to `host_ip_address` and `broadcast_ip_address` respectively. Option 0 will run a controller-based resource discovery protocol, while option 1 will run an end-to-end resource discovery protocol
