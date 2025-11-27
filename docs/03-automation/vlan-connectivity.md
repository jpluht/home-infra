# VLAN Network Architecture & Connectivity Policy

**Complete documentation of VLAN structure, routing rules, and inter-VLAN communication policies.**

Last updated: November 27, 2025

---

## 📊 VLAN Overview

| VLAN ID | Name | Subnet | Purpose | DHCP | Access Level |
|---------|------|--------|---------|------|--------------|
| **10** | **Valinor** | 192.168.10.0/24 | Management & Infrastructure Control | ❌ Static IPs | 🔴 CRITICAL |
| **20** | **Rivendell** | 192.168.20.0/24 | Personal Devices & Admin Access | ✅ Yes | 🟠 HIGH |
| **30** | **Bree** | 192.168.30.0/24 | Family Devices - Entertainment | ✅ Yes | 🟡 MEDIUM |
| **40** | **Moria** | 192.168.40.0/24 | VMs & Infrastructure Services | ✅ Yes | 🟠 HIGH |
| **41** | **Barad-dur** | 192.168.41.0/24 | Security Cameras & Surveillance | ✅ Yes | 🟠 MEDIUM-HIGH |
| **50** | **Mordor** | 192.168.50.0/24 | Untrusted IoT - Isolated | ✅ Yes | 🔵 LOW |

---

## 🌐 VLAN Roles & Devices

### VLAN 10 — Valinor (Management CRITICAL)

**Purpose:** Network infrastructure control — firewalls, switches, management PCs

**Key Devices:**
- `192.168.10.1` — OPNsense Firewall (Primary)
- `192.168.10.2` — OPNsense Firewall (Secondary/HA)
- `192.168.10.20` — Cisco Core Switch
- `192.168.10.21` — Cisco PoE Switch
- `192.168.10.100` — Admin PC (static)

**Security:**
- ✅ No DHCP (static IPs only)
- ✅ Only management personnel should access
- ✅ All devices critical to network operation

**Connectivity Rules:**
- ✅ **CAN reach:** All other VLANs (full access)
- ✅ **CAN reach:** Internet/WAN (via OPNsense)
- ✅ **CANNOT be reached from:** Any other VLAN except Rivendell
- ✅ **Internet access:** YES (WAN via OPNsense eth0)

---

### VLAN 20 — Rivendell (Personal Devices HIGH)

**Purpose:** Personal computers, admin workstations, trusted personal devices

**Key Devices:**
- Personal laptop (DHCP)
- Personal desktop (DHCP)
- Admin workstation (static)

**Security:**
- ✅ DHCP enabled (pool: 192.168.20.100-250)
- ✅ Lease time: 24 hours
- ✅ Can access most infrastructure services

**Connectivity Rules:**
- ✅ **CAN reach:** Valinor (management)
- ✅ **CAN reach:** Moria (VMs & home automation)
- ✅ **CAN reach:** Barad-dur (cameras — view only)
- ❌ **CANNOT reach:** Mordor (IoT isolation)
- ✅ **Internet access:** YES (via OPNsense NAT)

---

### VLAN 30 — Bree (Family Devices MEDIUM)

**Purpose:** Entertainment devices, family members' computers, guest devices

**Key Devices:**
- Smart TV
- Family laptops (DHCP)
- Tablets
- Guest devices

**Security:**
- ✅ DHCP enabled (pool: 192.168.30.100-250)
- ✅ Lease time: 12 hours (shorter — less stable)
- ⚠️ Limited access to infrastructure

**Connectivity Rules:**
- ✅ **CAN reach:** Moria ONLY on HTTPS port 443 (Jellyfin media server)
- ❌ **CANNOT reach:** Valinor (management)
- ❌ **CANNOT reach:** Rivendell (personal devices)
- ❌ **CANNOT reach:** Barad-dur (cameras — privacy)
- ❌ **CANNOT reach:** Mordor (IoT isolation)
- ✅ **Internet access:** YES (via OPNsense NAT)

---

### VLAN 40 — Moria (VMs & Infrastructure HIGH)

**Purpose:** Proxmox hypervisors, VMs, home automation, storage services

**Key Devices:**
- `192.168.40.20` — Proxmox Node 1 (hypervisor)
- `192.168.40.21` — Proxmox Node 2
- `192.168.40.22` — Proxmox Node 3
- `192.168.40.10` — Home Assistant VM
- `192.168.40.50` — NAS / Shared Storage
- `192.168.40.51` — TrueNAS VM
- `192.168.40.52` — Jellyfin Media Server

**Security:**
- ✅ DHCP enabled (pool: 192.168.40.100-250)
- ✅ Lease time: 1 hour (VMs may be ephemeral)
- ✅ Critical infrastructure VLAN

**Connectivity Rules:**
- ✅ **CAN reach:** Valinor (management via SSH, API)
- ✅ **CAN reach:** Mordor (IoT management)
- ✅ **CAN reach:** Barad-dur (for NVR camera streams)
- ❌ **CANNOT be reached from:** Bree (except port 443 to Jellyfin)
- ❌ **CANNOT be reached from:** Mordor (except from Moria management)
- ✅ **Internet access:** YES (via OPNsense NAT, but generally not needed)

