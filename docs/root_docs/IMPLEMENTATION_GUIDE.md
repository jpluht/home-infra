# 📖 Implementation & Deployment Guide

**This guide helps you implement the security framework in your own infrastructure.**

For detailed audit reports and security findings, see `.private/reports/` (local only, not in git).

---

## Overview

This project provides a complete framework for:
- 🔐 **Enterprise-grade firewall hardening** (OPNsense)
- 🌐 **Network segmentation** with 5-VLAN isolation
- 🛡️ **Active IDS/IPS threat prevention**
- 📊 **Centralized encrypted logging**
- 🔑 **Access control hardening**
- ⚡ **DDoS protection**

---

## Quick Start (5 minutes)

1. **Clone this repository**
   ```bash
   git clone https://github.com/your-username/home-infra.git
   cd home-infra
   ```

2. **Follow setup guide**
   ```bash
   # Read quick start for 5-minute setup
   cat QUICK_START_PRIVATE.md
   ```

3. **Set up your infrastructure**
   ```bash
   mkdir -p .private/{inventory,network,credentials,security}
   cp automation/inventory/hosts.example .private/inventory/hosts.yml
   nano .private/inventory/hosts.yml  # Add YOUR device IPs
   ```

4. **Test deployment**
   ```bash
   ansible-playbook playbooks/opnsense.yml \
     -i .private/inventory/hosts.yml \
     --check
   ```

---

## What You Get

### 🔒 Security Hardening
- Default-deny firewall policy (12 explicit rules)
- Active IDS/IPS blocking (Suricata)
- TLS-encrypted centralized syslog
- SSH/HTTPS access restricted to management VLAN
- DDoS protection (SYN flood, port scan detection)
- DHCP snooping + ARP spoofing prevention
- DNS privacy (Quad9, Cloudflare)
- Enforced password policies (14-char, 90-day)

### 📚 Documentation
- **OPSEC_POLICY.md** - Security policy framework
- **DEPLOYMENT_CHECKLIST.md** - Safe deployment procedure
- **PRIVATE_SETUP_GUIDE.md** - Detailed setup workflow
- **QUICK_START_PRIVATE.md** - 5-minute quick start
- **SANITIZED_DOCUMENTATION_TEMPLATE.md** - How to sanitize docs

### 🤖 Ansible Playbooks
- Fully automated OPNsense configuration
- Network switch provisioning
- Proxmox hypervisor setup
- GPU compute node configuration
- Reusable Jinja2 templates

### 🔐 Security Framework
- Vault-encrypted credentials
- Example inventory templates
- Best practices documented
- Public/private compartmentalization

---

## Implementation Path

### Phase 1: Planning (1-2 hours)
- [ ] Review OPSEC_POLICY.md
- [ ] Understand security improvements (PRIVATE_SETUP_GUIDE.md)
- [ ] Identify your devices
- [ ] Plan IP addressing

### Phase 2: Setup (2-3 hours)
- [ ] Create .private/ directory structure
- [ ] Populate inventory with YOUR device IPs
- [ ] Create vault password
- [ ] Test SSH connectivity to devices

### Phase 3: Dry-Run (1-2 hours)
- [ ] Run playbooks with `--check` flag
- [ ] Review all proposed changes
- [ ] Verify no unintended modifications
- [ ] Test on non-critical device first

### Phase 4: Deployment (2-4 hours)
- [ ] Back up existing configurations
- [ ] Deploy to production infrastructure
- [ ] Verify all security controls active
- [ ] Monitor logs for issues

### Phase 5: Validation (1-2 hours)
- [ ] Test firewall rules
- [ ] Verify IPS blocking threats
- [ ] Confirm logging working
- [ ] Document results

---

## Key Files

### Public Files (GitHub-ready)
```
README.md                              # Main documentation
QUICK_START_PRIVATE.md                 # 5-minute setup
PRIVATE_SETUP_GUIDE.md                 # Complete workflow
OPSEC_POLICY.md                        # Security policy
DEPLOYMENT_CHECKLIST.md                # Deployment guide
SANITIZED_DOCUMENTATION_TEMPLATE.md    # Doc sanitization
automation/inventory/hosts.example     # Example inventory
docs/01-hardware/NETWORK_TOPOLOGY.example.md  # Example network
```

### Private Files (Local-only, git-ignored)
```
.private/inventory/                    # YOUR device IPs
.private/network/                      # YOUR network topology
.private/credentials/                  # YOUR passwords & keys
.private/security/                     # YOUR security configs
.private/reports/                      # Audit reports
```

---

## Documentation Structure

### For Learning Security Concepts
- Read: `OPSEC_POLICY.md`
- Example: Generic network architecture
- Purpose: Understand security principles

### For Setting Up Your Infrastructure
- Read: `PRIVATE_SETUP_GUIDE.md`
- Action: Create `.private/` directory
- Populate: Your actual device IPs and configs

### For Safe Deployment
- Read: `DEPLOYMENT_CHECKLIST.md`
- Action: Follow step-by-step
- Validate: Run with `--check` first

### For Security Analysis
- See: `.private/reports/` (local only)
- Contains: Audit findings, test results
- Access: Not in git, for your reference

---

## Security Framework

### Layers of Protection

```
Layer 1: Firewall Rules        (Default-Deny Policy)
    ↓
Layer 2: IDS/IPS               (Active Threat Blocking)
    ↓
Layer 3: Network Segmentation  (5-VLAN Isolation)
    ↓
Layer 4: Access Control        (SSH/HTTPS Restricted)
    ↓
Layer 5: Encryption            (TLS Syslog)
    ↓
Layer 6: DDoS Protection       (Rate Limiting)
    ↓
Layer 7: Hardening             (Password Policies)
```

