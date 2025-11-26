# 🔐 Private Infrastructure Setup Guide

**Complete guide for separating public (GitHub-ready) and private (local-only) infrastructure data.**

---

## Overview

This project uses a **Public/Private separation model**:

```
📖 PUBLIC (GitHub)              🔒 PRIVATE (Local Only)
├── automation/playbooks/       ├── .private/inventory/
├── automation/templates/       ├── .private/network/
├── docs/                       ├── .private/credentials/
├── OPSEC_POLICY.md            └── .private/security/
└── *.example files
```

**Key Principle**: Playbooks and documentation are published with **placeholder values**. Actual infrastructure details remain local and git-ignored.

---

## Directory Structure

### Public (Committed to GitHub)
```
.
├── README.md                              # Main project documentation
├── QUICK_START_PRIVATE.md                 # Quick 5-minute setup
├── OPSEC_POLICY.md                        # Security policies
├── DEPLOYMENT_CHECKLIST.md                # Safe deployment procedure
│
├── automation/
│   ├── README.md                          # Ansible setup guide
│   ├── playbooks/                         # Generic playbooks
│   ├── templates/                         # Jinja2 templates
│   ├── group_vars/                        # Generic group variables
│   ├── inventory/
│   │   └── hosts.example                  # ← Example inventory template
│   └── ansible.cfg
│
└── docs/
    ├── 01-hardware/
    │   └── NETWORK_TOPOLOGY.example.md    # ← Example network topology
    ├── 02-initial-setup/
    ├── 03-automation/
    └── 04-security/
```

### Private (Git-Ignored, Local Only)
```
.private/                                  # Git-ignored (see .gitignore)
├── README.md                              # 🔒 Setup and usage guide
│
├── inventory/
│   ├── hosts.yml                          # 🔒 Actual device IPs & credentials
│   └── device_inventory.yml               # 🔒 Device models & serial numbers
│
├── network/
│   ├── vlan_mapping.yml                   # 🔒 VLAN IDs → actual names
│   ├── ip_schema.md                       # 🔒 Your IP allocation plan
│   ├── network_diagram.txt                # 🔒 ASCII diagram with real IPs
│   └── addressing_plan.yml                # 🔒 DHCP & static IP ranges
│
├── credentials/
│   ├── vault_password.txt                 # 🔒 Ansible vault key (CRITICAL!)
│   ├── device_passwords.yml               # 🔒 Device passwords (encrypted)
│   ├── ssh_keys/                          # 🔒 Private SSH keys (never commit!)
│   └── api_tokens.txt                     # 🔒 API keys & auth tokens
│
└── security/
    ├── firewall_rules_actual.txt          # 🔒 Real firewall rules deployed
    ├── incident_response_plan.md          # 🔒 Your specific procedures
    ├── access_control_matrix.yml          # 🔒 Who has access to what
    └── audit_log.txt                      # 🔒 Changes log & history
```

---

## Setup Workflow

### Phase 1: Initial Clone (5 min)

#### 1.1 Clone Public Repository
```bash
git clone https://github.com/your-username/home-infra.git
cd home-infra

# Verify .private/ is git-ignored
git status | grep ".private"
# Should show: nothing (already in .gitignore)
```

#### 1.2 Create Private Directories
```bash
mkdir -p .private/{inventory,network,credentials,security}
chmod 700 .private/
chmod 700 .private/*
```

#### 1.3 Verify Setup
```bash
ls -la .private/
# Should show 4 directories with 700 permissions
```

---

### Phase 2: Inventory Setup (10 min)

#### 2.1 Copy Example Inventory
```bash
cp automation/inventory/hosts.example .private/inventory/hosts.yml
```

#### 2.2 Edit with Your Infrastructure

Open `.private/inventory/hosts.yml` and replace ALL `<PLACEHOLDER_*>` values:

**Example transformation:**

Before (placeholder):
```yaml
opnsense:
  hosts:
    fw_main:
      ansible_host: <PLACEHOLDER_OPNSENSE_IP>
      ansible_user: admin
```