---

### VLAN 41 — Barad-dur (Security Cameras MEDIUM-HIGH)

**Purpose:** IP cameras, NVR storage, surveillance system — relatively isolated

**Key Devices:**
- `192.168.41.10` — Camera Front
- `192.168.41.11` — Camera Back
- `192.168.41.20` — NVR Storage / Video Recording Server

**Security:**
- ✅ DHCP enabled (pool: 192.168.41.100-250)
- ✅ Lease time: 24 hours (stable devices)
- ⚠️ Limited outbound access (DNS only to management, internet for cloud features)

**Connectivity Rules:**
- ✅ **CAN reach:** Valinor DNS (port 53 UDP) — domain resolution only
- ✅ **CAN reach:** Internet/WAN (port 53 DNS, HTTPS for cloud services)
- ✅ **CAN reach FROM:** Rivendell (view camera feeds)
- ✅ **CAN reach FROM:** Moria (NVR recording)
- ❌ **CANNOT reach:** Moria infrastructure directly
- ❌ **CANNOT reach:** Rivendell
- ❌ **CANNOT reach:** Mordor

---

### VLAN 50 — Mordor (Untrusted IoT LOW)

**Purpose:** Untrusted IoT devices, smart plugs, robots, third-party devices — ISOLATED

**Key Devices:**
- Smart vacuum robot
- Smart washing machine
- Generic IoT devices
- Alexa-like devices
- Any third-party cloud-connected device

**Security:**
- ✅ DHCP enabled (pool: 192.168.50.100-250)
- ✅ Lease time: 24 hours
- 🔴 **HIGHLY RESTRICTED** — Cannot access any trusted infrastructure

**Connectivity Rules:**
- ✅ **CAN reach:** Valinor DNS (port 53 UDP) — domain resolution only
- ✅ **CAN reach:** Internet/WAN (HTTPS, NTP, specific ports only)
- ✅ **CAN reach FROM:** Moria (management/control only)
- ❌ **CANNOT reach:** Any other internal VLAN
- ❌ **CANNOT reach:** Valinor (except DNS)
- ❌ **CANNOT reach:** Rivendell
- ❌ **CANNOT reach:** Bree
- ❌ **CANNOT reach:** Barad-dur
- ❌ **CANNOT reach:** Moria (except from Moria control)

---

## 🔥 Firewall Rules (OPNsense)

### Default Policy: **DENY ALL**

**Philosophy:** Zero-trust. All traffic is denied by default. Only explicitly allowed connections pass.

---

### Explicit ALLOW Rules (Priority Order)

#### Rule 1: Valinor → Anywhere (CRITICAL)
```
From: VLAN 10 (Valinor)
To: ANY
Protocol: ANY
Action: ALLOW
Priority: 100
```
**Rationale:** Management VLAN must have full network access for administration.

---

#### Rule 2: Rivendell → Valinor (Management Access)
```
From: VLAN 20 (Rivendell)
To: VLAN 10 (Valinor)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Admin PCs need SSH to firewall, switch, and other management devices.

---

#### Rule 3: Rivendell → Moria (Infrastructure Services)
```
From: VLAN 20 (Rivendell)
To: VLAN 40 (Moria)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Admin access to Proxmox, Home Assistant, storage, etc.

---

#### Rule 4: Rivendell → Barad-dur (Camera Viewing)
```
From: VLAN 20 (Rivendell)
To: VLAN 41 (Barad-dur)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Personal access to view security camera feeds.

---

#### Rule 5: Bree → Moria HTTPS Only (Jellyfin Media)
```
From: VLAN 30 (Bree)
To: VLAN 40 (Moria)
Protocol: TCP
Port: 443 (HTTPS only)
Action: ALLOW
Priority: 300
```
**Rationale:** Family can watch Jellyfin media server, but cannot SSH into VMs or access other services.

---

#### Rule 6: Moria → Valinor (Cluster Management)
```
From: VLAN 40 (Moria)
To: VLAN 10 (Valinor)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** VMs/Proxmox need to reach management network for DNS, syslog, NTP.

---

#### Rule 7: Moria → Mordor (IoT Control)
```
From: VLAN 40 (Moria)
To: VLAN 50 (Mordor)
Protocol: ANY
Action: ALLOW
Priority: 200
```
**Rationale:** Home automation can control IoT devices (vacuum, washing machine, etc.).

---

#### Rule 8: Barad-dur → Valinor DNS Only
```
From: VLAN 41 (Barad-dur)
To: VLAN 10 (Valinor)
Protocol: UDP
Port: 53 (DNS)
Action: ALLOW
Priority: 300
```
**Rationale:** Cameras need to resolve domain names, but cannot directly access infrastructure.

---

#### Rule 9: Barad-dur → Internet (Cloud Services)
```
From: VLAN 41 (Barad-dur)
To: Internet/WAN
Protocol: TCP/UDP
Port: 443, 53, 123 (HTTPS, DNS, NTP)
Action: ALLOW
Priority: 400
NAT: Applied
```
**Rationale:** Cameras may upload to cloud, need internet for time sync and DNS.

