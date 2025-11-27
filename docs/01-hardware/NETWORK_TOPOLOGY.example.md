# Network Topology Template (Generic Example)

**IMPORTANT**: This is a PUBLIC EXAMPLE with placeholder values. 

For your **actual network topology**, see: `.private/network/vlan_mapping.yml` (local only, not in Git)

---

## Network Architecture Overview

This infrastructure uses a **5-VLAN segmentation model** with a central OPNsense firewall providing:
- Strict inter-VLAN isolation
- Default-deny firewall policy
- DDoS protection
- IDS/IPS threat prevention
- Centralized logging

---

## VLAN Segmentation Strategy

| VLAN | Purpose | Subnet Example | Gateway | Isolation Level | Use Case |
|------|---------|-----------------|---------|---|---|
| **VLAN 10** | Management / OOB | `<MGT_SUBNET_EXAMPLE>` | `<MGT_GW_EXAMPLE>` | 🔴 **Complete** | Out-of-band access to all devices |
| **VLAN 20** | Infrastructure | `<INFRA_SUBNET_EXAMPLE>` | `<INFRA_GW_EXAMPLE>` | 🟠 **High** | Trusted compute (Proxmox, storage, switches) |
| **VLAN 30** | User Devices | `<USER_SUBNET_EXAMPLE>` | `<USER_GW_EXAMPLE>` | 🟡 **Medium** | Workstations (NAT'd to internet) |
| **VLAN 40** | Virtual Machines | `<VM_SUBNET_EXAMPLE>` | `<VM_GW_EXAMPLE>` | 🟡 **Medium** | Guest VMs (limited inter-VLAN) |
| **VLAN 50** | IoT / Isolated | `<IOT_SUBNET_EXAMPLE>` | `<IOT_GW_EXAMPLE>` | 🔴 **Complete** | Smart devices (no outbound access) |

---

## Firewall Architecture

### Default-Deny Policy

```
┌──────────────────────────────────────┐
│         OPNsense Firewall            │
│    (Default: DENY all traffic)       │
│                                       │
│  ✅ Only EXPLICIT whitelist rules    │
│  ❌ Everything else: BLOCKED         │
│                                       │
│  Policy: Principle of Least Priv.   │
└──────────────────────────────────────┘
```

### Allowed Inter-VLAN Traffic

```
VLAN 10 (Management)
    ├─→ SSH/HTTPS access (ports 22, 443)
    └─→ **RECEIVES ONLY**: Critical alerts from VLAN 20

VLAN 20 (Infrastructure)
    ├─→ Can manage VLAN 40 (VM console access)
    ├─→ Can reach external internet (NAT)
    └─→ **ISOLATED FROM**: VLAN 30 (Users), VLAN 50 (IoT)

VLAN 30 (Users)
    ├─→ Internet access via NAT
    └─→ **CANNOT REACH**: VLAN 10, 20, 40, 50

VLAN 40 (VMs)
    ├─→ Receives management from VLAN 20
    ├─→ Can reach internet via NAT
    └─→ **CANNOT REACH**: VLAN 10, 30, 50

VLAN 50 (IoT)
    ├─→ Local network access only
    └─→ **COMPLETE ISOLATION**: No outbound, no inter-VLAN
```

---

## Security Controls by Layer

### Layer 1: Firewall Rules (OPNsense)
- Default-deny policy
- 12 explicit whitelist rules
- Rate limiting (SYN, UDP, ICMP)
- Connection state tracking
- DDoS threshold detection

### Layer 2: IDS/IPS (Suricata)
- Active blocking mode (not just alerts)
- Real-time threat signature matching
- Taint tracking for exploit attempts
- Eve-JSON logging for alerting

### Layer 3: Network Segmentation (VLANs)
- 5 isolated segments
- VLAN access control lists
- MAC-based VLAN assignment possible
- 802.1X authentication support (if needed)

### Layer 4: Access Control
- SSH restricted to VLAN 10 only
- Web UI (HTTPS) restricted to VLAN 10 only
- Failed login lockout (after 3 attempts)
- 15-minute account lockdown on failure

### Layer 5: Encryption
- TLS for management (SSH, HTTPS)
- TLS-encrypted syslog (replaces UDP plaintext)
- VPN access for remote management

### Layer 6: DNS Security
- DNSSEC validation enabled
- DNS rebinding protection
- Privacy-focused DNS (Quad9, Cloudflare)
- Rate limiting on DNS queries

### Layer 7: Logging & Monitoring
- Centralized TLS syslog (port 6514)
- Event logging for all security events
- Firewall rule hit counting
- Failed authentication logging

---

## Network Topology Diagram (Generic)

```
Internet
  |
  └─ [OPNsense Firewall] ── DDoS/IPS/IDS
       │
       └─ Core Switch (VLAN Trunking)
            │
        ┌───┼───┬───┬───┬───┐
        │   │   │   │   │   │
      VLAN10 VLAN20 VLAN30 VLAN40 VLAN50
        │   │   │   │   │   │
     (Mgmt) (Infra) (Users) (VMs) (IoT)
        │
      [SSH/HTTPS Access Points]
      (Port 22, 443 - VLAN 10 only)

VLAN 20 (Infrastructure)
    ├─ Proxmox Hypervisor
    ├─ Storage System
    ├─ PoE Switches (management)
    └─ Monitoring System

VLAN 30 (Users)
    ├─ User Workstations
    ├─ Laptops
    └─ NAT'd to internet (outbound only)

VLAN 40 (VMs)
    ├─ Application VMs
    ├─ Service VMs
    └─ Limited inter-VLAN access

VLAN 50 (IoT)
    ├─ Smart Devices
    ├─ Sensors
    └─ NO outbound access
```

---

## Access Control Matrix

| Source | Dest | Ports | Protocol | Rule | Status |
|--------|------|-------|----------|------|--------|
| VLAN 10 | OPNsense Firewall | 443, 22 | TCP | Mgmt Access | ✅ |
| VLAN 10 | Any Other VLAN | All | All | Isolation | ❌ |
| VLAN 20 | VLAN 40 | 22, 3389, 443 | TCP | VM Management | ✅ |
| VLAN 20 | WAN | All | TCP/UDP | Infrastructure to Internet | ✅ |
| VLAN 30 | WAN | 80, 443, 53 | TCP/UDP | User Internet Access | ✅ |
| VLAN 30 | Other VLANs | All | All | Isolation | ❌ |
| VLAN 40 | WAN | All | All | VM Internet Access | ✅ |
| VLAN 40 | VLAN 20 | 22, 3389 | TCP | Return to Hypervisor | ✅ |
| VLAN 50 | Anywhere | All | All | Complete Isolation | ❌ |
| **Inbound (WAN → All)** | **Any** | **All** | **All** | **Default Deny** | **❌** |

---

## Management Access Points

### SSH Access (Port 22)
```
Source: VLAN 10 (Management VLAN) only
Destination: All managed devices
Authentication: SSH key + vault-encrypted password
Rate Limiting: 3 failures → 15-minute lockout
```

### Web UI Access (HTTPS Port 443)
```
Source: VLAN 10 (Management VLAN) only
Destination: Firewall (OPNsense) only
TLS: Self-signed certificate (or CA-signed)
Session Timeout: 30 minutes idle
Concurrent Sessions: Maximum 10
```

### Console Access
```
Method: Serial console (out-of-band)
Device: USB-to-Serial adapter
Speed: 115200 baud
Use Case: Recover from SSH/HTTPS lockout
```

---

## Deployment Phases

### Phase 1: Perimeter Security (Day 1)
- [ ] Configure WAN ingress rules (default deny)
- [ ] Configure DDoS thresholds
- [ ] Enable IDS/IPS active blocking
- [ ] Test: Port scan should be blocked

### Phase 2: VLAN Isolation (Day 2)
- [ ] Configure 5 VLANs in switches
- [ ] Configure VLAN trunking on core switch
- [ ] Configure firewall VLAN interfaces
- [ ] Test: Cross-VLAN traffic should be blocked

### Phase 3: Management Access (Day 3)
- [ ] Restrict SSH to VLAN 10 only
- [ ] Restrict HTTPS to VLAN 10 only
- [ ] Configure failed login lockout
- [ ] Test: SSH from VLAN 30 should be blocked

### Phase 4: Logging & Monitoring (Day 4)
- [ ] Configure TLS syslog
- [ ] Enable centralized logging
- [ ] Configure alerting on security events
- [ ] Test: Verify syslog messages arriving encrypted

### Phase 5: Testing & Validation (Day 5)
- [ ] Full security audit
- [ ] Penetration testing (internal)
- [ ] Rule validation
- [ ] Documentation review

---

## Accessing This Infrastructure

### For Public Documentation
This file and similar public docs show **generic examples** of how the network is organized.

### For Actual Infrastructure Details
See private documentation (local only):
```
.private/network/vlan_mapping.yml    ← Actual VLAN IDs and names
.private/network/ip_schema.md        ← Actual IP subnetting
.private/security/firewall_rules.txt ← Actual firewall rules
.private/inventory/hosts.yml         ← Device IPs and credentials
```

These are **not in Git** and only available locally.

---

## Example: Using Templates

### Step 1: Copy Example to Private
```bash
cp automation/inventory/hosts.example .private/inventory/hosts.yml
```

### Step 2: Fill in Your Infrastructure
```bash
cat > .private/inventory/hosts.yml << 'EOF'
all:
  vars:
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    ansible_user: admin
  
  children:
    opnsense:
      hosts:
        fw_main:
          # Replace placeholder with ACTUAL IP
          ansible_host: 10.0.10.5
EOF
```

### Step 3: Verify It Works
```bash
ansible-inventory -i .private/inventory/hosts.yml --list
```

### Step 4: Run Playbook
```bash
ansible-playbook playbooks/opnsense.yml \
  --inventory .private/inventory/hosts.yml \
  --check  # Dry-run first!
```

---

## Summary

✅ **This public documentation shows:**
- Generic network architecture
- Security principles and layers
- VLAN segmentation strategy
- Firewall policy concepts
- Example access control matrix

❌ **Real infrastructure details (in `.private/`):**
- Actual VLAN IDs and names
- Real IP addresses and subnets
- Device serial numbers
- Firewall rules specific to your setup
- Access credentials and keys

For deployment, always:
1. Start with these templates
2. Populate `.private/` with your actual values
3. Run playbooks against `.private/inventory/hosts.yml`
4. Never commit `.private/` to git
