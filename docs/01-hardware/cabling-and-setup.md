# Cabling and Physical Setup

Complete guide for physical installation, cabling, and initial hardware setup.

## Pre-Installation Checklist

### Planning Phase
- [ ] Verify all hardware has arrived and matches purchase orders
- [ ] Check serial numbers against documentation
- [ ] Inspect for physical damage or signs of tampering
- [ ] Review network topology diagram (see network-topology.md)
- [ ] Plan cable runs and rack layout
- [ ] Gather all tools (crimpers, testers, labels, tie-down straps)

### Tools Required
- Ethernet cable tester or multimeter
- Wire crimper for RJ-45 connectors (if making custom cables)
- Network monitoring tool (wireshark, tcpdump for testing)
- Labels and label maker
- Cable ties and velcro straps
- Grounding wrist strap and anti-static mat

## Rack Layout and Placement

### Physical Organization

**Rack Mount Order (Top to Bottom - Recommended)**:
```
Top (Hot aisle):
  1. Core Switch (48 ports + 2 uplink)
  2. PoE Switch (48 PoE ports + 2 uplink)
  3. OPNsense Firewall (management on left side)

Middle:
  4. Proxmox Node 1 (primary cluster node)
  5. Proxmox Node 2 (secondary cluster node)
  6. Proxmox Node 3 (if available)

Bottom (Cool aisle):
  7. GPU Node (high power, bottom placement for cooling)
  8. UPS (Uninterruptible Power Supply) - bottom for heavy unit
  9. PDU (Power Distribution Unit) - for power monitoring/control
```

### Cooling Considerations
- **Airflow Direction**: Front intake (cool) → Rear exhaust (hot)
- **Cable Routing**: Keep cables out of airflow paths
- **Gap Spacing**: 1-2 RU between high-heat devices for ventilation
- **Temperature Monitoring**: Install temperature sensors in rack

### Power Distribution
- **Primary UPS**: Main power source with battery backup
- **Secondary PDU**: Outlet control for remote reboot capability
- **Separate Circuits**: Critical devices on separate power circuits if possible
- **Grounding**: Ensure all metallic frames grounded to rack ground

## Cabling Specifications

### Ethernet Cable Standards

#### Cat6A (Recommended for Future-Proofing)
- **Speed**: 10 Gbps (1000BASE-T, 10GBASE-T)
- **Distance**: Up to 100m
- **Shielding**: Unshielded (UTP) standard
- **Diameter**: Slightly thicker than Cat6
- **Cost**: Premium, but supports future upgrades
- **Use Case**: All production/critical runs

#### Cat6 (Acceptable for 1Gbps)
- **Speed**: 1 Gbps (1000BASE-T)
- **Distance**: Up to 100m
- **Shielding**: Unshielded (UTP) standard
- **Diameter**: Standard for modern networking
- **Cost**: Budget-friendly
- **Use Case**: Non-critical/temporary runs, development

#### Cable Organization Best Practices
- ✅ Label BOTH ends of every cable (switch port + device interface)
- ✅ Use consistent labeling scheme (e.g., "SW-CORE-1-01" for switch port 1)
- ✅ Bundle cables with velcro straps (not zip ties - allow future adjustments)
- ✅ Separate power and ethernet cables (reduce electromagnetic interference)
- ✅ Run cables in overhead tray or wall conduit when possible
- ✅ Maintain minimum bending radius (10x cable diameter)

### Cable Runs (Specific Connections)

#### ISP Uplink → OPNsense WAN
- **Cable Type**: Cat6A, 1x
- **Length**: Typically 1-5m (ISP modem location dependent)
- **Label**: "WAN_UPLINK"
- **Speed**: Full ISP speed (no loss acceptable)
- **Notes**: Keep separate from internal cables

#### OPNsense LAN → Core Switch Trunk
- **Cable Type**: Cat6A, 1x (redundant: 2x for failover)
- **Length**: 1-2m (same cabinet or adjacent)
- **Label**: "TRUNK_OPN_CORE"
- **Speed**: 1Gbps (consider 10GbE if available)
- **VLAN Tagging**: 802.1Q all VLANs
- **Protocol**: Spanning Tree enabled to prevent loops

#### Core Switch → PoE Switch Trunk
- **Cable Type**: Cat6A, 1x (redundant: 2x optional)
- **Length**: 1-5m (typically same room)
- **Label**: "TRUNK_CORE_POE"
- **Speed**: 1Gbps
- **VLAN Tagging**: 802.1Q all VLANs
- **Port Channel**: Can create LAG for redundancy + bandwidth

#### Core Switch → Proxmox Nodes (Access Ports)
- **Cable Type**: Cat6, 1x per node (dual NICs: 2x per node optional)
- **Length**: 1-3m (within cabinet)
- **Label**: "ACCESS_CORE_PROXMOX1" (per node)
- **VLAN**: VLAN 20 (INFRA_VLAN) untagged
- **Speed**: 1Gbps (all nodes should aggregate 2Gbps+ if dual NICs)

#### Core Switch → GPU Node (Access Port)
- **Cable Type**: Cat6A, 2x (management + storage)
- **Length**: 1-3m
- **Label**: "ACCESS_GPU_MGMT" + "ACCESS_GPU_STORAGE"
- **VLAN**: VLAN 20 untagged on both
- **Speed**: 2Gbps combined (better isolation between mgmt/storage)

#### PoE Switch → APs/Cameras (Access Ports)
- **Cable Type**: Cat6, 1x per device
- **Length**: Variable (5-15m to reach APs)
- **Label**: "ACCESS_POE_AP1" (per device)
- **VLAN**: Untagged (AP configures native VLAN)
- **PoE Power**: 30W-90W per device (verify PoE budget)

