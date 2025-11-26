# Hardware Overview

This document lists the main hardware components used in the home lab. For OpSec reasons, specific models, costs, and detailed specifications are not disclosed to avoid providing potential attack vectors.

## Devices

- **GPU Node:** Hosts AI/ML workloads and GPU-accelerated services.
- **TrueNAS:** Centralized storage, iSCSI for GPU node, backup.
- **Proxmox:** Virtualization platform for VMs.
- **OPNsense:** Firewall and router.
- **Cisco Switches:** Core and PoE switches for network segmentation.
- **Access Points (APs):** Wi-Fi coverage.
- **VoIP Phones:** Not critical, but present for voice communication.

## Physical Security Notes

- Store all devices in a locked server rack or cabinet to prevent unauthorized physical access.
- Use tamper-evident seals on critical devices like OPNsense and switches.
- Ensure the lab space has controlled access (e.g., in a home office with door locks).
- Source hardware from reputable vendors to maintain supply chain security.

## Network Topology

- OPNsense connects to the internet and core switch.
- Core switch connects to PoE switch, Proxmox, TrueNAS, and APs.
- PoE switch powers APs and other PoE devices.
- VLANs segment traffic for security and management (see network-topology.md for details).
