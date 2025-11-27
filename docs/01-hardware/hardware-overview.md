# Hardware Overview

Complete physical hardware specifications and inventory for the home lab infrastructure.

**Note**: For OpSec and security reasons, specific models, serial numbers, costs, and detailed specifications are anonymized to prevent supply chain attacks and device fingerprinting.

## Hardware Inventory Summary

### Network Infrastructure

#### WAN Uplink
- **Type**: ISP-provided connection (fiber/cable/DSL)
- **Speed**: Multi-gigabit capable (typical 100+ Mbps)
- **Redundancy**: Single connection (primary)
- **Future**: Dual ISP with failover recommended

#### Firewall/Router - OPNsense
- **Form Factor**: x86-64 compatible hardware (desktop/mini-ITX/rack appliance)
- **CPU**: Multi-core processor (2+ GHz)
- **RAM**: 8GB+ (16GB recommended for Suricata IDS/IPS)
- **Storage**: SSD preferred (120GB minimum)
- **NICs**: Dual Gigabit minimum (WAN + LAN trunk)
- **Management**: NETCONF-enabled, SSH available
- **OS**: FreeBSD (OPNsense distribution)
- **Features**: Stateful firewall, NAT, IDS/IPS, DNS, DHCP, VPN

#### Core Switch (Distribution Layer)
- **Model**: Cisco Catalyst 3750 TS (multilayer switch)
- **Ports**: 48x 10/100/1000 Mbps + 2x 10GbE uplink
- **Backplane**: High throughput for wire-speed switching
- **Stack**: Can stack up to 9 switches for high availability
- **VLAN Support**: Supports 4094 VLANs
- **PoE**: Capable (limited power budget, primarily for PoE switch uplink)
- **Management**: SSH via Cisco IOS CLI
- **Protocol Support**: STP, RSTP, portfast, port-channel, LACP
- **Console**: RJ-45 + USB serial

#### PoE Switch (Access Layer)
- **Model**: Cisco Catalyst 3750 PoE (with PoE+ capability)
- **Ports**: 48x 10/100/1000 Mbps PoE + 2x 1GbE uplink
- **PoE Power Budget**: 740W total (supports ~30-40 PoE devices)
- **Backplane**: Layer 3 switching capability
- **VLAN Support**: Full VLAN support like core switch
- **Management**: SSH via Cisco IOS CLI
- **Uplink**: Trunk to Core Switch
- **Console**: RJ-45 + USB serial

### Compute Infrastructure

#### Proxmox Cluster (Hypervisor Nodes)
- **Nodes**: 2-3 physical servers (minimum 2 for cluster)
- **CPU**: Multi-core x86-64 (Intel Xeon E5+ or AMD EPYC preferred)
- **RAM**: 64GB+ per node (scales with VM count)
- **Storage**: 
  - **Local**: SSD for OS + fast VM storage (500GB+)
  - **Shared**: iSCSI backend on GPU node (see GPU Node section)
- **NICs**: Dual Gigabit minimum (management + cluster traffic)
- **Virtualization**: KVM/QEMU with full VM support
- **OS**: Proxmox VE (Debian-based)
- **Management**: Web UI (port 8006), SSH access
- **Clustering**: Corosync + Pacemaker for HA

#### GPU Node (High-Performance Compute)
- **OS**: Ubuntu 22.04 LTS (desktop/server)
- **CPU**: Multi-core x86-64 processor
- **GPU**: NVIDIA GPU (A100/A6000/RTX series for AI/ML)
- **CUDA**: Support for CUDA compute capability 3.5+
- **RAM**: 256GB+ (LLM model cache + batch processing)
- **Storage**:
  - **Local**: Fast NVMe SSD (1TB+) for OS, models cache
  - **iSCSI**: Initiator connecting to shared storage backend
- **NICs**: Dual Gigabit (management + iSCSI, separate networks preferred)
- **Power Supply**: 2000W+ modular PSU (high power GPU = 300-400W)
- **Cooling**: Active cooling (GPU nodes generate significant heat)
- **CUDA Toolkit**: Version 11.8+ for latest models
- **Drivers**: NVIDIA proprietary driver (470+)

### Networking & PoE Devices

#### WiFi Access Points (VLAN 30 - Shire & VLAN 50 - Mirkwood)
- **Type**: WiFi 6 (802.11ax) or WiFi 5 (802.11ac) minimum
- **Power**: PoE+ powered (90W maximum)
- **Antennas**: Internal or external (site-dependent)
- **Mesh Support**: Optional mesh networking for roaming
- **VLANs**: Segregated per device type (user APs on VLAN 30, IoT on VLAN 50)
- **Management**: Centralized controller or local Web UI

#### IP Cameras (VLAN 50 - Mirkwood/IoT)
- **Type**: PoE+ powered network cameras (4K-capable)
- **Power**: 95-240W PoE+ consumption varies
- **Resolution**: 1080p minimum, 4K preferred for security
- **Compression**: H.264 or H.265 (better compression)
- **Frame Rate**: 30fps minimum
- **Ports**: RJ-45 (PoE) + optional audio/alarm I/O
- **Recording**: Optional on-board SD card, NVR integration