## Installation Steps

### Phase 1: Physical Setup (30 min)

1. **Prepare Cabinet**
   - Ensure cabinet is secured to floor/wall
   - Install rails for rack-mount equipment
   - Test power delivery (plug in UPS, verify outlets)

2. **Mount Equipment**
   - Install UPS at bottom (heavy, needs stable base)
   - Mount PDU above UPS
   - Install switches (core above PoE for trunk cable run)
   - Mount Proxmox nodes in middle (easier access)
   - Mount GPU Node at bottom with extra cooling space

3. **Install Power Cables**
   - Connect UPS to mains power (grounded outlet)
   - Connect PDU to UPS output
   - Connect each device to PDU outlets
   - Label power cables (optional but helpful)
   - Test power button on each device

### Phase 2: Network Cabling (45 min)

1. **Connect ISP Uplink**
   - Cable from ISP modem → OPNsense WAN port
   - Test link light (both ends should light up)
   - Verify with `ip link show` or OPNsense web UI

2. **Connect Trunk Links**
   - Cable from OPNsense LAN → Core Switch designated uplink
   - Cable from Core Switch uplink → PoE Switch uplink
   - Configure as trunk ports (allow all VLANs tagged)
   - Test with `show int trunk` on Cisco switches

3. **Connect Access Ports**
   - Cable each Proxmox node to Core Switch VLAN 20 port
   - Cable GPU Node to Core Switch (2x NIC if available)
   - Cable APs/Cameras to PoE Switch (verify PoE budget)
   - Test connectivity with `ping` across devices

### Phase 3: Basic Connectivity Testing (30 min)

1. **Test OPNsense**
   - Web UI accessible on VLAN 10 management IP
   - Can reach internet (test ping to 8.8.8.8)
   - DHCP serving addresses on all VLANs

2. **Test Switches**
   - Can SSH to switch management IPs on VLAN 10
   - Show VLANs configured: `show vlan brief`
   - Verify trunk ports: `show int trunk`

3. **Test Compute Nodes**
   - Can SSH to Proxmox nodes on VLAN 20
   - Can SSH to GPU Node on VLAN 20
   - iSCSI connectivity between GPU Node and storage (if applicable)

4. **Test PoE Devices**
   - APs power on (PoE indicators light up)
   - Cameras power on and accessible
   - Check PoE power usage: `show power inline`

### Phase 4: Cable Management (20 min)

1. **Label All Cables**
   - Create label on both ends of every cable
   - Use consistent format: "SOURCE-PORT_DEST-PORT"
   - Example: "CORE-48_POE-01" (Core port 48 to PoE port 1)

2. **Organize Cable Runs**
   - Bundle cables with velcro straps (1-2 cable bundles per strap)
   - Route cables in cable tray if available
   - Keep power cables separate from data cables
   - Ensure cables aren't pinched or excessively bent

3. **Document Setup**
   - Photograph cable layout from multiple angles
   - Document switch port assignments in spreadsheet
   - Record MAC addresses of all devices
   - Store documentation in safe location

## Network Configuration (Post-Cabling)

### OPNsense Initial Setup
```bash
# Console access during first boot
1. Network interface configuration
   - Assign WAN interface to ISP uplink port
   - Assign LAN interface to trunk port (all VLANs)
   
2. IP configuration
   - WAN: DHCP (from ISP) or static (if provided)
   - LAN (VLAN 10): 10.0.10.1/24
   
3. Access web UI
   - Navigate to https://10.0.10.1
   - Complete initial wizard (language, timezone, etc)
```

### Switch Configuration (Ansible Automation)
After cabling complete, use Ansible playbooks to configure switches:
```bash
# Create inventory with switch IPs (VLAN 10)
cd automation
ansible-playbook playbooks/core_switches.yml --check
ansible-playbook playbooks/poe_switches.yml --check
# Review preview, then apply without --check
```

### Verification Steps
```bash
# Verify all devices reachable
ansible all -i inventory/hosts -m ping

# Check VLAN configuration
ansible core_switches -m cisco.ios.ios_command -a "commands='show vlan brief'"

# Verify PoE status
ansible poe_switches -m cisco.ios.ios_command -a "commands='show power inline'"
```

## Troubleshooting Common Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| No link lights | Cable not connected or defective | Test with link tester, try different port |
| Intermittent connectivity | Bad connection or cable damage | Replace cable, verify connection pressure |
| PoE devices not powering | Exceed PoE budget or port misconfigured | Check `show power inline`, enable PoE on port |
| Trunk not passing traffic | VLAN misconfiguration | Verify `show int trunk`, check VLAN allowed list |
| Can't reach management IP | Device not on VLAN 10 or IP conflict | SSH to switch via console, verify IP assignment |
| High latency | Congestion or suboptimal routing | Check `show int` stats, verify no errors/drops |

## Maintenance Schedule

### Weekly
- Verify all devices online and responsive
- Check temperature sensors (should be 10-25°C)
- Inspect cables for loose connections

### Monthly
- Verify link speeds (1Gbps where expected)
- Check PoE budget usage
- Review log files for errors

### Quarterly
- Clean equipment of dust (use compressed air)
- Verify cable labels are still readable
- Test failover paths (if redundancy configured)

### Annually
- Replace air filters in cooling systems
- Inspect cables for degradation
- Review capacity usage and plan upgrades

## Related Documentation

- [Network Topology](./network-topology.md) - Architecture and VLAN design
- [Hardware Overview](./hardware-overview.md) - Device specifications
- [Firewall & IDS](../04-security/firewall-and-ids.md) - OPNsense configuration
- [Ansible Playbooks](../03-automation/playbooks-and-templates.md) - Device automation
