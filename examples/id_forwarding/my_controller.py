import socket
import sys
import os

workdir = os.getcwd()
print workdir
sys.path.append(os.getcwd() + '/../../utils/')

import run_exercise

sw_names = ["s1", "s2", "s3", "s4"]

sw_json_files = {
        "s1": {'runtime_json': 'pod-topo/s1-runtime.json'},
        "s2": {'runtime_json': 'pod-topo/s2-runtime.json'},
        "s3": {'runtime_json': 'pod-topo/s3-runtime.json'},
        "s4": {'runtime_json': 'pod-topo/s4-runtime.json'}
        }

mac_table = {
        "s1": {"08:00:00:00:01:11": 1,
               "08:00:00:00:02:22": 2,
               "08:00:00:00:03:33": 3,
               "08:00:00:00:04:44": 4
               },
        "s2": {"08:00:00:00:01:11": 3,
               "08:00:00:00:02:22": 4,
               "08:00:00:00:03:33": 1,
               "08:00:00:00:04:44": 2
               },
        "s3": {"08:00:00:00:01:11": 1,
               "08:00:00:00:02:22": 1,
               "08:00:00:00:03:33": 2,
               "08:00:00:00:04:44": 2
               },
        "s4": {"08:00:00:00:01:11": 1,
               "08:00:00:00:02:22": 1,
               "08:00:00:00:03:33": 2,
               "08:00:00:00:04:44": 2
               },
        }


def insert_table_entry(msg):
    machine_addr = ""
    object_id = ""
    count = 0
    assert(len(msg) == 44)
    for c in msg:
        if count < 10:
            if count % 2 == 0:
                machine_addr += c
            else:
                machine_addr += c + ":"
        elif count == 10 or count == 11:
            machine_addr += c
        elif count > 11 and count < 42:
            if count % 2 == 0:
                object_id += c
            else:
                object_id += c + ":"
        elif count == 42 or count == 43:
            object_id += c
        count += 1

    for sw in sw_names:
        entry = {
          "table": "MyIngress.id_table",
          "match": {
            "hdr.twizzler.objectId": object_id
          },
          "action_name": "MyIngress.id_forward",
          "action_params": {
            "egress_port": mac_table[sw][machine_addr]
          }
        }
        run_exercise.ExerciseRunner().program_switch_p4runtime(sw, sw_json_files[sw], 1, entry)


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the port
server_address = ('localhost', 10000)
print >>sys.stderr, 'starting up controller on %s port %s' % server_address
sock.bind(server_address)

# Listen for incoming connections
sock.listen(1)

while True:
    # Wait for a connection
    print >>sys.stderr, 'waiting for a connection'
    connection, client_address = sock.accept()

    try:
        print >>sys.stderr, 'connection from', client_address

        # Receive the data in small chunks
        msg = ""
        while True:
            data = connection.recv(16)
            for c in data:
                if c == ":":
                    print msg
                    insert_table_entry(msg)
                    msg = ""
                else:
                    msg += c
    finally:
        # Clean up the connection
        connection.close()
