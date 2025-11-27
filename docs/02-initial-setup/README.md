# Initial Setup Documentation

Step-by-step guides for bootstrapping and initial configuration of all infrastructure components.

## Overview

This section covers the sequential setup procedures required to bring the home lab infrastructure online from a blank slate. Each guide is independent but should be followed in order to establish proper network foundation.

## Setup Sequence (Recommended Order)

### 1. Network Foundation
- **switch-setup.md** - Configure core and PoE switches with VLAN tagging and trunking
- **basic-network-testing.md** - Verify connectivity and basic network operations

### 2. Firewall & Routing
- **opnsense-baseline.md** - Initial OPNsense configuration for routing and DHCP

### 3. Compute Infrastructure  
- **proxmox-bootstrap.md** - Bootstrap Proxmox cluster nodes and shared storage

## Key Setup Considerations

### Network Segmentation
All devices must be configured into appropriate VLAN:
- **VLAN 10**: Out-of-band management (switch mgmt ports, OOB serial)
- **VLAN 20**: Infrastructure devices (OPNsense, proxmox mgmt)
- **VLAN 30**: Development & user devices
- **VLAN 40**: Virtual machines (guest devices)
- **VLAN 50**: IoT and isolated/untrusted devices

### Connectivity Verification
Before each stage completes, verify:
1. Devices can ping the gateway
2. VLAN tagging works correctly
3. Port trunking is functioning
4. DHCP is serving addresses in correct VLAN

### Credential Management
- **Initial credentials**: Set during device bootstrap (see each guide)
- **Vault secrets**: After setup, update ansible vault with production credentials
- **Access control**: Configure RBAC in Proxmox and firewall ACLs

## Quick Links

For automation setup after initial config, see: [Automation Documentation](../03-automation/)
For security hardening, see: [Security Documentation](../04-security/)
