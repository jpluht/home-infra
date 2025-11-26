# 📊 Repository Organization Guide

**This document explains the structure and where to find information.**

---

## Public Documentation (This Repository - GitHub Ready)

These files are safe to share publicly and can be committed to GitHub:

### Setup & Getting Started
- **`README.md`** - Main project documentation
- **`QUICK_START_PRIVATE.md`** - 5-minute quick start guide
- **`PRIVATE_SETUP_GUIDE.md`** - Complete setup workflow
- **`IMPLEMENTATION_GUIDE.md`** - Implementation roadmap

### Security & Policies
- **`OPSEC_POLICY.md`** - Operational security policy
- **`DEPLOYMENT_CHECKLIST.md`** - Safe deployment procedures
- **`SANITIZED_DOCUMENTATION_TEMPLATE.md`** - How to anonymize documentation

### Infrastructure Code
- **`automation/playbooks/`** - Ansible playbooks
- **`automation/templates/`** - Jinja2 configuration templates
- **`automation/inventory/hosts.example`** - Example inventory template
- **`docs/`** - Generic architecture documentation

### Tools
- **`anonymize_docs.sh`** - Bulk documentation sanitization script
- **`requirements.txt`** - Python dependencies
- **`requirements.yml`** - Ansible dependencies

---

## Private Documentation (`.private/` Directory - Local Only)

**⚠️ NEVER committed to git**  
**🔒 Git-ignored by `.gitignore`**  
**📍 Location**: `.private/`

Contains YOUR sensitive infrastructure details:

### `.private/inventory/`
Your actual device IPs, hostnames, and credentials:
- `hosts.yml` - Ansible inventory with real device IPs
- `device_inventory.yml` - Device models, serial numbers, locations

### `.private/network/`
Your network topology and configuration:
- `vlan_mapping.yml` - VLAN IDs → actual names
- `ip_schema.md` - Your IP allocation plan
- `network_diagram.txt` - ASCII network diagram with real IPs
- `addressing_plan.yml` - DHCP pools and static ranges

### `.private/credentials/`
Sensitive authentication data:
- `vault_password.txt` - Ansible vault encryption key
- `device_passwords.yml` - Device passwords (encrypted in vault)
- `ssh_keys/` - Private SSH keys
- `api_tokens.txt` - API keys and auth tokens

### `.private/security/`
Security-sensitive configurations:
- `firewall_rules_actual.txt` - Your actual firewall rules
- `incident_response_plan.md` - Your security procedures
- `access_control_matrix.yml` - Who has access to what
- `audit_log.txt` - Change history and audit trail

### `.private/reports/`
Security audit and assessment reports:
- `01-SECURITY_AUDIT_INITIAL.md` - Initial security audit
- `02-SECURITY_IMPROVEMENTS_OPNSENSE.md` - Implementation details
- `03-POST_DEPLOYMENT_VERIFICATION.md` - Testing results
- `04-FINAL_SUMMARY.md` - Executive summary
- `05-IMPROVEMENTS_LOG.md` - Future improvements tracking
- `README.md` - Reports directory guide

---

## File Organization Philosophy

```
📦 Public (GitHub)                    🔒 Private (.private/)
├── Generic documentation            ├── YOUR device IPs
├── Example playbooks                ├── YOUR network topology
├── Security policies                ├── YOUR credentials
├── Setup guides                     ├── YOUR firewall rules
├── Best practices                   ├── YOUR audit reports
└── Shareable code                   └── Your specific configs
```

---

## Workflow: Using This Repository

### 1. Clone Public Repository
```bash
git clone https://github.com/your-username/home-infra.git
cd home-infra

# Only public files are included
ls *.md  # Shows documentation
ls automation/  # Shows example playbooks
```

### 2. Create Your Private Setup
```bash
mkdir -p .private/{inventory,network,credentials,security,reports}

# .private/ is git-ignored, so these files stay local
```

### 3. Populate Your Infrastructure Details
```bash
cp automation/inventory/hosts.example .private/inventory/hosts.yml
nano .private/inventory/hosts.yml  # Add YOUR device IPs

# Create your network topology
nano .private/network/vlan_mapping.yml
```

### 4. Run Ansible Against Your Infrastructure
```bash
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --check  # Dry-run first!
```

---

## What's Public vs Private

### 📖 Public (Can be on GitHub)

✅ **Safe to share:**
- Generic security concepts
- How-to guides and tutorials
- Example playbooks with placeholder values
- Architecture diagrams (anonymized)
- Best practices
- Tool descriptions

❌ **Never public:**
- Real IP addresses
- VLAN names (specific to your network)
- Device hostnames/serial numbers
- Passwords or API keys
- Firewall rules specific to your setup
- Network topology details

### 🔒 Private (Keep Local Only)

```
NEVER PUBLIC:
  - 10.0.10.5 (your firewall IP)
  - VLAN 10 "Rivendell" (your specific naming)
  - admin@proxy123 (your credentials)
  - ssh key in .private/credentials/
  - .private/security/firewall_rules.txt
```

**EXAMPLE: Anonymized vs Real**

```markdown
❌ WRONG (Specific):
VLAN 10: "Rivendell" (Management)
  Subnet: 10.0.10.0/24
  Firewall: 10.0.10.5
  
✅ RIGHT (Generic):
Management VLAN: Private Class C subnet
  Devices: OOB firewall management
  Purpose: Out-of-band access only
```

---

## Before Publishing to GitHub

**Verification Checklist:**

