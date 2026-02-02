# VLAN Network Architecture & Connectivity Policy

**Complete documentation of VLAN structure, routing rules, and inter-VLAN communication policies.**

Last updated: November 27, 2025

---

## 📊 VLAN Overview

| VLAN ID | Name | Subnet | Purpose | DHCP | Access Level |
|---------|------|--------|---------|------|--------------|
| **10** | **MGMT_VLAN** | 10.0.10.0/24 | Management & Infrastructure Control | ❌ Static IPs | 🔴 CRITICAL |
| **20** | **INFRA_VLAN** | 10.0.20.0/24 | Personal Devices & Admin Access | ✅ Yes | 🟠 HIGH |
| **30** | **USER_VLAN** | 10.0.30.0/24 | Family Devices - Entertainment | ✅ Yes | 🟡 MEDIUM |
| **40** | **VM_VLAN** | 10.0.40.0/24 | VMs & Infrastructure Services | ✅ Yes | 🟠 HIGH |
| **41** | **CAMERA_VLAN** | 10.0.41.0/24 | Security Cameras & Surveillance | ✅ Yes | 🟠 MEDIUM-HIGH |
| **50** | **IOT_VLAN** | 10.0.50.0/24 | Untrusted IoT - Isolated | ✅ Yes | 🔵 LOW |

---

## 🌐 VLAN Roles & Devices

### VLAN 10 — MGMT_VLAN (Management CRITICAL)

**Purpose:** Network infrastructure control — firewalls, switches, management PCs

**Key Devices:**
- `10.0.10.1` — OPNsense Firewall (Primary)
- `10.0.10.2` — OPNsense Firewall (Secondary/HA)
- `10.0.10.20` — Cisco Core Switch
- `10.0.10.21` — Cisco PoE Switch
- `10.0.10.100` — Admin PC (static)

**Security:**
- ✅ No DHCP (static IPs only)
- ✅ Only management personnel should access
- ✅ All devices critical to network operation

**Connectivity Rules:**
- ✅ **CAN reach:** All other VLANs (full access)
- ✅ **CAN reach:** Internet/WAN (via OPNsense)
- ✅ **CANNOT be reached from:** Any other VLAN except INFRA_VLAN
- ✅ **Internet access:** YES (WAN via OPNsense eth0)

---

### VLAN 20 — INFRA_VLAN (Personal Devices HIGH)

**Purpose:** Personal computers, admin workstations, trusted personal devices

**Key Devices:**
- Personal laptop (DHCP)
- Personal desktop (DHCP)
- Admin workstation (static)

**Security:**
- ✅ DHCP enabled (pool: 10.0.20.100-250)
- ✅ Lease time: 24 hours
- ✅ Can access most infrastructure services

**Connectivity Rules:**
- ✅ **CAN reach:** MGMT_VLAN (management)
- ✅ **CAN reach:** VM_VLAN (VMs & home automation)
- ✅ **CAN reach:** CAMERA_VLAN (cameras — view only)
- ❌ **CANNOT reach:** IOT_VLAN (IoT isolation)
- ✅ **Internet access:** YES (via OPNsense NAT)

---

### VLAN 30 — USER_VLAN (Family Devices MEDIUM)

**Purpose:** Entertainment devices, family members' computers, guest devices

**Key Devices:**
- Smart TV
- Family laptops (DHCP)
- Tablets
- Guest devices

**Security:**
- ✅ DHCP enabled (pool: 10.0.30.100-250)
- ✅ Lease time: 12 hours (shorter — less stable)
- ⚠️ Limited access to infrastructure

**Connectivity Rules:**
- ✅ **CAN reach:** VM_VLAN ONLY on HTTPS port 443 (Jellyfin media server)
- ❌ **CANNOT reach:** MGMT_VLAN (management)
- ❌ **CANNOT reach:** INFRA_VLAN (personal devices)
- ❌ **CANNOT reach:** CAMERA_VLAN (cameras — privacy)
- ❌ **CANNOT reach:** IOT_VLAN (IoT isolation)
- ✅ **Internet access:** YES (via OPNsense NAT)

---

### VLAN 40 — VM_VLAN (VMs & Infrastructure HIGH)

**Purpose:** Proxmox hypervisors, VMs, home automation, storage services

**Key Devices:**
- `10.0.40.20` — Proxmox Node 1 (hypervisor)
- `10.0.40.21` — Proxmox Node 2
- `10.0.40.22` — Proxmox Node 3
- `10.0.40.10` — Home Assistant VM
- `10.0.40.50` — NAS / Shared Storage
- `10.0.40.51` — TrueNAS VM
- `10.0.40.52` — Jellyfin Media Server

