# SANITIZED DOCUMENTATION TEMPLATE

**Status**: TEMPLATE FOR CREATING PUBLIC DOCUMENTATION  
**Purpose**: Show how to rewrite documentation without exposing infrastructure details

---

## ❌ WRONG (Exposes Infrastructure)

```markdown
## Network Architecture

Our network has 5 VLANs:
- VLAN 10 (Rivendell) - Management on 10.0.10.0/24
- VLAN 20 (Fellowship) - Infrastructure on 10.0.20.0/24
- VLAN 30 (Shire) - Users on 10.0.30.0/24
- VLAN 40 (Mordor) - VMs on 10.0.40.0/24
- VLAN 50 (Mirkwood) - IoT on 10.0.50.0/24

All traffic is filtered by OPNsense firewall at 10.0.10.1
```

**Problems**:
- ❌ All VLAN names revealed (attacker knows your naming scheme)
- ❌ All IP subnets revealed (attacker can scan your network)
- ❌ Exact architecture exposed (attacker knows how many VLANs and which devices)
- ❌ Gateway IP revealed (attacker can fingerprint your firewall)

---

## ✅ RIGHT (Generic, Safe to Share)

```markdown
## Network Architecture

Our infrastructure uses network segmentation (VLAN isolation) for defense in depth:

**Core Principle**: Multiple security domains separated at Layer 3 (routing level)

### Segmentation Strategy

1. **Management Domain**: Out-of-band management access (switches, firewall, serial)
   - Completely isolated from user networks
   - Restricted access (authorized personnel only)
   - Used for: SSH, HTTPS, serial console access

2. **Infrastructure Domain**: Trusted computing resources (hypervisors, storage)
   - Restricted access from management domain
   - Isolated from user and guest systems
   - Used for: VM management, backup, monitoring

3. **User Domain**: Regular workstations and client devices
   - Allowed internet access via firewall
   - No access to management or infrastructure
   - Restricted intra-domain traffic (no lateral movement)

4. **Guest Domain**: Virtual machines and temporary systems
   - Can access infrastructure for management only
   - Cannot reach management domain
   - No access to user devices

5. **Isolated Domain**: Untrusted devices (IoT, cameras, printers)
   - Completely isolated (cannot reach other domains)
   - Can send outbound traffic only for specific protocols
   - All inbound traffic blocked

### Firewall Policy

**Default**: DENY (block everything by default)

**Exceptions** (whitelist only necessary traffic):
- Management → Infrastructure: SSH/RDP (management traffic)
- Infrastructure → Guest: SSH/RDP (VM management)
- User → Internet: HTTP/HTTPS (web browsing)
- Isolated → Monitoring: SNMP/syslog (observability only)

**Blocked by Default**:
- Management ← Other domains (OOB isolation)
- Isolated → Anywhere (complete isolation)
- All ← Internet (no inbound services)
```

**Advantages**:
- ✅ Describes WHAT the architecture does (defense in depth)
- ✅ Shows WHY each segment exists (purpose/threat model)
- ✅ Explains HOW traffic flows (logical view, not specific)
- ✅ Safe to share with contractors, consultants, or public
- ✅ No specific information an attacker could use
- ✅ Still technically accurate

---

## Comparison: Other Elements

### Device Details

❌ **WRONG**:
```
Core Switch: Cisco 3750 TS (48 ports + 2 SFP)
PoE Switch: Cisco 3750 PoE (48 ports + PoE 740W)
Firewall: OPNsense on Intel NUC (8 core, 16GB RAM)
Storage: 10TB iSCSI backend
```

✅ **RIGHT**:
```
Distribution layer: Layer 3 switch with multiple ports
Access layer: PoE-capable switch for endpoints
Firewall: Open-source FreeBSD-based router
Storage: Centralized block storage with iSCSI
```

### IP Addressing

❌ **WRONG**:
```
| VLAN | Subnet | Gateway | Purpose |
|------|--------|---------|---------|
| 10 | 10.0.10.0/24 | 10.0.10.1 | Management |
| 20 | 10.0.20.0/24 | 10.0.20.1 | Infrastructure |
```

✅ **RIGHT**:
```
Each network segment uses RFC1918 private addressing:
- Management segment: Private Class C subnet with /24 netmask
- Infrastructure segment: Separate private Class C subnet
- All gateways configured with +.1 offset
```

### Firewall Rules

❌ **WRONG**:
```
# Inter-VLAN rules
- VLAN 10 → VLAN 20: SSH (22), RDP (3389)
- VLAN 10 → VLAN 30: DENY
- VLAN 30 → WAN: HTTP (80), HTTPS (443)
- VLAN 50 → Any: DENY
```

✅ **RIGHT**:
```
# Inter-VLAN Traffic Policy

| Source | Destination | Traffic | Decision |
|--------|-------------|---------|----------|
| Management | Infrastructure | SSH, RDP | ALLOW |
| Management | User | (none) | DENY |
| User | Internet | HTTP, HTTPS | ALLOW |
| User | Management | (any) | DENY |
| Isolated | Any | (any) | DENY |
```

---

## Quick Checklist: Is This Document Safe to Share?

Ask these questions:

1. **Contains VLAN names?** (Rivendell, Fellowship, etc.)
   - [ ] Yes → DO NOT SHARE (move to vault)
   - [ ] No → Safe to share

2. **Contains IP addresses/subnets?** (10.0.x.x, 192.168.x.x)
   - [ ] Yes → DO NOT SHARE (use generic examples)
   - [ ] No → Safe to share

3. **Contains device details?** (Cisco 3750, Intel i9, 32GB RAM)
   - [ ] Yes → MAYBE (generalize to "Layer 3 switch", "high-end CPU")
   - [ ] No → Safe to share

4. **Contains specific firewall rules?** (port numbers, exact protocols)
   - [ ] Yes → DO NOT SHARE (describe pattern only)
   - [ ] No → Safe to share

5. **Contains credentials/keys/passwords?**
   - [ ] Yes → DO NOT SHARE (these go in vault only)
   - [ ] No → Safe to share

6. **Explains HOW something works?** (troubleshooting, procedures)
   - [ ] Yes → SAFE TO SHARE
   - [ ] No → Check items 1-5

---

## Examples You Can Share

✅ Safe to include in public documentation:
- "How to run a playbook" (generic commands)
- "How to troubleshoot connectivity" (diagnostic methodology)
- "Network segmentation best practices" (general concepts)
- "Firewall policy templates" (generic examples)
- "Ansible playbook structure" (code examples)
- "IDS/IPS tuning guide" (technical concepts)

❌ NOT safe to include:
- Your actual IP scheme
- Your VLAN names or count
- Your device types or serial numbers
- Your firewall rules
- Your credentials or API keys
- Your vault password
- Physical locations or rack assignments
- Any actual configuration values

---

## How to Make Your Documentation Public-Ready

1. **Backup Original**
   ```bash
   cp -r docs/ docs_private/
   ```

2. **Create Public Version**
   ```bash
   cp -r docs/ docs_public/
   ```

3. **Anonymize Public Version**
   ```bash
   # In docs_public/:
   sed -i 's/10\.0\.10\.0\/24/<MGT_SUBNET>/g' *.md
   sed -i 's/Rivendell/<MGT_VLAN>/g' *.md
   sed -i 's/Cisco 3750/<SWITCH_MODEL>/g' *.md
   ```

4. **Manual Review**
   - Read through each file
   - Ensure no real IPs, VLAN names, or device details
   - Check for any other sensitive information

5. **Publish Public Version**
   - Commit `docs_public/` to public repo
   - Keep `docs/` (original) in private repo

---

