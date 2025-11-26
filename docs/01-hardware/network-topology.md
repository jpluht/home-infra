# Network Topology

## Overview

- Internet → OPNsense → Core Switch → PoE Switch
- Core Switch connects to Proxmox, TrueNAS, and APs
- PoE Switch powers APs and other PoE devices
- VLANs: 10 (Infra), 20 (Trusted), 30 (Entertainment), 40 (VM), 50 (IoT)

## Diagram

See diagrams/network-topology.png for visual representation.