**Security:**
- ✅ DHCP enabled (pool: 10.0.40.100-250)
- ✅ Lease time: 1 hour (VMs may be ephemeral)
- ✅ Critical infrastructure VLAN

**Connectivity Rules:**
- ✅ **CAN reach:** MGMT_VLAN (management via SSH, API)
- ✅ **CAN reach:** IOT_VLAN (IoT management)
- ✅ **CAN reach:** CAMERA_VLAN (for NVR camera streams)
- ❌ **CANNOT be reached from:** USER_VLAN (except port 443 to Jellyfin)
- ❌ **CANNOT be reached from:** IOT_VLAN (except from VM_VLAN management)
- ✅ **Internet access:** YES (via OPNsense NAT, but generally not needed)

---

### VLAN 41 — CAMERA_VLAN (Security Cameras MEDIUM-HIGH)

**Purpose:** IP cameras, NVR storage, surveillance system — relatively isolated

**Key Devices:**
- `10.0.41.10` — Camera Front
- `10.0.41.11` — Camera Back
- `10.0.41.20` — NVR Storage / Video Recording Server

**Security:**
- ✅ DHCP enabled (pool: 10.0.41.100-250)
- ✅ Lease time: 24 hours (stable devices)
- ⚠️ Limited outbound access (DNS only to management, internet for cloud features)

**Connectivity Rules:**
- ✅ **CAN reach:** MGMT_VLAN DNS (port 53 UDP) — domain resolution only
- ✅ **CAN reach:** Internet/WAN (port 53 DNS, HTTPS for cloud services)
- ✅ **CAN reach FROM:** INFRA_VLAN (view camera feeds)
- ✅ **CAN reach FROM:** VM_VLAN (NVR recording)
- ❌ **CANNOT reach:** VM_VLAN infrastructure directly
- ❌ **CANNOT reach:** INFRA_VLAN
- ❌ **CANNOT reach:** IOT_VLAN

---

### VLAN 50 — IOT_VLAN (Untrusted IoT LOW)

**Purpose:** Untrusted IoT devices, smart plugs, robots, third-party devices — ISOLATED

**Key Devices:**
- Smart vacuum robot
- Smart washing machine
- Generic IoT devices
- Alexa-like devices
- Any third-party cloud-connected device

**Security:**
- ✅ DHCP enabled (pool: 10.0.50.100-250)
- ✅ Lease time: 24 hours
- 🔴 **HIGHLY RESTRICTED** — Cannot access any trusted infrastructure

**Connectivity Rules:**
- ✅ **CAN reach:** MGMT_VLAN DNS (port 53 UDP) — domain resolution only
- ✅ **CAN reach:** Internet/WAN (HTTPS, NTP, specific ports only)
- ✅ **CAN reach FROM:** VM_VLAN (management/control only)
- ❌ **CANNOT reach:** Any other internal VLAN
- ❌ **CANNOT reach:** MGMT_VLAN (except DNS)
- ❌ **CANNOT reach:** INFRA_VLAN
- ❌ **CANNOT reach:** USER_VLAN
- ❌ **CANNOT reach:** CAMERA_VLAN
- ❌ **CANNOT reach:** VM_VLAN (except from VM_VLAN control)

---

## 🔥 Firewall Rules (OPNsense)

### Default Policy: **DENY ALL**

**Philosophy:** Zero-trust. All traffic is denied by default. Only explicitly allowed connections pass.

---

### Explicit ALLOW Rules (Priority Order)

#### Rule 1: MGMT_VLAN → Anywhere (CRITICAL)
```
From: VLAN 10 (MGMT_VLAN)
To: ANY
Protocol: ANY
Action: ALLOW
Priority: 100
```
**Rationale:** Management VLAN must have full network access for administration.

---

#### Rule 2: INFRA_VLAN → MGMT_VLAN (Management Access)
```
From: VLAN 20 (INFRA_VLAN)
To: VLAN 10 (MGMT_VLAN)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Admin PCs need SSH to firewall, switch, and other management devices.

---

#### Rule 3: INFRA_VLAN → VM_VLAN (Infrastructure Services)
```
From: VLAN 20 (INFRA_VLAN)
To: VLAN 40 (VM_VLAN)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Admin access to Proxmox, Home Assistant, storage, etc.

---

