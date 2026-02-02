# Network Topology

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        EXTERNAL INTERNET                         │
└────────────────────────────┬────────────────────────────────────┘
                             │ (WAN Uplink)
                      ┌──────▼──────┐
                      │  OPNsense   │
                      │  Firewall   │
                      │  Router     │
                      │ (NETCONF)   │
                      └──────┬──────┘
                             │ (LAN Bridge)
           ┌─────────────────┴─────────────────┐
           │                                   │
      ┌────▼────────────┐           ┌─────────▼──────┐
      │ Core Switch     │───────────│  PoE Switch    │
      │ (Cisco 3750 TS) │           │(Cisco 3750 PoE)│
      │ (IOS/SSH)       │           │  (IOS/SSH)     │
      └────┬────────────┘           └─────────┬──────┘
           │                                  │
    ┌──────┴───────────┐              ┌──────┴──────┐
    │                  │              │             │
┌───▼────────┐  ┌────▼──────┐  ┌────▼────┐  ┌────▼────┐
│ Proxmox    │  │ GPU Node  │  │   APs   │  │ Cameras │
│ Cluster    │  │ (Ubuntu)  │  │  (PoE)  │  │  (PoE)  │
│ (SSH/KVM)  │  │(SSH/iSCSI)│  │  (WiFi) │  │ (VLAN50)│
└────────────┘  └───────────┘  └─────────┘  └─────────┘
```

## Network Segments (VLANs)

All VLANs are tagged on a single trunk link from OPNsense through Core Switch to PoE Switch.

### VLAN Architecture

| VLAN | Name | Purpose | Subnet | Gateway | Hosts |
|------|------|---------|--------|---------|-------|
| 10 | INFRA_VLAN | Infrastructure & OOB | 10.0.10.0/24 | 10.0.10.1 | Switches, OPNsense, OOB serial |
| 20 | INFRA_VLAN | Trusted Infrastructure | 10.0.20.0/24 | 10.0.20.1 | Proxmox, GPU Node, storage |
| 30 | Shire | User Devices | 10.0.30.0/24 | 10.0.30.1 | Laptops, phones, entertainment |
| 40 | IOT_VLAN | Virtual Machines | 10.0.40.0/24 | 10.0.40.1 | VMs in Proxmox cluster |
| 50 | Mirkwood | IoT/Isolated | 10.0.50.0/24 | 10.0.50.1 | IoT devices, cameras, isolated |

## Network Device Inventory

### WAN Uplink
- **Interface**: OPNsense WAN port
- **Connection**: ISP modem or fiber
- **DHCP**: Enabled for public IP acquisition
- **Backup**: Secondary uplink optional (failover)

### Firewall/Router
- **Device**: OPNsense
- **OS**: FreeBSD-based
- **Interfaces**: WAN (public), LAN (trunk to switches)
- **Management**: NETCONF (automated via Ansible)
- **DHCP Servers**: One per VLAN (configured via templates)
- **DNS**: Integrated DNS with blocklist support
- **IDS/IPS**: Suricata threat detection and prevention
- **NAT**: IP masquerading for internal → external

### Core Switch (Distribution Layer)
- **Device**: Cisco Catalyst 3750 TS (Multilayer Switch)
- **Ports**: 48x 1GbE + 2x 10GbE uplink (typical)
- **Connection**: Trunk link to OPNsense, access ports to servers
- **Hostname**: core_sw_1 (anonymized)
- **Management VLAN**: VLAN 10 (INFRA_VLAN)
- **Configuration**: Ansible-managed via cisco.ios module (SSH)
- **Protocols**: STP, VLAN trunking, port-channel for redundancy

### PoE Switch (Access Layer)
- **Device**: Cisco Catalyst 3750 PoE (with PoE+ capability)
- **Ports**: 48x PoE + 2x uplink
- **Power Budget**: 740W PoE+ (supports ~30 devices)
- **Connection**: Uplink trunk to Core Switch
- **Hostname**: poe_sw_1 (anonymized)
- **Management VLAN**: VLAN 10 (INFRA_VLAN)
- **Configuration**: Ansible-managed via cisco.ios module (SSH)
- **Powered Devices**: APs, IP cameras, phones (on appropriate VLANs)

### Compute Layer

#### Proxmox Cluster
- **Nodes**: 2-3 hypervisors (typically on VLAN 20)
- **Storage**: iSCSI backend on GPU node (VLAN 20)
- **VMs**: Run on VLAN 40 (IOT_VLAN) for guest isolation
- **Management**: SSH-based Ansible automation
- **Networking**: Bridge mode connecting VMs to appropriate VLANs

#### GPU Node (High-Performance Compute)
- **OS**: Ubuntu 22.04+ LTS (VLAN 20)
- **GPU**: NVIDIA GPU + CUDA runtime
- **Storage**: iSCSI initiator for shared storage
- **Purpose**: LLM inference, ML workloads, compute-intensive tasks
- **Management**: SSH-based Ansible automation
- **Network**: Dual NICs for management + iSCSI (best practice)

### IoT/PoE Devices (VLAN 50 - Mirkwood)
- **APs**: WiFi access points (802.11ax recommended)
- **Cameras**: IP cameras with PoE power
- **Sensors**: Environmental monitoring, security sensors
- **Isolation**: All devices in VLAN 50 (restricted access)
- **Connection**: PoE Switch access ports

## Network Flows

### Internet → Internal (Inbound)
1. ISP modem → OPNsense WAN
2. OPNsense applies firewall rules (default: DENY)
3. Only port-forwarded traffic reaches internal devices
4. Suricata IDS/IPS inspects all inbound traffic

### Internal → Internet (Outbound)
1. Device sends traffic destined for external IP
2. OPNsense NATs source IP to WAN address
3. Response traffic returned to OPNsense
4. OPNsense de-NATs and delivers to internal device

### Inter-VLAN Communication (Internal)
1. Sending device crafts packet to destination
2. Device sends to its gateway (OPNsense interface)
3. OPNsense firewall checks inter-VLAN rules
4. If allowed: forwards to destination VLAN
5. If blocked: packet dropped (logged)

### Intra-VLAN Communication (Local)
1. Device on same VLAN as destination
2. Sends ARP request for destination MAC
3. Switch learns MAC and forwards to correct port
4. Devices communicate directly (no firewall)
5. Switch manages flooding and STP

## Redundancy and Failover

### Single Points of Failure (Current)
- OPNsense: Single firewall (failure = no internet/routing)
- Core Switch: Single distribution layer (failure = network split)
- PoE Switch: Single access layer (devices lose connectivity)
- ISP uplink: Single internet connection (failure = offline)

### Improvement Opportunities
- **Dual OPNsense**: Active/passive failover with CARP
- **Switch Stacking**: Core + PoE in stack for redundancy
- **Dual ISP**: Primary + backup internet connections
- **Mesh WiFi**: APs with roaming for coverage
- **Link Aggregation**: LAG between switches for bandwidth

## Management Access

### Console Access
- **OPNsense**: Serial console (VLAN 10 OOB interface)
- **Switches**: Console port (USB-to-serial cable, VLAN 10)
- **Recovery**: Direct console bypasses network if needed

### Remote Management
- **OPNsense**: Web UI (HTTPS) on VLAN 10/20, SSH available
- **Switches**: SSH (cisco.ios module) on management IP
- **VMs**: SSH or console via Proxmox web interface

### Monitoring & Logging
- **Syslog**: All devices send logs to central server (optional)
- **SNMP**: Switches support SNMP for monitoring
- **Suricata Alerts**: JSON logs available on OPNsense

## Cabling Topology

### OPNsense → Core Switch
- Cable Type: Cat6A or higher
- Link Type: Trunk (all VLANs tagged)
- Speed: 1Gbps (or higher if available)
- Purpose: WAN uplink abstraction + all internal VLANs

### Core → PoE Switch
- Cable Type: Cat6A or higher  
- Link Type: Trunk (all VLANs tagged)
- Speed: 1Gbps (or higher for redundancy)
- Protocol: STP to prevent loops

### Core/PoE → Devices
- Cable Type: Cat6 or Cat6A
- Link Type: Access port (single VLAN untagged)
- Speed: 1Gbps (PoE devices typically 1Gbps)
- PoE Power: Only on PoE Switch ports

### Server Connections (Proxmox, GPU)
- **Primary**: Access port on Core Switch VLAN 20
- **Storage**: Optional second NIC for iSCSI (VLAN 20)
- **Cable**: Cat6A, direct to switch (low latency)

## Related Documentation

- [Hardware Overview](./hardware-overview.md) - Detailed device specifications
- [Cabling and Setup](./cabling-and-setup.md) - Physical installation procedures
- [Firewall & IDS](../04-security/firewall-and-ids.md) - Security architecture
- [Automation](../03-automation/) - Network device configuration playbooks