---

#### Rule 10: Mordor → Valinor DNS Only
```
From: VLAN 50 (Mordor)
To: VLAN 10 (Valinor)
Protocol: UDP
Port: 53 (DNS)
Action: ALLOW
Priority: 300
```
**Rationale:** IoT devices need DNS resolution but no direct infrastructure access.

---

#### Rule 11: Mordor → Internet (Cloud Services)
```
From: VLAN 50 (Mordor)
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

#### Deny Rule 1: Mordor → Other VLANs
```
From: VLAN 50 (Mordor)
To: VLAN 20, 30, 40, 41
Protocol: ANY
Action: DENY
Priority: 50
```
**Rationale:** IoT MUST NOT access any trusted infrastructure except via Moria.

---

#### Deny Rule 2: Bree → Untrusted VLANs
```
From: VLAN 30 (Bree)
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

**Gateway:** `192.168.10.1` (Valinor VLAN)

**Uplink:** `em0` (WAN interface on OPNsense)

**Routing:**
- Internal → Valinor gateway → OPNsense em0 → ISP gateway → Internet
- Default route: `0.0.0.0/0` → ISP gateway (via em0)

### Which VLANs Can Reach Internet?

| VLAN | Access | Via | Port Restrictions |
|------|--------|-----|-------------------|
| **Valinor** | ✅ Full | Direct NAT | None (management) |
| **Rivendell** | ✅ Full | NAT | None |
| **Bree** | ✅ Full | NAT | None |
| **Moria** | ✅ Full | NAT | None (but rarely needed) |
| **Barad-dur** | ✅ Limited | NAT | DNS (53), HTTPS (443), NTP (123) |
| **Mordor** | ✅ Limited | NAT | DNS (53), HTTPS (443), NTP (123) |

### No Direct Internet Access From:
- ❌ Internal networks (192.168.0.0/16) — all traffic via OPNsense NAT
- ❌ Any device directly routed, must go through OPNsense firewall

---

## 🔗 Inter-VLAN Communication Matrix

```
From\To    Valinor  Rivendell  Bree  Moria  Barad-dur  Mordor   Internet
────────────────────────────────────────────────────────────────────────
Valinor      —         ✅        ✅     ✅      ✅        ✅        ✅
Rivendell   ✅✅        —         ❌     ✅      ✅        ❌        ✅
Bree        ❌         ❌         —    443SSL   ❌        ❌        ✅
Moria       ✅         ❌         ❌     —      ✅        ✅        ✅
Barad-dur  DNS        ✅        ❌     ✅       —        ❌        ✅*
Mordor     DNS        ❌        ❌    ✅       ❌        —         ✅*
────────────────────────────────────────────────────────────────────────
Legend: ✅ = Full access | ❌ = Blocked | 443SSL = HTTPS only | DNS = DNS only | ✅* = Limited ports
```

---

## 📝 Summary: Who Talks to Whom?

### 🟢 Full Inter-VLAN Communication

1. **Valinor ↔ Everyone** (Management controls all)
2. **Rivendell ↔ Valinor** (Admin to management)
3. **Rivendell ↔ Moria** (Admin to VMs)
4. **Rivendell ↔ Barad-dur** (View cameras)
5. **Moria ↔ Barad-dur** (NVR video recording)
6. **Moria ↔ Mordor** (Home automation controls IoT)

### 🟡 Limited Inter-VLAN Communication

1. **Bree → Moria** (HTTPS 443 only — Jellyfin)
2. **Barad-dur → Valinor** (DNS 53 UDP only)
3. **Mordor → Valinor** (DNS 53 UDP only)
4. **Barad-dur → Internet** (DNS, HTTPS, NTP)
5. **Mordor → Internet** (DNS, HTTPS, NTP)

### 🔴 Blocked Inter-VLAN Communication

1. **Mordor ❌ Everything** (except Moria management, Valinor DNS, Internet)
2. **Bree ❌ Rivendell** (family cannot see personal devices)
3. **Bree ❌ Moria** (except HTTPS port 443)
4. **Bree ❌ Barad-dur** (family cannot see cameras — privacy)
5. **Bree ❌ Mordor** (family cannot control IoT)

---

## 🧪 Testing Connectivity

### Test VLAN 20 → VLAN 40

```bash
# From a Rivendell device (192.168.20.x)
ping 192.168.40.20         # Should work (Proxmox node)
ssh admin@192.168.40.20    # Should work (SSH access)
```

### Test VLAN 30 → VLAN 40

```bash
# From a Bree device (192.168.30.x)
ping 192.168.40.52         # Should FAIL (blocked by firewall)
curl https://192.168.40.52 # Should work (Jellyfin HTTPS on port 443)
ssh admin@192.168.40.20    # Should FAIL (blocked by firewall)
```

### Test VLAN 50 → VLAN 20

```bash
# From a Mordor device (192.168.50.x)
ping 192.168.20.10         # Should FAIL (explicitly denied)
nslookup example.com       # Should work (DNS to Valinor)
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
