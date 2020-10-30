#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>

#include <net/if.h>
#include <netinet/if_ether.h>
#include <linux/if_packet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>

#define TWIZZLER_PORT 9090 //port on twizzler machine
#define CONTROLLER_PORT 9091 //port on controller machine, i.e., this machine

#define CONTROLLER_SERVER_ADDR "10.0.2.2" //host address
#define CONTROLLER_SERVER_PORT 10000 //port on host machine

#define ETH_HDR_SIZE 14
#define UDP_HDR_SIZE 8
#define MSG_SIZE 256

typedef struct __attribute__((__packed__)) eth_hdr {
    uint8_t dst_mac[6];
    uint8_t src_mac[6];
    uint16_t type;
} eth_hdr_t;

typedef struct __attribute__((__packed__)) ip_hdr {
    uint8_t ver_and_ihl;
    uint8_t tos;
    uint16_t tot_len;
    uint16_t identification;
    uint16_t flags_and_offset;
    uint8_t ttl;
    uint8_t protocol;
    uint16_t hdr_checksum;
    uint8_t src_ip[4];
    uint8_t dst_ip[4];
} ip_hdr_t;

typedef struct __attribute__((__packed__)) udp_hdr {
    uint16_t src_port;
    uint16_t dst_port;
    uint16_t len;
    uint16_t checksum;
} udp_hdr_t;


int main(int argc, char* argv[])
{
    if (argc != 2) {
        fprintf(stderr,
            "usage: sudo ./controller_client <interface_name,e.g.,eth0>\n");
        exit(1);
    }

    assert(strlen(argv[1]) < IFNAMSIZ);

    //create a raw socket to listen to *every* packet on a given interface
    int raw_sock;
    struct sockaddr_ll addr;

	if ((raw_sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) < 0) {
        perror("raw socket");
        exit(1);
    }

    //get the id of the interface provided in argv[1]
    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));
    strncpy(ifr.ifr_name, argv[1], IFNAMSIZ);

    if (ioctl(raw_sock, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl");
        exit(1);
    }

    //bind to the interface
	addr.sll_family = AF_PACKET;
    addr.sll_protocol = htons(ETH_P_ALL);
    addr.sll_ifindex = ifr.ifr_ifindex;

    socklen_t socklen;
    socklen = (socklen_t) sizeof(addr);
    if (bind(raw_sock, (struct sockaddr *)&addr, socklen) < 0) {
        perror("bind");
        exit(1);
    }

	//create a UDP socket to send the message to controller server on host machine
	int udp_sock;
	struct sockaddr_in servaddr;

	if ((udp_sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("udp socket");
        exit(1);
    }

	bzero(&servaddr, sizeof(servaddr));

	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = inet_addr(CONTROLLER_SERVER_ADDR);
	servaddr.sin_port = htons(CONTROLLER_SERVER_PORT);

    //receive message
    fprintf(stdout, "\nReady to receive message..\n\n");

	while (1) {
        uint8_t* msg = (uint8_t *)malloc(sizeof(uint8_t)*MSG_SIZE);
        uint8_t* p = msg;

        memset(msg, 0, MSG_SIZE);

        if (recv(raw_sock, msg, MSG_SIZE, 0) < 0) {
            perror("recv");
            break;
        }

        //parse Ethernet
        eth_hdr_t* eth_hdr = (eth_hdr_t *)msg;
        if (ntohs(eth_hdr->type) != 0x0800) {
            //fprintf(stdout, "Received Ethernet packet of type 0x%04X; "
            //        "packet dropped\n", ntohs(eth_hdr->type));
            free(p);
            continue;
        }

        //parse IPv4
        msg += ETH_HDR_SIZE;
        ip_hdr_t* ip_hdr = (ip_hdr_t *)msg;
        uint8_t ihl = (ip_hdr->ver_and_ihl & 0b00001111) * 4; //in bytes
        if (ip_hdr->protocol != 0x11) {
            //fprintf(stdout, "Received IPV4 packet of type 0x%02X; "
            //        "packet dropped\n", ip_hdr->protocol);
            assert(msg != NULL);
            free(p);
            continue;
        }

        //parse UDP
        msg += ihl;
        udp_hdr_t* udp_hdr = (udp_hdr_t *)msg;
        if (ntohs(udp_hdr->src_port) != TWIZZLER_PORT
        || ntohs(udp_hdr->dst_port) != CONTROLLER_PORT) {
            //fprintf(stdout, "Received UDP packet from port %d -> %d; "
            //        "packet dropped\n", ntohs(udp_hdr->src_port),
            //        ntohs(udp_hdr->dst_port));
            free(p);
            continue;
        }

        //extract message
        msg += UDP_HDR_SIZE;
        printf("Received UDP packet from ('%d.%d.%d.%d', %d) msg = %s\n",
                ip_hdr->src_ip[0], ip_hdr->src_ip[1], ip_hdr->src_ip[2],
                ip_hdr->src_ip[3], ntohs(udp_hdr->src_port), msg);

		//send message
        sendto(udp_sock, msg, strlen(msg),
            MSG_CONFIRM, (const struct sockaddr *)&servaddr, sizeof(servaddr));
        printf("Sent message: %s\n\n", msg);

        free(p);
	}

	//close sockets
    close(raw_sock);
	close(udp_sock);

    return 0;
}
