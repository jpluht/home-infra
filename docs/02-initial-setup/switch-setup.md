# Cisco Switch Setup Guide

Step-by-step guide for initial configuration of core and PoE switches.

## Prerequisites

- Physical cabling complete (see [Cabling & Setup](../01-hardware/cabling-and-setup.md))
- Console cable and terminal access available
- IOS devices accessible via SSH (after initial config)
- Basic Cisco IOS knowledge or reference guide ready

## Core Switch Initial Setup

### Console Access (First Boot)

1. **Connect Console Cable**
   ```
   RJ-45 to USB serial adapter connected to laptop
   Terminal: ssh to switch, or use screen/miniterm
   ```

2. **Initial Configuration**
   ```
   Router# configure terminal
   Router(config)# hostname core_sw_1
   Router(config)# ip domain-name lab.local
   ```

### Management VLAN (VLAN 10 - Rivendell)

```ios
! Create management VLAN
configure terminal
vlan 10
  name Rivendell_Infrastructure
  exit

! Assign management interface
interface vlan 10
  ip address 10.0.10.2 255.255.255.0
  no shutdown
  exit

! Set default gateway
ip default-gateway 10.0.10.1

! Enable SSH
ip ssh version 2
ip ssh rsa keypair-name ssh-key
crypto key generate rsa modulus 2048
username admin privilege 15 secret [strong-password]
line vty 0 4
  transport input ssh
  login local
  exit
```

### VLAN Configuration (All 5 VLANs)

```ios
! Create all VLANs
configure terminal

vlan 20
  name Fellowship_Trusted
  exit

vlan 30
  name Shire_UserDevices
  exit

vlan 40
  name Mordor_VirtualMachines
  exit

vlan 50
  name Mirkwood_IoT_Isolated
  exit

! Verify VLANs created
end
show vlan brief
```

### Port Configuration (Core Switch)

```ios
! Example: Configure ports 1-48 as access ports
configure terminal

interface range gigabitethernet 0/1 - 48

! Disable spanning tree on access ports (BPDU guard enabled by default)
spanning-tree bpduguard enable
spanning-tree portfast

! Access port default assignment (will change per actual devices)
switchport mode access
switchport access vlan 20
no shutdown
exit

! Example: Assign specific ports to VLANs
interface range g0/1 - 10
  switchport access vlan 20   ! Proxmox nodes
  exit

interface range g0/11 - 20
  switchport access vlan 30   ! User devices
  exit

interface range g0/21 - 30
  switchport access vlan 40   ! VMs (if any direct connections)
  exit

interface range g0/31 - 40
  switchport access vlan 50   ! IoT devices
  exit

! Management access - VLAN 10
interface g0/41
  switchport access vlan 10   ! OOB management
  exit

! Uplink ports as trunk
interface range g0/47 - 48
  switchport mode trunk
  switchport trunk allowed vlan 1,10,20,30,40,50
  switchport trunk native vlan 10
  spanning-tree link-type point-to-point
  no shutdown
  exit
```

### Spanning Tree Configuration

```ios
! Enable STP for loop prevention
configure terminal
spanning-tree mode rapid-pvst

! Set switch as root for all VLANs (if it's primary)
spanning-tree vlan 1-50 priority 4096

! Verify STP
end
show spanning-tree summary
```

### Save Configuration

```ios
! Save running configuration to startup
copy running-config startup-config

! Verify it saved
show startup-config | include version
```

## PoE Switch Setup

Follow same procedure as Core Switch with these modifications:

### PoE-Specific Configuration

```ios
! Enable PoE on all ports
configure terminal
interface range g0/1 - 48
  power inline auto
  exit

! Set PoE priority (optional - higher = higher priority for power)
interface range g0/1 - 20
  power inline priority high
  exit

interface range g0/21 - 48
  power inline priority medium
  exit

! Verify PoE status
end
show power inline
show power inline totals
```

### PoE Port Naming

```ios
configure terminal
interface g0/1
  description AP_Main_Floor
  exit

interface g0/2
  description AP_Second_Floor
  exit

interface g0/3
  description Camera_Front
  exit

! Continue for all PoE devices...
```

## Trunk Configuration Between Switches

### Uplink Ports (Ports 47-48 on both switches)

