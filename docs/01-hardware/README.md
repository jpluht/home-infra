# Hardware Documentation

Complete physical infrastructure documentation for the home lab network.

## Overview

This section documents the physical hardware, network topology, and cabling layout for the entire infrastructure. It includes specifications, connections, and layout diagrams.

## Contents

- **network-topology.md** - Network architecture, VLAN design, and connectivity matrix
- **hardware-overview.md** - Detailed hardware specifications and device inventory
- **cabling-and-setup.md** - Physical cabling, port assignments, and setup procedures

## Key Infrastructure Components

### Compute Layer
- **Proxmox Cluster**: Virtualization hypervisors for VM management
- **GPU Node**: High-performance compute for LLM/AI workloads
- **Storage**: iSCSI-based shared storage backend

### Network Layer
- **Core Switches**: Cisco 3750 TS (distribution/aggregation)
- **PoE Switches**: Cisco 3750 PoE (access layer with power delivery)
- **OPNsense Firewall**: Routing, firewalling, and security services
- **Uplink**: External internet connectivity

### Network Segmentation (VLANs)
- **VLAN 10** (Rivendell): Infrastructure & Out-of-Band Management
- **VLAN 20** (Fellowship): Trusted Devices & Development
- **VLAN 30** (Shire): User Devices & Entertainment
- **VLAN 40** (Mordor): Virtual Machines & Guest Systems
- **VLAN 50** (Mirkwood): IoT & Isolated Devices

## Quick Links

For setup instructions, see: [Initial Setup Documentation](../02-initial-setup/)
For security policies, see: [Security Documentation](../04-security/)
