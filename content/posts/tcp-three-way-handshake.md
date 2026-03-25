---
title: "How TCP's Three-Way Handshake Actually Works"
date: "2025-02-10"
readTime: "6 min read"
tags: ["networking", "tcp", "c"]
---

Every time you open a browser tab, your OS silently performs a three-way handshake before a single byte of HTTP data is sent. I've read about SYN, SYN-ACK, ACK dozens of times — but it didn't click until I watched it happen in a packet capture.

## The Problem TCP Solves

UDP is simple: you send a packet, you hope it arrives. TCP is a contract. Before any data flows, both sides agree they're ready to talk, synchronize their sequence numbers, and establish state on both ends.

The handshake does three things simultaneously:
- Proves both sides can send and receive
- Exchanges initial sequence numbers (ISNs)
- Allocates socket buffers on both ends

## Step by Step

**SYN** — The client picks a random ISN (let's call it `x`) and sends a segment with the SYN flag set and `seq=x`. No data yet.

**SYN-ACK** — The server receives it, picks its own ISN `y`, and responds with both SYN and ACK flags set: `seq=y, ack=x+1`. The `ack=x+1` means "I got your byte `x`, send me `x+1` next."

**ACK** — The client acknowledges the server's ISN: `seq=x+1, ack=y+1`. Connection is now established.

```c
/* Watching it happen with a raw socket */
struct tcphdr *tcp = (struct tcphdr *)(packet + ip_header_len);

if (tcp->syn && !tcp->ack)
    printf("SYN     seq=%u\n", ntohl(tcp->seq));
else if (tcp->syn && tcp->ack)
    printf("SYN-ACK seq=%u ack=%u\n", ntohl(tcp->seq), ntohl(tcp->ack_seq));
else if (tcp->ack && !tcp->syn)
    printf("ACK     seq=%u ack=%u\n", ntohl(tcp->seq), ntohl(tcp->ack_seq));
```

## Why Random ISNs?

If ISNs started at 0 every time, an attacker on the same network could predict the sequence number and inject forged segments into your connection. Random ISNs make this impractical — a classic example of security through unpredictability rather than secrecy.

Modern kernels also add a timestamp component to ISN generation to prevent sequence number wrapping on fast connections.

## The Half-Open Problem

What happens if the SYN-ACK never arrives? The client retransmits the SYN up to `tcp_syn_retries` times (default 6 on Linux), then gives up. The server, meanwhile, holds a half-open connection in its SYN queue — this is exactly what SYN flood attacks exploit.

Next time I'll look at how Linux's SYN cookies defend against this without keeping per-connection state.
