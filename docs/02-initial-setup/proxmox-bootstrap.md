# Proxmox VE Bootstrap Guide

Complete setup guide for initializing Proxmox VE cluster nodes.

## Prerequisites

- Dedicated x86-64 servers (see [Hardware Overview](../01-hardware/hardware-overview.md))
- 64GB+ RAM per node (minimum 32GB)
- SSD storage for OS (120GB minimum)
- Network connectivity on VLAN 20 (INFRA_VLAN)
- Console access or Out-of-band (iLO/iDRAC) for first boot

## Installation Steps

### 1. Download Proxmox ISO

```bash
# Download latest stable (8.x LTS recommended)
# Visit: https://www.proxmox.com/proxmox-ve/get-started

# Verify integrity
sha256sum -c proxmox-ve_[version].iso.sha256
```

### 2. Create Boot Media

```bash
# On Linux/macOS
dd if=proxmox-ve_[version].iso of=/dev/[usb_device] bs=4M
sync

# On Windows
# Use Balena Etcher or Rufus
```

### 3. Boot and Install

1. Insert USB and boot system
2. Select "Install Proxmox VE"
3. Accept EULA
4. **Target Disk Selection**:
   - Choose SSD for best performance
   - Partition type: Choose ZFS (RAID1 if 2 disks available)

5. **Network Configuration**:
   - Hostname: pve-1, pve-2, pve-3 (cluster nodes)
   - Domain: lab.local
   - IP Address: 10.0.20.10/24 (pve-1), 10.0.20.11/24 (pve-2), etc.
   - Gateway: 10.0.20.1 (OPNsense)
   - DNS: 10.0.10.1 (OPNsense)

6. **Administrator Password**:
   - Set strong password (12+ chars, mixed case/numbers)
   - Note: This is root/admin account

7. **Installation Progress**:
   - Wait for installation (15-20 minutes typical)
   - Reboot when complete

## Web UI Initial Access

### 1. Access Proxmox Console

```
URL: https://10.0.20.10:8006
Username: root
Password: (the password set during install)
```

**Warning**: Browser will show SSL certificate warning (self-signed) - this is normal

### 2. System Updates

Node → System → Updates:
- Click "Check for Updates"
- Apply any available updates
- May require reboot

### 3. Change Root Password

User Management → Users:
- Click root@pam
- Change password to secure value
- Save

### 4. Network Configuration (If needed)

Node → System → Network:
- Verify management interface (vmbr0) is configured
- IP: 10.0.20.10/24
- Gateway: 10.0.20.1
- DNS: 10.0.10.1

If changes needed: Edit → Apply & Reboot

## Storage Configuration

### Local Storage (Already Configured)

Datacenter → Storage:
- Local (default) - uses ZFS on system disk
- Local-lvm - logical volume manager for VMs/containers

### iSCSI Storage (GPU Node Backend)

1. **Identify iSCSI Target**:
   - Target: GPU Node running iSCSI target
   - IQN: iqn.2024-01.local.cluster:target (example)
   - Portal: 10.0.20.[GPU_NODE_IP]:3260

2. **Add iSCSI Storage**:
   ```
   Datacenter → Storage → Add
   Type: ISCSI
   ID: iscsi-storage (friendly name)
   Content: Disk image, VZDump backup file
   Target: [GPU_NODE_IP]:3260
   IQN: iqn.2024-01.local.cluster:target
   ```

3. **Discover and Login**:
   - System discovers LUN automatically
   - Select LUN for storage
   - Login proceeds automatically

4. **Verify Storage**:
   - Proxmox → Storage → iscsi-storage
   - Should show available space
   - Can now use for VM storage

## Cluster Setup (If Multiple Nodes)

### Primary Node Only (pve-1)

1. **Create Cluster**:
   ```
   Node pve-1 → Cluster
   Click "Create Cluster"
   Cluster name: lab-cluster
   Ring0 address: 10.0.20.10 (management IP)
   ```

2. **Generate Join Token**:
   ```
   Cluster → Cluster
   Copy join information (token + fingerprint)
   Share with secondary node operators
   ```

### Secondary Nodes (pve-2, pve-3)

1. **Join Cluster**:
   ```
   Node pve-2 → Cluster
   Click "Join Cluster"
   Cluster name: lab-cluster
   Ring0 address: 10.0.20.11 (this node's IP)
   Peer address: 10.0.20.10 (primary node)
   Fingerprint: [paste from primary]
   Vote: Yes (enabled for HA)
   ```

2. **Verify Cluster Status**:
   ```
   Datacenter → Cluster
   All nodes should show "Online" (green)
   Quorum should be "OK"
   ```

### High Availability (Optional)

Datacenter → HA:
- [ ] Enable HA
- [ ] Configure watchdog device (fence failed nodes)
- [ ] Set autostart policies for critical VMs

## Default Storage Volumes

### Root Partition (System)
- ZFS: rpool or similar
- Size: ~50GB (varies with selection)
- Purpose: Proxmox OS and system files

