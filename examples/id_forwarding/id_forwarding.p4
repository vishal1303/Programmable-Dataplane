/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<128> objectId_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

header twizzler_t {
    objectId_t objectId;
    bit<8> twzOp;
    bit<16> twzType;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t ethernet;
    twizzler_t twizzler;
}


/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x0700: parse_twizzler;
            default: accept;
        }
    }

    state parse_twizzler {
        packet.extract(hdr.twizzler);
        transition accept;
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action broadcast() {
        standard_metadata.mcast_grp = 1;
    }

    action mac_forward(egressSpec_t egress_port) {
        standard_metadata.egress_spec = egress_port;
    }

    action id_forward(egressSpec_t egress_port) {
        standard_metadata.egress_spec = egress_port;
    }

    table mac_table {
        key = {
            hdr.ethernet.dstAddr: exact;
        }

        actions = {
            drop;
            broadcast;
            mac_forward;
        }
        size = 1024;
        default_action = broadcast();
    }

    table id_table {
        key = {
            hdr.twizzler.objectId: exact;
        }

        actions = {
            drop;
            broadcast;
            id_forward;
        }
        size = 1024;
        default_action = broadcast();
    }

    apply {
        if (hdr.ethernet.isValid()) {
            if (hdr.ethernet.etherType == 0x0700
            && hdr.ethernet.dstAddr == 0xFFFFFFFFFFFF) {
                if (hdr.twizzler.isValid()) {
                    id_table.apply();
                }
            } else {
                mac_table.apply();
            }
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    action drop() {
        mark_to_drop(standard_metadata);
    }

    apply {
        // Prune broadcast packet to ingress port to preventing loop
        if (standard_metadata.egress_port == standard_metadata.ingress_port) {
            drop();
        }
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply { }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        //parsed headers have to be added again into the packet.
        packet.emit(hdr.ethernet);
        packet.emit(hdr.twizzler);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

//switch architecture
V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