#### IoT Devices (VLAN 50 - Mirkwood)
- **Types**: Sensors, smart plugs, environmental monitors
- **Power**: PoE, AC power, or battery
- **Protocols**: WiFi, Ethernet, Zigbee, Z-Wave
- **Integration**: Home automation hub (optional)
- **Isolation**: Segregated to VLAN 50 for security

### Storage Infrastructure

#### Backup Storage (Optional/Future)
- **Type**: NAS with iSCSI backend or local NVMe RAID
- **Capacity**: 10TB+ for VM backups
- **Redundancy**: RAID 6 or RAID 10 recommended
- **Protocol**: iSCSI for Proxmox integration
- **Backup Frequency**: Weekly full + daily incremental

### Cabling & Passive Infrastructure

#### Ethernet Cabling
- **Type**: Cat6A (10Gbps capable, future-proofing)
- **Shielding**: Unshielded twisted pair (UTP) standard, STP optional
- **Runs**: Organized in cable trays or conduit
- **Distance**: <100m per run (Ethernet standard)
- **Management**: Labeling at both ends (patch panel + switch)

#### Power Delivery
- **UPS (Uninterruptible Power Supply)**: 2000+ VA capacity
- **Surge Protection**: UPS with battery backup recommended
- **PDU (Power Distribution Unit)**: Outlet-controlled or monitored PDU
- **Power Budget**: 
  - OPNsense: 200W
  - Core Switch: 300W
  - PoE Switch: 500W (with PoE budget)
  - Each Proxmox node: 500W
  - GPU Node: 2000W (peak with GPU)
  - Total: ~4-5kW max load

#### Environmental
- **Rack/Cabinet**: Secure enclosure with cooling
- **Cooling**: Passive airflow or active fans (depends on environment)
- **Temperature**: Keep 10-30°C (50-86°F) for optimal operation
- **Humidity**: 20-80% RH (non-condensing)
- **Ventilation**: Adequate air intake and exhaust paths

## Physical Security

### Access Control
- ✅ All devices in locked server cabinet or secure room
- ✅ Physical access restricted to authorized personnel
- ✅ Security cameras monitoring equipment area
- ✅ Tamper-evident seals on critical devices

### Cabling Security
- ✅ Organized cable management (no loose cables)
- ✅ Labeled and documented all connections
- ✅ Secure cable runs to prevent unauthorized taps
- ✅ No external cables visible or accessible

### Supply Chain Security
- ✅ Hardware sourced from reputable vendors
- ✅ Verify devices on arrival (serial numbers, packaging)
- ✅ Document all hardware assets with serial numbers
- ✅ Track firmware versions for all devices

### Environmental Protection
- ✅ Adequate air conditioning/cooling
- ✅ UPS protection against power failures
- ✅ Grounding and surge protection
- ✅ Fire suppression system (optional but recommended)

## Hardware Specifications Summary Table

| Component | Type | Count | Specs | VLAN |
|-----------|------|-------|-------|------|
| WAN | ISP | 1 | Multi-Gbps | External |
| Firewall | OPNsense | 1 | Dual NIC, SSD | VLAN 10 (Mgmt) |
| Core Switch | Cisco 3750 TS | 1 | 48x GbE + 2x 10GbE | VLAN 10 |
| PoE Switch | Cisco 3750 PoE | 1 | 48x PoE + 2x GbE | VLAN 10 |
| Proxmox Node | Hypervisor | 2-3 | 64GB+ RAM, Multi-core | VLAN 20 |
| GPU Node | Compute | 1 | NVIDIA GPU, 256GB+ RAM | VLAN 20 |
| WiFi AP | Access Point | 2-4 | WiFi 6, PoE+ | VLAN 30/50 |
| IP Camera | Video | 2-8 | 4K, PoE+ | VLAN 50 |
| IoT Device | Sensors | 5-20 | Mixed power | VLAN 50 |

## Capacity Planning

### Current Capacity
- **Network**: 1Gbps per device to core (adequate for most workloads)
- **Compute**: 3-4 medium VMs or 1-2 large VMs per Proxmox node
- **Storage**: Variable (depends on backup retention)
- **PoE**: ~30-40 PoE devices on PoE Switch

### Growth Planning
- **Network**: Upgrade to 10GbE core links within 3-5 years
- **Compute**: Add Proxmox nodes as VM count exceeds capacity
- **Storage**: Expand iSCSI backend as backup needs grow
- **PoE**: Second PoE switch if device count > 40

## Related Documentation

- [Network Topology](./network-topology.md) - Architecture and VLAN design
- [Cabling and Setup](./cabling-and-setup.md) - Physical installation procedures
- [Ansible Playbooks](../03-automation/playbooks-and-templates.md) - Device automation