### Data Partition (VM Storage)
- ZFS: tank or similar
- Size: Remaining disk space
- Purpose: Virtual machine disk images

## Initial VM/Container Creation

### Test VM Creation

1. **Create Linux VM**:
   ```
   Right-click node → Create VM
   VMID: 100 (unique across cluster)
   Name: test-vm
   Cores: 2
   Memory: 4GB
   Disk: 32GB (on local or iscsi-storage)
   Network: vmbr0 (bridge to VLAN 20)
   ```

2. **Install OS**:
   - Download Ubuntu/Debian ISO
   - Upload to ISO storage: Node → Storage → local (ISO images)
   - Boot VM from ISO and install OS
   - Verify network connectivity

3. **Network Configuration**:
   - VM gets IP via DHCP from OPNsense VLAN 20
   - Should be able to ping gateway (10.0.20.1)

## Backup Configuration

### Backup Storage (Optional)

1. **Create Backup Storage**:
   ```
   Datacenter → Storage → Add
   Type: Directory
   ID: backups
   Content: VZDump backup file
   Path: /var/lib/vz/backup (or separate mount)
   ```

2. **Configure Backup Job**:
   ```
   Node → Backup
   Create: Add Backup Job
   Node: All (or specific)
   Storage: backups
   Schedule: Daily at 2am
   Retention: Keep 7 daily backups
   ```

## Summary of Key Settings

| Setting | Value | Notes |
|---------|-------|-------|
| Management Network | VLAN 20 (10.0.20.0/24) | High-availability VLAN |
| Primary Node IP | 10.0.20.10 | pve-1 |
| Secondary Node IPs | 10.0.20.11, 10.0.20.12 | pve-2, pve-3 |
| Local Storage | ZFS (rpool/tank) | Fast SSD backing |
| iSCSI Storage | GPU Node backend | Shared VM storage |
| Backup Storage | NFS/iSCSI/local | Weekly/daily snapshots |
| Cluster Mode | HA Enabled | Auto-failover VMs |
| Default VM Network | vmbr0 → VLAN 20 | Management bridge |

## Verification Steps

### Cluster Health
```bash
# SSH to primary node
ssh root@10.0.20.10

# Check cluster status
pvecm status

# Verify all nodes online
pvecm nodes

# Check quorum
pvecm status | grep quorum
```

### Storage Verification
```bash
# Check local storage
pvesm list-content local

# Check iSCSI storage
pvesm list-content iscsi-storage

# Verify iSCSI connection
iscsiadm -m session -o show
```

### Networking
```bash
# Test connectivity
ping 10.0.20.1      # OPNsense gateway
ping 8.8.8.8        # Internet (via OPNsense NAT)
ping -I vmbr0 10... # Test bridge connectivity

# Check bridges
ip link show | grep vmbr
brctl show
```

## Troubleshooting

| Issue | Symptom | Solution |
|-------|---------|----------|
| Can't access web UI | Page timeout | Verify network connectivity, check if pve is running |
| Node offline | Shows "Offline" in cluster | SSH to node, restart corosync: `systemctl restart corosync` |
| iSCSI not discovered | Storage shows empty | Verify GPU node iSCSI target is running, check firewall |
| VM won't boot | Error during VM start | Check storage accessible, verify sufficient disk space |
| Network problems | VMs can't get IP | Verify vmbr0 bridge, check DHCP on OPNsense |
| High CPU usage | System sluggish | Check running VMs, verify ZFS performance |

## Best Practices

### Performance
- ✅ Use SSD local storage for OS
- ✅ Use iSCSI for shared VM storage
- ✅ Enable ZFS compression (lz4 recommended)
- ✅ Monitor CPU/RAM/disk usage regularly

### High Availability
- ✅ Always use 3 nodes for quorum (or odd number)
- ✅ Enable watchdog for automatic failover
- ✅ Test failover scenarios regularly

### Security
- ✅ Use SSH keys instead of passwords
- ✅ Limit web UI access to VLAN 10/20 (firewall rules)
- ✅ Enable two-factor authentication (optional)
- ✅ Keep Proxmox updated with security patches

### Backup & Recovery
- ✅ Configure automated backups weekly minimum
- ✅ Test backup restoration regularly
- ✅ Keep offsite copies of critical VM backups
- ✅ Document recovery procedures

## Ansible Automation

After initial manual setup, can be managed via Ansible:

```bash
# SSH into Proxmox node
ssh root@10.0.20.10

# Apply Ansible playbook
cd /root/home-infra/automation
ansible-playbook playbooks/proxmox.yml --check
ansible-playbook playbooks/proxmox.yml --vault-password-file .vault_pass
```

## Related Documentation

- [Network Topology](../01-hardware/network-topology.md) - Architecture
- [Hardware Overview](../01-hardware/hardware-overview.md) - Device specs
- [Cabling & Setup](../01-hardware/cabling-and-setup.md) - Physical setup
- [Proxmox Official Docs](https://pve.proxmox.com/wiki/Main_Page)