After (your infrastructure):
```yaml
opnsense:
  hosts:
    fw_main:
      ansible_host: 10.0.10.5           # Your actual firewall IP
      ansible_user: admin_prod          # Your actual username
      console_port: /dev/ttyUSB0
```

#### 2.3 Add Device-Specific Variables

```yaml
# .private/inventory/hosts.yml (additions)

proxmox:
  hosts:
    hypervisor_01:
      ansible_host: 10.0.20.10
      proxmox_node_name: "pve-node-1"
      proxmox_api_url: "https://10.0.20.10:8006/api2/json"

gpu_node:
  hosts:
    compute_gpu_01:
      ansible_host: 10.0.20.50
      gpu_count: 2
      gpu_type: "A100"
```

#### 2.4 Test Inventory

```bash
# List all hosts
ansible-inventory -i .private/inventory/hosts.yml --list

# Should output JSON with all your devices
```

---

### Phase 3: Credentials Setup (10 min)

#### 3.1 Create Vault Password File

```bash
# Generate secure random password (32+ characters)
openssl rand -base64 32 > .private/credentials/vault_password.txt

# Protect file (owner read-only)
chmod 600 .private/credentials/vault_password.txt

# Verify
cat .private/credentials/vault_password.txt
```

**⚠️ CRITICAL**: Never commit this file!

#### 3.2 Create Encrypted Vault File (Optional but Recommended)

```bash
# Create vault file for device passwords
ansible-vault create \
  --vault-password-file .private/credentials/vault_password.txt \
  .private/credentials/device_passwords.yml
```

This opens an editor. Add your device credentials:

```yaml
---
# .private/credentials/device_passwords.yml

device_passwords:
  opnsense_admin: "SecurePassword123!@#"
  proxmox_root: "AnotherSecurePass!@#"
  switch_admin: "YetAnotherPass!@#"

api_credentials:
  proxmox_api_token: "PVEAPIToken=user@pam!token_name-xxxxx"
  other_api_key: "sk-xxxxxxxxxx"
```

#### 3.3 Store SSH Keys

```bash
# If you have private SSH keys for devices:
mkdir -p .private/credentials/ssh_keys
cp ~/.ssh/id_rsa_infra .private/credentials/ssh_keys/

# Protect
chmod 600 .private/credentials/ssh_keys/*
```

**Update inventory to reference:**
```yaml
all:
  vars:
    ansible_ssh_private_key_file: .private/credentials/ssh_keys/id_rsa_infra
```

---

### Phase 4: Network Configuration (15 min)

#### 4.1 Create VLAN Mapping

```yaml
# .private/network/vlan_mapping.yml

vlans:
  10:
    name: "Rivendell"           # Your VLAN name
    subnet: "10.0.10.0/24"      # Your subnet
    gateway: "10.0.10.1"        # Your gateway IP
    devices:
      - opnsense (10.0.10.5)
      - firewall_mgmt (10.0.10.3)
    purpose: "OOB Management"
  
  20:
    name: "Fellowship"
    subnet: "10.0.20.0/24"
    gateway: "10.0.20.1"
    devices:
      - proxmox (10.0.20.10)
      - storage (10.0.20.20)
    purpose: "Infrastructure"
  
  30:
    name: "Shire"
    subnet: "10.0.30.0/24"
    gateway: "10.0.30.1"
    purpose: "User Devices"
    dhcp_start: "10.0.30.100"
    dhcp_end: "10.0.30.200"
  
  40:
    name: "Mordor"
    subnet: "10.0.40.0/24"
    gateway: "10.0.40.1"
    purpose: "Virtual Machines"
  
  50:
    name: "Valinor"
    subnet: "10.0.50.0/24"
    gateway: "10.0.50.1"
    purpose: "IoT / Isolated"
```

#### 4.2 Document IP Allocation