### VLAN Architecture

| VLAN | Purpose | Isolation | Access |
|------|---------|-----------|--------|
| 10 | Management (OOB) | 🔴 COMPLETE | SSH/HTTPS only |
| 20 | Infrastructure | 🟠 HIGH | Proxmox, storage |
| 30 | Users | 🟡 MEDIUM | Internet via NAT |
| 40 | Virtual Machines | 🟡 MEDIUM | From VLAN 20 |
| 50 | IoT/Isolated | 🔴 COMPLETE | No outbound |

---

## Common Use Cases

### Use Case 1: Home Lab Security
**Goal**: Secure personal infrastructure  
**Implementation**: Follow PRIVATE_SETUP_GUIDE.md  
**Time**: 4-6 hours initial setup

### Use Case 2: Learning Ansible
**Goal**: Understand infrastructure automation  
**Implementation**: Study playbooks, modify for your devices  
**Time**: 2-3 hours

### Use Case 3: Security Best Practices
**Goal**: Implement enterprise security in home lab  
**Implementation**: Follow OPSEC_POLICY.md + DEPLOYMENT_CHECKLIST.md  
**Time**: 1-2 weeks

### Use Case 4: Multi-Device Management
**Goal**: Automate network device configuration  
**Implementation**: Use Ansible playbooks against inventory  
**Time**: Ongoing maintenance

---

## Deployment Checklist

- [ ] Review OPSEC_POLICY.md
- [ ] Follow PRIVATE_SETUP_GUIDE.md
- [ ] Create .private/ directory
- [ ] Populate inventory
- [ ] Test SSH connectivity
- [ ] Run playbooks with `--check`
- [ ] Review proposed changes
- [ ] Back up existing configs
- [ ] Deploy changes
- [ ] Verify security controls
- [ ] Monitor logs
- [ ] Document lessons learned

---

## Tips for Success

### ✅ DO
- ✅ Start with `--check` flag (dry-run only)
- ✅ Test on non-critical device first
- ✅ Back up existing configs before deploying
- ✅ Keep `.private/` directory git-ignored
- ✅ Document all changes
- ✅ Monitor firewall logs after deployment
- ✅ Review security findings in `.private/reports/`

### ❌ DON'T
- ❌ Deploy to production without `--check` first
- ❌ Commit `.private/` directory to git
- ❌ Share passwords in unencrypted form
- ❌ Use default credentials
- ❌ Skip network segmentation
- ❌ Disable firewall rules without understanding
- ❌ Ignore security warnings in logs

---

## Getting Help

### Documentation
- **OPSEC_POLICY.md** - Security policy questions
- **PRIVATE_SETUP_GUIDE.md** - Setup and configuration
- **DEPLOYMENT_CHECKLIST.md** - Deployment procedures
- **.private/reports/** - Security audit findings (local)

### Troubleshooting
1. Check ansible output for errors
2. Review firewall logs
3. Verify device connectivity
4. Consult `.private/reports/` for known issues

### Further Learning
- Study VLAN configuration concepts
- Learn Ansible fundamentals
- Review OPNsense documentation
- Practice with non-critical devices

---

## Implementation Examples

### Example 1: Basic Setup
```bash
# 1. Clone repo
git clone <repo> && cd home-infra

# 2. Create private directory
mkdir -p .private/{inventory,network,credentials,security}

# 3. Add your infrastructure
cp automation/inventory/hosts.example .private/inventory/hosts.yml
nano .private/inventory/hosts.yml  # Edit with YOUR IPs

# 4. Create vault password
openssl rand -base64 32 > .private/credentials/vault_password.txt

# 5. Test connectivity
ansible all -i .private/inventory/hosts.yml -m ping

# 6. Deploy (dry-run)
ansible-playbook playbooks/opnsense.yml -i .private/inventory/hosts.yml --check
```

### Example 2: Security Review
```bash
# Review security policy
cat OPSEC_POLICY.md

# Check your deployment against checklist
cat DEPLOYMENT_CHECKLIST.md

# Verify no sensitive data in git
git grep "10\.0\." -- docs/ | wc -l  # Should be 0
```

### Example 3: Accessing Audit Reports
```bash
# Reports are in .private/ (local-only, never committed)
ls -la .private/reports/

# Review specific audit
cat .private/reports/01-SECURITY_AUDIT_INITIAL.md
```

---

## Success Metrics

After successful implementation, you should see:

- ✅ **Security Posture**: 8.5/10 (from 4/10)
- ✅ **Firewall Rules**: 12 explicit rules (default-deny)
- ✅ **IPS Active**: Threats blocked in real-time
- ✅ **Logs Encrypted**: TLS-encrypted syslog
- ✅ **Access Controlled**: SSH/HTTPS restricted to VLAN 10
- ✅ **VLAN Isolated**: 5 VLANs completely isolated
- ✅ **Zero Blobs**: No plaintext passwords in repositories

---

## Next Steps

1. **Immediate** (Today): Read QUICK_START_PRIVATE.md
2. **Short-term** (This week): Create .private/ with your data
3. **Medium-term** (This month): Deploy to test environment
4. **Long-term** (Ongoing): Monitor, update, and maintain

---

**Version**: 1.0  
**Last Updated**: 2024-01-17  
**Status**: Production Ready ✅

For detailed implementation steps, see **PRIVATE_SETUP_GUIDE.md**