- ✅ No real IP addresses in public files
- ✅ No VLAN-specific names in docs/
- ✅ No device serial numbers or models
- ✅ No passwords or API keys
- ✅ No `.private/` directory committed
- ✅ No `.vault_pass` file committed
- ✅ Run: `git log --all --name-only | grep ".private"` → Returns 0
- ✅ Run: `git grep "10\\.0\\." -- docs/` → Returns 0 (or only in examples)

---

## Directory Structure at a Glance

```
home-infra/
│
├── 📖 PUBLIC FILES (GitHub-ready)
│   ├── README.md                    ✅ Main documentation
│   ├── QUICK_START_PRIVATE.md       ✅ 5-minute setup
│   ├── PRIVATE_SETUP_GUIDE.md       ✅ Complete guide
│   ├── IMPLEMENTATION_GUIDE.md      ✅ Implementation roadmap
│   ├── OPSEC_POLICY.md              ✅ Security policy
│   ├── DEPLOYMENT_CHECKLIST.md      ✅ Deployment guide
│   ├── SANITIZED_DOCUMENTATION_TEMPLATE.md  ✅ Guide
│   ├── anonymize_docs.sh            ✅ Tool
│   ├── REPOSITORY_STRUCTURE.md      ✅ This file
│   │
│   ├── automation/
│   │   ├── playbooks/               ✅ Generic playbooks
│   │   ├── templates/               ✅ Jinja2 templates
│   │   ├── group_vars/              ✅ Example variables
│   │   └── inventory/hosts.example  ✅ Example inventory
│   │
│   └── docs/                        ✅ Generic docs
│       ├── 01-hardware/
│       ├── 02-initial-setup/
│       ├── 03-automation/
│       └── 04-security/
│
├── 🔒 PRIVATE FILES (Git-ignored, local only)
│   └── .private/
│       ├── inventory/               🔒 YOUR device IPs
│       ├── network/                 🔒 YOUR network config
│       ├── credentials/             🔒 YOUR passwords & keys
│       ├── security/                🔒 YOUR security configs
│       └── reports/                 🔒 Audit reports
│           ├── 01-SECURITY_AUDIT_INITIAL.md
│           ├── 02-SECURITY_IMPROVEMENTS_OPNSENSE.md
│           ├── 03-POST_DEPLOYMENT_VERIFICATION.md
│           ├── 04-FINAL_SUMMARY.md
│           ├── 05-IMPROVEMENTS_LOG.md
│           └── README.md
│
└── .gitignore                       ← Contains .private/ entries
```

---

## Quick Reference: Where to Find Things

| Information | Location | Visibility |
|---|---|---|
| **How to set up** | QUICK_START_PRIVATE.md | 📖 Public |
| **Complete workflow** | PRIVATE_SETUP_GUIDE.md | 📖 Public |
| **Security policy** | OPSEC_POLICY.md | 📖 Public |
| **Deployment steps** | DEPLOYMENT_CHECKLIST.md | 📖 Public |
| **YOUR infrastructure** | .private/inventory/ | 🔒 Private |
| **YOUR network topology** | .private/network/ | 🔒 Private |
| **YOUR credentials** | .private/credentials/ | 🔒 Private |
| **Security audit** | .private/reports/01-*.md | 🔒 Private |
| **Test results** | .private/reports/03-*.md | 🔒 Private |

---

## Maintenance

### When Updating Infrastructure
1. Edit `.private/network/vlan_mapping.yml`
2. Update `.private/inventory/hosts.yml`
3. Update `.private/security/firewall_rules_actual.txt`
4. Add entry to `.private/security/audit_log.txt`
5. Document in `.private/reports/` if significant

### When Adding New Playbooks
1. Keep generic (use variables, not hardcoded values)
2. Add to `automation/playbooks/`
3. Create `automation/templates/` entries if needed
4. Update `docs/` with how-to guide

### When Publishing to GitHub
1. Review all public files for sensitive data
2. Ensure `.private/` is in `.gitignore`
3. Run sanitization check script
4. Verify no IPs, hostnames, or passwords
5. Create pull request for review

---

## Security Considerations

### ✅ Safe to Store in Git
- Generic playbooks
- Ansible roles
- Templates with variables
- Documentation
- Configuration examples
- Best practices

### ❌ NEVER Store in Git
- Credentials (passwords, API keys)
- SSH private keys
- Real IP addresses
- VLAN names or IDs
- Device-specific details
- Vault passwords

### 🔒 Encrypt Before Storing
- Device passwords → Use Ansible vault
- API credentials → Use Ansible vault
- SSH keys → Already encrypted at rest
- Vault password → Store separately (outside git)

---

## Example: Public vs Private

### Public: Generic Setup Guide
```markdown
# Network Architecture

Your infrastructure uses VLAN segmentation:
- Management VLAN: Out-of-band access
- Infrastructure VLAN: Trusted devices
- User VLAN: Workstations
- VM VLAN: Guest systems
- IoT VLAN: Isolated devices

See `.private/network/vlan_mapping.yml` for your specific assignments.
```

### Private: Actual Configuration
```yaml
# .private/network/vlan_mapping.yml
vlans:
  10:
    name: "Rivendell"
    subnet: "10.0.10.0/24"
    gateway: "10.0.10.1"
  20:
    name: "Fellowship"
    subnet: "10.0.20.0/24"
    gateway: "10.0.20.1"
```

---

## Tips for Organization

1. **Keep it Simple**: Don't over-organize
2. **Use Numbering**: `.private/reports/01-*`, `02-*`, etc.
3. **Document Changes**: Update audit log
4. **Regular Backups**: Encrypt and store `.private/` separately
5. **Review Quarterly**: Audit for stale information

---

**Version**: 1.0  
**Purpose**: Help users understand repository organization  
**Status**: Complete ✅