```markdown
# .private/network/ip_schema.md

## IP Allocation Plan

### VLAN 10: Rivendell (Management)
- Gateway: 10.0.10.1
- OPNsense: 10.0.10.5
- Firewall SSH: 10.0.10.5:22
- Reserved: 10.0.10.1-10.0.10.10
- Static: 10.0.10.11-10.0.10.50
- Available: 10.0.10.51-10.0.10.254

### VLAN 20: Fellowship (Infrastructure)
- Gateway: 10.0.20.1
- Proxmox Hypervisor: 10.0.20.10
- Storage Array: 10.0.20.20
- Reserved: 10.0.20.1-10.0.20.10
- Available: 10.0.20.11-10.0.20.254

[... more VLANs ...]
```

#### 4.3 Create Network Diagram

```
# .private/network/network_diagram.txt

Internet
  ↓ [WAN: 203.0.113.x]
[OPNsense Firewall: 10.0.10.5]
  │ VLAN Trunk
  ├─ VLAN 10 (10.0.10.0/24) - Rivendell [OOB Management]
  │  └─ SSH: 10.0.10.5:22
  │
  ├─ VLAN 20 (10.0.20.0/24) - Fellowship [Infrastructure]
  │  ├─ Proxmox: 10.0.20.10
  │  ├─ Storage: 10.0.20.20
  │  └─ Switch Mgmt: 10.0.20.1
  │
  ├─ VLAN 30 (10.0.30.0/24) - Shire [Users]
  │  ├─ Users: 10.0.30.100-200
  │  └─ NAT to Internet
  │
  ├─ VLAN 40 (10.0.40.0/24) - Mordor [VMs]
  │  ├─ VM1: 10.0.40.10
  │  ├─ VM2: 10.0.40.11
  │  └─ VM3: 10.0.40.12
  │
  └─ VLAN 50 (10.0.50.0/24) - Valinor [IoT]
     ├─ Device1: 10.0.50.10
     ├─ Device2: 10.0.50.11
     └─ [Complete Isolation, No Outbound]

Security Rules:
- VLAN 10 → All: MANAGEMENT ACCESS ONLY (SSH, HTTPS)
- VLAN 20 ↔ VLAN 40: Infrastructure to VMs (ports 22, 3389, 443)
- VLAN 30 → Internet: NAT via OPNsense
- VLAN 50: COMPLETELY ISOLATED (no inbound/outbound)
- All Others: DEFAULT-DENY
```

---

### Phase 5: Security Configuration (10 min)

#### 5.1 Document Actual Firewall Rules

```
# .private/security/firewall_rules_actual.txt

=== OPNSENSE FIREWALL RULES (Your Actual Setup) ===

Rule 1: Default Deny (Fallback)
  Priority: 999
  Action: DENY
  Direction: inbound
  Reason: Default-deny policy - all traffic blocked unless explicitly allowed

Rule 2: Management Access to Firewall
  Source: VLAN 10 (10.0.10.0/24)
  Destination: Firewall (10.0.10.5)
  Port: 22 (SSH), 443 (HTTPS)
  Action: ALLOW
  Log: Yes
  Reason: Allow management from OOB VLAN only

Rule 3: Infrastructure to VMs
  Source: VLAN 20 (10.0.20.0/24)
  Destination: VLAN 40 (10.0.40.0/24)
  Port: 22, 3389, 443
  Action: ALLOW
  Log: Yes
  Reason: Hypervisor management of guest VMs

Rule 4: Users to Internet
  Source: VLAN 30 (10.0.30.0/24)
  Destination: Any (via NAT)
  Port: 80, 443, 53
  Action: ALLOW (NAT)
  Log: Yes
  Reason: User internet access with address translation

[... more rules ...]

Total Rules: 12
Test Date: 2024-01-15
Last Modified: 2024-01-15 by admin_prod
Notes: Deployed via Ansible playbook deployment-20240115
```

#### 5.2 Create Access Control Matrix

