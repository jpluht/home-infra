# OPNsense Baseline Setup

Complete bootstrap guide for initial OPNsense firewall configuration.

## Prerequisites

- Dedicated x86-64 hardware (see [Hardware Overview](../01-hardware/hardware-overview.md))
- 8GB+ RAM recommended
- SSD storage (120GB minimum)
- Network connectivity to core switch via trunk port
- Serial console cable available for first boot

## Installation Steps

### 1. Download OPNsense ISO

```bash
# Download latest stable release
# Visit: https://opnsense.org/download/

# Verify checksum (important!)
sha256sum -c OPNsense-[version].iso.sha256
```

### 2. Create Installation Media

```bash
# On Linux/macOS
dd if=OPNsense-[version].iso of=/dev/[usb_device] bs=4M
sync

# On Windows
# Use Rufus or Etcher: https://www.balena.io/etcher/
```

### 3. Boot and Install

1. Insert USB media and boot system
2. Select "Install (UFS)" or "Install (ZFS)"
   - ZFS recommended for better reliability
3. Follow installer prompts:
   - Select disk for installation
   - Confirm installation (will wipe disk!)
4. Reboot when installation completes

### 4. Initial Console Setup

After reboot, system enters console configuration menu:

```
Available options:
  1) Assign Interfaces
  2) Set interface(s) IP address
  3) Reset webConfigurator password
  4) Reset to factory defaults
  5) Power off system
  6) Reboot system
  ...
```

**Steps**:

1. **Assign Interfaces** (Option 1)
   - WAN: Select NIC connected to ISP (or trunk port)
   - LAN: Select NIC for internal network (or same trunk)
   - Extra VLANs: No (we'll configure via web UI)

2. **Set IP Addresses** (Option 2)
   - WAN: DHCP (if ISP provides) or static IP
   - LAN: Set to 10.0.10.1/24 (VLAN 10 management)

3. **Password Reset** (Option 3) - Optional for first setup
   - Skip for now (use defaults, change via web UI)

4. **Save and Exit**
   - System comes online

## Web UI Initial Configuration

### 1. Access Dashboard

```
Navigate to: https://10.0.10.1
Username: admin
Password: opnsense (default)
```

**Security**: Change password immediately on first login!

### 2. System Update

System → Firmware → Automatic Updates:
- [ ] Check for Updates and Installs them
- [ ] Scheduled automatic updates

Then: System → Firmware → Check for Updates (manually trigger)

### 3. General Settings

System → Settings → General:
- **Hostname**: opnsense-fw (or similar)
- **Domain**: lab.local
- **Time Zone**: Set to local timezone
- **DNS Servers**: 8.8.8.8, 1.1.1.1 (or your preferred DNS)

### 4. Interface Configuration

Interfaces → Assignments:
- **WAN**: Ethernet interface connected to ISP
- **LAN**: Ethernet interface (trunk port) for internal network
- **Add VLAN interfaces** (optional - we'll configure via automation)

Interfaces → LAN:
- IPv4 Configuration Type: Static IPv4
- IPv4 Address: 10.0.10.1
- IPv4 Netmask: 255.255.255.0 (or /24)

### 5. DHCP Server Setup

Services → DHCP Server:

Create DHCP configuration for each VLAN (via Ansible later, but manual setup here):

**VLAN 10 (Rivendell - Infrastructure)**:
```
Range: 10.0.10.50 - 10.0.10.200
Gateway: 10.0.10.1
DNS Servers: 10.0.10.1
Lease Time: 3600
```

**VLAN 20 (Fellowship - Trusted)**:
```
Range: 10.0.20.50 - 10.0.20.200
Gateway: 10.0.20.1
DNS Servers: 10.0.10.1
```

**Similar for VLANs 30, 40, 50**

### 6. Firewall Rules

Firewall → Rules → WAN:
- Default: All traffic blocked (checked by default)

Firewall → Rules → LAN:
- Default: All traffic allowed (checked - keep for now)

Advanced rules configured via Ansible (see playbooks/opnsense.yml)

### 7. DNS Configuration

Services → DNS:
- **DNS Forwarders**: Checked (forward to public DNS)
- **Local Domain**: lab.local
- **Caching**: Enabled

### 8. Enable SSH Access

System → Settings → Administration:
- SSH: Check "Enable SSH"
- SSH Port: 22
- Permit Root: Unchecked (use admin user)

### 9. NTP (Time Synchronization)

Services → NTP:
- **Enable**: Checked
- **Servers**: pool.ntp.org
- **Restrict**: Ensure internal networks can access NTP

### 10. UPnP (Optional)

Services → UPnP:
- **Enable**: Unchecked (security best practice)

## VLAN Configuration (Via Web UI)

### Create VLAN Interfaces

Interfaces → Assignments:
- Click "Add" to create VLAN interfaces

For each VLAN (10-50):
```
Parent Interface: LAN (trunk port)
VLAN Tag: [10, 20, 30, 40, 50]
VLAN Priority: 0
Description: Rivendell (or appropriate name)
```

### Assign IP to Each VLAN Interface

Interfaces → [VLAN Name]:
```
IPv4 Configuration: Static IPv4
IPv4 Address: 10.0.XX.1 (where XX = VLAN ID * 10)
IPv4 Netmask: 255.255.255.0
```

## Initial Firewall Rules

### Create Base Rules (Manual - Later Automated)

Firewall → Rules → Add (for each):

**Allow Inter-VLAN Traffic (Selective)**:
```
Protocol: TCP/UDP
Source: VLAN 20 (Fellowship)
Destination: VLAN 40 (Mordor)
Port: Any
Action: Pass
```

**Block IoT VLAN (VLAN 50) Outbound**:
```
Protocol: Any
Source: VLAN 50 (Mirkwood)
Destination: Any
Port: Any
Action: Block
```

**Block VLAN 10 to Other VLANs** (OOB isolation):
```
Protocol: Any
Source: VLAN 10 (Rivendell)
Destination: VLANs 20,30,40,50
Port: Any
Action: Block
```

## Intrusion Detection/Prevention (Suricata)

Services → Intrusion Detection → General:
- [ ] Enable IDS
- [ ] Enable IPS (if desired)
- [ ] Home Net: 10.0.0.0/8

Download Threat Rules:
- Click "Update Rules" to get latest signatures

## Backup Initial Configuration

Diagnostics → Backup & Restore:
- Download configuration backup as XML
- Store in secure location
- Use for disaster recovery

## Testing Connectivity

### From Internal Device
```bash
# Test WAN connectivity
ping 8.8.8.8

# Test DNS
nslookup google.com

# Test NTP synchronization
ntpq -p
```

### Monitor Dashboard
System → Monitoring:
- Verify traffic statistics
- Monitor interfaces
- Check uptime

## SSH Access (Post Setup)

Once SSH enabled, can SSH from VLAN 10:
```bash
ssh admin@10.0.10.1
# Password: (the one you set)
```

## Automation via Ansible

After baseline setup, switch to Ansible-based configuration:

```bash
# Update inventory
echo "opnsense_fw ansible_host=10.0.10.1 ansible_user=admin" >> inventory/hosts

# Test NETCONF connection
ansible opnsense_fw -i inventory/hosts -m netconf_config -a "action=get"

# Apply full configuration
ansible-playbook playbooks/opnsense.yml --vault-password-file .vault_pass
```

## Troubleshooting

| Issue | Symptom | Solution |
|-------|---------|----------|
| Can't access web UI | Page timeout or refused | Verify network cable, check WAN/LAN assignments |
| No internet (WAN fails) | Can't ping external IPs | Verify WAN interface, check ISP connection |
| DHCP not working | Devices don't get IPs | Enable DHCP server, verify subnet config |
| Can't SSH | Connection refused | Enable SSH in System → Settings, use admin user |
| Time skew | NTP not synchronizing | Verify DNS works, set correct timezone |
| High CPU usage | System sluggish | Update to latest patch, disable unnecessary services |

## Best Practices

### Security
- ✅ Change admin password immediately
- ✅ Disable unnecessary services
- ✅ Keep firmware updated (enable auto-update)
- ✅ Use Suricata IDS/IPS for threat detection
- ✅ Restrict management access (SSH to VLAN 10 only)

### Performance
- ✅ Monitor WAN usage (dashboard)
- ✅ Enable hardware acceleration if available (Netgate appliances)
- ✅ Tune Suricata rules for performance

### Backup & Recovery
- ✅ Regular backups (weekly minimum)
- ✅ Test backup restoration procedure
- ✅ Store backups off-site if possible

## Related Documentation

- [Network Topology](../01-hardware/network-topology.md) - Architecture reference
- [Hardware Overview](../01-hardware/hardware-overview.md) - Device specifications
- [Firewall & IDS](../04-security/firewall-and-ids.md) - Security configuration
- [Ansible Playbooks](../03-automation/playbooks-and-templates.md) - Automation setup