#### Rule 4: INFRA_VLAN → CAMERA_VLAN (Camera Viewing)
```
From: VLAN 20 (INFRA_VLAN)
To: VLAN 41 (CAMERA_VLAN)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Personal access to view security camera feeds.

---

#### Rule 5: USER_VLAN → VM_VLAN HTTPS Only (Jellyfin Media)
```
From: VLAN 30 (USER_VLAN)
To: VLAN 40 (VM_VLAN)
Protocol: TCP
Port: 443 (HTTPS only)
Action: ALLOW
Priority: 300
```
**Rationale:** Family can watch Jellyfin media server, but cannot SSH into VMs or access other services.

---

#### Rule 6: VM_VLAN → MGMT_VLAN (Cluster Management)
```
From: VLAN 40 (VM_VLAN)
To: VLAN 10 (MGMT_VLAN)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** VMs/Proxmox need to reach management network for DNS, syslog, NTP.

---

#### Rule 7: VM_VLAN → IOT_VLAN (IoT Control)
```
From: VLAN 40 (VM_VLAN)
To: VLAN 50 (IOT_VLAN)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Home automation can control IoT devices (vacuum, washing machine, etc.).

---

#### Rule 8: CAMERA_VLAN → MGMT_VLAN DNS Only
```
From: VLAN 41 (CAMERA_VLAN)
To: VLAN 10 (MGMT_VLAN)
Protocol: UDP
Port: 53 (DNS)
Action: ALLOW
Priority: 300
```
**Rationale:** Cameras need to resolve domain names, but cannot directly access infrastructure.

---

#### Rule 9: CAMERA_VLAN → Internet (Cloud Services)
```
From: VLAN 41 (CAMERA_VLAN)
To: Internet/WAN
Protocol: TCP/UDP
Port: 443, 53, 123 (HTTPS, DNS, NTP)
Action: ALLOW
Priority: 400
NAT: Applied
```
**Rationale:** Cameras may upload to cloud, need internet for time sync and DNS.

---

#### Rule 10: IOT_VLAN → MGMT_VLAN DNS Only
```
From: VLAN 50 (IOT_VLAN)
To: VLAN 10 (MGMT_VLAN)
Protocol: UDP
Port: 53 (DNS)
Action: ALLOW
Priority: 300
```
**Rationale:** IoT devices need DNS resolution but no direct infrastructure access.

---

#### Rule 11: IOT_VLAN → Internet (Cloud Services)
```
From: VLAN 50 (IOT_VLAN)
To: Internet/WAN
Protocol: TCP/UDP
Port: 443, 53, 123 (HTTPS, DNS, NTP)
Action: ALLOW
Priority: 400
NAT: Applied
```
**Rationale:** IoT devices communicate with their cloud services, get time sync.

---

### Explicit DENY Rules (Lower Priority)

#### Deny Rule 1: IOT_VLAN → Other VLANs
```
From: VLAN 50 (IOT_VLAN)
To: VLAN 20, 30, 40, 41
Protocol: ANY
Action: DENY
Priority: 50
```
**Rationale:** IoT MUST NOT access any trusted infrastructure except via VM_VLAN.

---

#### Deny Rule 2: USER_VLAN → Untrusted VLANs
```
From: VLAN 30 (USER_VLAN)
To: VLAN 20, 40, 50
Protocol: ANY
Action: DENY
Priority: 50
```
**Rationale:** Family devices cannot access personal infrastructure or IoT.

---

### Allow Internet (NAT)

#### Rule: ANY → Internet
```
From: ANY
To: Internet/WAN (via OPNsense eth0)
Protocol: ANY
Action: ALLOW (with NAT)
Priority: 1000
NAT: Apply
```
**Rationale:** All internal VLANs can reach the internet, but with source IP translated to firewall IP.

---

## 🌍 WAN / Internet Connectivity

### Primary Path: OPNsense

**Gateway:** `10.0.10.1` (MGMT_VLAN VLAN)

**Uplink:** `em0` (WAN interface on OPNsense)

**Routing:**
- Internal → MGMT_VLAN gateway → OPNsense em0 → ISP gateway → Internet
- Default route: `0.0.0.0/0` → ISP gateway (via em0)

### Which VLANs Can Reach Internet?

| VLAN | Access | Via | Port Restrictions |
|------|--------|-----|-------------------|
| **MGMT_VLAN** | ✅ Full | Direct NAT | None (management) |
| **INFRA_VLAN** | ✅ Full | NAT | None |
| **USER_VLAN** | ✅ Full | NAT | None |
| **VM_VLAN** | ✅ Full | NAT | None (but rarely needed) |
| **CAMERA_VLAN** | ✅ Limited | NAT | DNS (53), HTTPS (443), NTP (123) |
| **IOT_VLAN** | ✅ Limited | NAT | DNS (53), HTTPS (443), NTP (123) |

### No Direct Internet Access From:
- ❌ Internal networks (10.0.0.0/16) — all traffic via OPNsense NAT
- ❌ Any device directly routed, must go through OPNsense firewall

---

## 🔗 Inter-VLAN Communication Matrix

```
From\To    MGMT_VLAN  INFRA_VLAN  USER_VLAN  VM_VLAN  CAMERA_VLAN  IOT_VLAN   Internet
────────────────────────────────────────────────────────────────────────
MGMT_VLAN      —         ✅        ✅     ✅      ✅        ✅        ✅
INFRA_VLAN   ✅✅        —         ❌     ✅      ✅        ❌        ✅
USER_VLAN        ❌         ❌         —    443SSL   ❌        ❌        ✅
VM_VLAN       ✅         ❌         ❌     —      ✅        ✅        ✅
CAMERA_VLAN  DNS        ✅        ❌     ✅       —        ❌        ✅*
IOT_VLAN     DNS        ❌        ❌    ✅       ❌        —         ✅*
────────────────────────────────────────────────────────────────────────
Legend: ✅ = Full access | ❌ = Blocked | 443SSL = HTTPS only | DNS = DNS only | ✅* = Limited ports
```

---

## 📝 Summary: Who Talks to Whom?

### 🟢 Full Inter-VLAN Communication

1. **MGMT_VLAN ↔ Everyone** (Management controls all)
2. **INFRA_VLAN ↔ MGMT_VLAN** (Admin to management)
3. **INFRA_VLAN ↔ VM_VLAN** (Admin to VMs)
4. **INFRA_VLAN ↔ CAMERA_VLAN** (View cameras)
5. **VM_VLAN ↔ CAMERA_VLAN** (NVR video recording)
6. **VM_VLAN ↔ IOT_VLAN** (Home automation controls IoT)

### 🟡 Limited Inter-VLAN Communication

1. **USER_VLAN → VM_VLAN** (HTTPS 443 only — Jellyfin)
2. **CAMERA_VLAN → MGMT_VLAN** (DNS 53 UDP only)
3. **IOT_VLAN → MGMT_VLAN** (DNS 53 UDP only)
4. **CAMERA_VLAN → Internet** (DNS, HTTPS, NTP)
5. **IOT_VLAN → Internet** (DNS, HTTPS, NTP)

### 🔴 Blocked Inter-VLAN Communication

1. **IOT_VLAN ❌ Everything** (except VM_VLAN management, MGMT_VLAN DNS, Internet)
2. **USER_VLAN ❌ INFRA_VLAN** (family cannot see personal devices)
3. **USER_VLAN ❌ VM_VLAN** (except HTTPS port 443)
4. **USER_VLAN ❌ CAMERA_VLAN** (family cannot see cameras — privacy)
5. **USER_VLAN ❌ IOT_VLAN** (family cannot control IoT)

---

## 🧪 Testing Connectivity

### Test VLAN 20 → VLAN 40

```bash
# From a INFRA_VLAN device (10.0.20.x)
ping 10.0.40.20         # Should work (Proxmox node)
ssh admin@10.0.40.20    # Should work (SSH access)
```

### Test VLAN 30 → VLAN 40

```bash
# From a USER_VLAN device (10.0.30.x)
ping 10.0.40.52         # Should FAIL (blocked by firewall)
curl https://10.0.40.52 # Should work (Jellyfin HTTPS on port 443)
ssh admin@10.0.40.20    # Should FAIL (blocked by firewall)
```

### Test VLAN 50 → VLAN 20

```bash
# From a IOT_VLAN device (10.0.50.x)
ping 10.0.20.10         # Should FAIL (explicitly denied)
nslookup example.com       # Should work (DNS to MGMT_VLAN)
```

### Test Internet Access

```bash
# From any VLAN (use NAT to reach ISP)
ping 8.8.8.8               # Should work (all VLANs)
curl https://example.com   # Should work (all VLANs)
nslookup example.com       # Should work (all VLANs)
```

---

## 📋 Configuration Implementation

All firewall rules are defined in:

**`.private/vault-config.yml` → `firewall_rules` section**

These are then applied by:

1. **`automation/playbooks/opnsense.yml`** — Renders XML templates and deploys via REST API
2. **Templates in `automation/templates/`:**
   - `firewall.xml.j2` — Firewall rule definitions
   - `nat.xml.j2` — NAT rules
   - `vlans.xml.j2` — VLAN definitions

---

## 🔄 Updates & Changes

When modifying firewall rules:

1. Edit `.private/vault-config.yml` (`firewall_rules` section)
2. Run playbook in `--check` mode first: `ansible-playbook automation/playbooks/opnsense.yml --tags firewall --check`
3. Review generated rules
4. Apply with: `ansible-playbook automation/playbooks/opnsense.yml --tags firewall`

---

**Document version:** 1.0 | Last updated: November 27, 2025