```yaml
# .private/security/access_control_matrix.yml

access_matrix:
  firewall:
    ssh_access:
      - vlan: 10
        users: [admin_prod, admin_backup]
        auth: SSH key + password
        mfa: Required
        log: All sessions
    
    web_ui_access:
      - vlan: 10
        users: [admin_prod, admin_view]
        auth: TLS client cert + password
        session_timeout: 30 min
        log: All logins
  
  proxmox:
    api_access:
      - vlan: 20
        users: [proxmox_api, ansible_svc]
        auth: API token
        permissions: VM management
        log: All API calls
    
    console_access:
      - vlan: 20
        users: [admin_prod]
        auth: Password + TOTP
        permissions: Full
        log: All console access
  
  switches:
    ssh_access:
      - vlan: 10
        users: [admin_prod, admin_network]
        auth: SSH key
        commands: Limited to safe read-only
        log: All commands

audit_log:
  - date: 2024-01-15
    action: "Created access matrix"
    by: "admin_prod"
    reason: "Initial documentation"
  
  - date: 2024-01-16
    action: "Added MFA to firewall SSH"
    by: "admin_prod"
    reason: "Security hardening"
```

#### 5.3 Create Audit Log

```
# .private/security/audit_log.txt

=== INFRASTRUCTURE AUDIT LOG ===

2024-01-15 10:00 | User: admin_prod | Action: Initial setup
  - Created .private/ directory structure
  - Set up vault encryption
  - Documented VLAN assignments

2024-01-15 11:30 | User: admin_prod | Action: Firewall deployment
  - Applied OPNsense hardening playbook (--check only)
  - Verified 12 firewall rules active
  - Confirmed TLS syslog enabled

2024-01-15 14:00 | User: admin_prod | Action: Network verification
  - Tested inter-VLAN isolation
  - Confirmed VLAN 50 (IoT) isolated
  - Validated NAT for VLAN 30 (Users)

2024-01-16 09:00 | User: admin_prod | Action: SSH hardening
  - Enabled MFA on firewall SSH
  - Updated SSH key rotation policy
  - Deployed updated access controls

[... more entries ...]
```

---

### Phase 6: Testing & Validation (15 min)

#### 6.1 Verify Inventory

```bash
# List all hosts
ansible-inventory -i .private/inventory/hosts.yml --list | jq '.all.hosts | keys'

# Output should show all your device hostnames
```

#### 6.2 Test Connectivity

```bash
# Ping all devices
ansible all -i .private/inventory/hosts.yml -m ping

# Gather facts
ansible all -i .private/inventory/hosts.yml -m gather_facts -o -t 30
```

#### 6.3 Dry-Run Playbooks

```bash
# Test OPNsense playbook (no changes)
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --vault-password-file .private/credentials/vault_password.txt \
  --check

# Test Proxmox playbook (no changes)
ansible-playbook playbooks/proxmox.yml \
  -i .private/inventory/hosts.yml \
  --check
```

#### 6.4 Verify Git Isolation

```bash
# Check no .private/ files are staged
git status | grep ".private"
# Should return: nothing

# Verify git history doesn't include .private
git log --all --name-only | grep ".private" | wc -l
# Should return: 0

# Verify no IPs in public files
git grep "10\.0\." -- automation/ docs/ | grep -v "example\|placeholder" | wc -l
# Should return: 0
```

---

## Common Operations

### Running a Playbook Against Your Infrastructure

```bash
# OPNsense firewall
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --vault-password-file .private/credentials/vault_password.txt

# Proxmox hypervisor
ansible-playbook playbooks/proxmox.yml \
  -i .private/inventory/hosts.yml

# All switches
ansible-playbook playbooks/core_switches.yml \
  -i .private/inventory/hosts.yml \
  --tags "vlan_config"
```

### Encrypting/Decrypting Vault Files

```bash
# Create new vault file
ansible-vault create \
  --vault-password-file .private/credentials/vault_password.txt \
  .private/credentials/secrets.yml

# Edit vault file
ansible-vault edit \
  --vault-password-file .private/credentials/vault_password.txt \
  .private/credentials/secrets.yml

# View vault file (decrypted)
ansible-vault view \
  --vault-password-file .private/credentials/vault_password.txt \
  .private/credentials/secrets.yml
```