```ios
! Core Switch: Uplink to PoE Switch
configure terminal
interface range g0/47 - 48
  switchport mode trunk
  switchport trunk allowed vlan 1,10,20,30,40,50
  switchport trunk native vlan 10
  spanning-tree link-type point-to-point
  spanning-tree guard root
  channel-group 1 mode active    ! Optional: LAG for redundancy
  exit

! Create port channel (if LAG desired)
interface port-channel 1
  switchport mode trunk
  switchport trunk native vlan 10
  exit

! Repeat on PoE Switch with same configuration
```

### Uplink to OPNsense

```ios
! On Core Switch - port facing OPNsense
configure terminal
interface g0/49
  description Trunk_To_OPNsense
  switchport mode trunk
  switchport trunk allowed vlan 1,10,20,30,40,50
  switchport trunk native vlan 10
  spanning-tree link-type point-to-point
  no shutdown
  exit
```

## Verification Steps

### Check VLAN Configuration
```ios
show vlan brief
show vlan id 10
show vlan id 20
! etc for all VLANs
```

### Verify Trunk Ports
```ios
show interfaces trunk
show interfaces port-channel 1  ! If LAG configured
```

### Check Port Status
```ios
show interfaces status
! Look for "connected" status on all connected ports
```

### Verify STP
```ios
show spanning-tree summary
show spanning-tree vlan 1-50
show spanning-tree detail
```

### Verify PoE (PoE Switch Only)
```ios
show power inline
show power inline totals
show power inline module 1
```

### Check SSH Access
```
# From another device on VLAN 10
ssh -l admin 10.0.10.2
# Should successfully log in
```

## Ansible-Based Automation

After manual switch setup (or to automate from this point), use Ansible:

```bash
# From automation directory
cd automation

# Create inventory/hosts with switch IPs
cat > inventory/hosts << 'EOF'
[core_switches]
core_sw_1 ansible_host=10.0.10.2 ansible_user=admin ansible_password=admin

[poe_switches]
poe_sw_1 ansible_host=10.0.10.3 ansible_user=admin ansible_password=admin
EOF

# Test connectivity
ansible core_switches -i inventory/hosts -m ping --vault-password-file ../.vault_pass

# Validate playbook
ansible-playbook playbooks/core_switches.yml --syntax-check

# Preview changes (dry-run)
ansible-playbook playbooks/core_switches.yml --check --vault-password-file ../.vault_pass

# Apply configuration
ansible-playbook playbooks/core_switches.yml --vault-password-file ../.vault_pass
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Can't SSH to switch | Management VLAN not configured or no IP assigned | Use console, verify VLAN 10 config and IP assignment |
| Ports not passing traffic | VLAN access mode not configured | Verify `show int status`, set `switchport mode access` |
| Spanning tree blocking ports | STP is blocking redundant links | Verify `show spanning-tree`, enable portfast on access ports |
| PoE devices not powering | Insufficient PoE budget or port disabled | Check `show power inline`, verify port admin status |
| Trunk not passing VLANs | Trunk mode not configured | Verify `show int trunk`, set `switchport mode trunk` |
| Port flapping up/down | Bad cable or duplex mismatch | Replace cable, check both ends for connection quality |

## Best Practices

### Configuration Management
- ✅ Always back up running config: `copy run start`
- ✅ Use SSH-only access (disable Telnet): `no ip telnet server`
- ✅ Change default credentials immediately
- ✅ Document all manual changes

### Port Management
- ✅ Use descriptive interface descriptions
- ✅ Disable unused ports: `shutdown` command
- ✅ Group related ports: `interface range g0/1 - 10`
- ✅ Use consistent naming convention

### Redundancy
- ✅ Enable rapid PVST for faster convergence
- ✅ Configure port channel for LAG/redundancy
- ✅ Set root bridge priority deliberately
- ✅ Test failover behavior regularly

### Security
- ✅ Limit SSH access to VLAN 10 only (firewall rules)
- ✅ Use strong passwords (12+ characters, mixed case/numbers)
- ✅ Enable SSH key authentication (remove password auth later)
- ✅ Review system logs for suspicious activity

## Related Documentation

- [Hardware Overview](../01-hardware/hardware-overview.md) - Device specifications
- [Network Topology](../01-hardware/network-topology.md) - Architecture reference
- [Cisco IOS Command Reference](https://www.cisco.com/c/en/us/support/docs/) - Official docs
- [Ansible cisco.ios Module](https://docs.ansible.com/ansible/latest/collections/cisco/ios/) - Playbook docs