### Updating Your Private Data

```bash
# When infrastructure changes:

# 1. Update inventory
nano .private/inventory/hosts.yml

# 2. Update VLAN mappings
nano .private/network/vlan_mapping.yml

# 3. Update firewall rules if changed
nano .private/security/firewall_rules_actual.txt

# 4. Add audit log entry
echo "$(date +%Y-%m-%d\ %H:%M) | User: $(whoami) | Action: Update VLAN mappings" >> \
  .private/security/audit_log.txt

# 5. Test changes
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --check

# 6. Deploy when ready
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml
```

---

## Security Checklist

Before deploying to production or sharing this repo:

- [ ] `.private/` directory created
- [ ] All 4 subdirectories exist and are empty
- [ ] `.gitignore` includes `.private/` ✅ (already done)
- [ ] `ansible-vault` password file created and protected (mode 600)
- [ ] Actual device IPs in `.private/inventory/hosts.yml` (NOT in git)
- [ ] VLAN mappings in `.private/network/vlan_mapping.yml` (NOT in git)
- [ ] No plaintext passwords in public files
- [ ] SSH keys only in `.private/credentials/ssh_keys/` (NOT in git)
- [ ] Vault files encrypted (if using vault)
- [ ] Git status shows `.private/` as ignored
- [ ] Git log shows NO `.private/` files in history
- [ ] All public files use `<PLACEHOLDER_*>` pattern
- [ ] No real IPs in `docs/` or public playbooks
- [ ] `README.md` points to `.private/README.md` for setup

---

## Final Verification

Run this to confirm everything is set up correctly:

```bash
#!/bin/bash
# quick_verify.sh

echo "🔍 Checking Private Setup..."

# Check directories exist
test -d .private/inventory && echo "✅ .private/inventory/" || echo "❌ Missing .private/inventory/"
test -d .private/network && echo "✅ .private/network/" || echo "❌ Missing .private/network/"
test -d .private/credentials && echo "✅ .private/credentials/" || echo "❌ Missing .private/credentials/"
test -d .private/security && echo "✅ .private/security/" || echo "❌ Missing .private/security/"

# Check .gitignore
grep "\.private" .gitignore && echo "✅ .private/ in .gitignore" || echo "❌ .private/ NOT in .gitignore"

# Check no .private files in git
count=$(git log --all --name-only | grep -c ".private")
[ $count -eq 0 ] && echo "✅ No .private/ in git history" || echo "❌ .private/ files found in history!"

# Check inventory exists
test -f .private/inventory/hosts.yml && echo "✅ Inventory file exists" || echo "❌ Inventory file missing"

# Check vault password
test -f .private/credentials/vault_password.txt && echo "✅ Vault password exists" || echo "❌ Vault password missing"

echo "✅ Setup verification complete!"
```

---

## Summary

✅ **Your infrastructure is now properly compartmentalized**:

| Component | Location | Status |
|-----------|----------|--------|
| Public playbooks | `automation/playbooks/` | ✅ Can be committed to GitHub |
| Public templates | `automation/templates/` | ✅ Can be committed to GitHub |
| Public documentation | `docs/` | ✅ Can be committed to GitHub |
| Example inventory | `automation/inventory/hosts.example` | ✅ Can be committed to GitHub |
| Actual inventory | `.private/inventory/hosts.yml` | 🔒 Git-ignored (local only) |
| Actual VLAN config | `.private/network/vlan_mapping.yml` | 🔒 Git-ignored (local only) |
| Credentials | `.private/credentials/` | 🔒 Git-ignored (local only) |
| Real firewall rules | `.private/security/` | 🔒 Git-ignored (local only) |

✅ You can now publish your project on GitHub with confidence that sensitive infrastructure details remain private!

---

**Remember**: If you wouldn't post it on public WiFi, it belongs in `.private/` 🔐
