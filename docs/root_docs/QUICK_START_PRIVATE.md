# 🚀 Quick Start: Setting Up Your Private Infrastructure

This guide walks you through setting up your **private infrastructure files** so you can run the Ansible playbooks against your actual equipment.

---

## 5-Minute Setup

### 1. Create Private Directories
```bash
mkdir -p .private/{inventory,network,credentials,security}
```

### 2. Create Private Inventory
```bash
# Copy the example
cp automation/inventory/hosts.example .private/inventory/hosts.yml

# Edit with your actual IPs
nano .private/inventory/hosts.yml
```

Replace these in your file:
```yaml
# EXAMPLE (what to replace):
ansible_host: <PLACEHOLDER_OPNSENSE_IP>

# YOUR ACTUAL (replace with):
ansible_host: 10.0.10.5  # Your firewall's IP
```

### 3. Create Vault Password File
```bash
# Generate a secure random password
openssl rand -base64 32 > .private/credentials/vault_password.txt

# Protect it
chmod 600 .private/credentials/vault_password.txt
```

### 4. Test Connectivity
```bash
# List your inventory
ansible-inventory -i .private/inventory/hosts.yml --list

# Ping all hosts (requires SSH key)
ansible all -i .private/inventory/hosts.yml -m ping
```

### 5. Run Your First Playbook (Dry-Run)
```bash
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --vault-password-file .private/credentials/vault_password.txt \
  --check  # Important: dry-run only
```

✅ **Done!** You're now ready to deploy.

---

## What Goes in `.private/`?

### `.private/inventory/hosts.yml`
Your Ansible inventory with **actual device IPs**:
```yaml
all:
  children:
    opnsense:
      hosts:
        fw_main:
          ansible_host: 10.0.10.5        # ← Your actual IP
          console_port: /dev/ttyUSB0
```

### `.private/credentials/vault_password.txt`
Password for encrypting Ansible vault secrets:
```
bGzC9d7x2Kq...  # 32+ random characters
```

### `.private/network/vlan_mapping.yml`
Your actual VLAN configuration:
```yaml
vlans:
  10:
    name: "Rivendell"
    subnet: "10.0.10.0/24"
    gateway: "10.0.10.1"
```

### `.private/security/firewall_rules.txt`
Actual firewall rules deployed:
```
Rule 1: Management Isolation
  Source: VLAN 10
  Destination: VLAN 20-50
  Action: DENY
```

---

## Common Tasks

### ✅ Test SSH Connection
```bash
# Test one device
ansible fw_main -i .private/inventory/hosts.yml -m ping

# Test all devices
ansible all -i .private/inventory/hosts.yml -m gather_facts
```

### ✅ Run a Specific Playbook
```bash
# OPNsense firewall
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  --vault-password-file .private/credentials/vault_password.txt

# Proxmox hypervisor
ansible-playbook playbooks/proxmox.yml \
  -i .private/inventory/hosts.yml
```

### ✅ Encrypt Sensitive Data
```bash
# Create a vault file for passwords
ansible-vault create --vault-password-file \
  .private/credentials/vault_password.txt \
  .private/credentials/device_passwords.yml

# Edit existing vault file
ansible-vault edit --vault-password-file \
  .private/credentials/vault_password.txt \
  .private/credentials/device_passwords.yml
```

### ✅ Verify Nothing Leaks to Git
```bash
# Check for .private/ files
git status | grep ".private"
# Should return: nothing (or gitignore message)

# Check git history
git log --all --name-only | grep ".private"
# Should return: 0

# Check for IPs in public files
git grep "10\.0\." -- docs/ automation/playbooks/
# Should return: 0 (unless in examples)
```

---

## Troubleshooting

### ❌ "SSH connection refused"
```bash
# Check SSH key
ls -la ~/.ssh/id_rsa

# Test SSH manually
ssh -i ~/.ssh/id_rsa admin@10.0.10.5

# Add verbose output to Ansible
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  -vvv  # Very verbose
```

### ❌ "Vault password incorrect"
```bash
# Make sure file exists
cat .private/credentials/vault_password.txt

# Try without vault (if not needed)
ansible-playbook playbooks/opnsense.yml \
  -i .private/inventory/hosts.yml \
  # (no vault password)
```

### ❌ "Inventory host not found"
```bash
# List all hosts in inventory
ansible-inventory -i .private/inventory/hosts.yml --list

# Check for typos in playbook
grep "hosts:" playbooks/opnsense.yml

# Match playbook host groups to inventory
# Playbook expects: opnsense, proxmox, etc.
# Your inventory must have those groups
```

### ❌ "Accidentally committed .private/!"
```bash
# Remove from git (immediately!)
git rm -r --cached .private/

# Update .gitignore
echo ".private/" >> .gitignore

# Commit the fix
git add .gitignore
git commit -m "Remove .private from tracking"

# ⚠️ WARNING: Anything committed is now in Git history!
# You MUST rotate all passwords and credentials!
```

---

## Best Practices

### 🛡️ Protect Your Private Files
```bash
# Make .private/ harder to accidentally copy
chmod 700 .private/
chmod 600 .private/**/*

# Encrypt vault password (optional but recommended)
gpg --symmetric .private/credentials/vault_password.txt
# Access becomes: ansible-playbook ... --vault-password-file \
#                   <(gpg -d .private/credentials/vault_password.txt.gpg)

# Backup (encrypted, not in Git repo!)
tar czf .private_backup.tar.gz .private/
gpg --symmetric .private_backup.tar.gz
# Store on external drive or encrypted cloud storage
```

### 📋 Version Control for .private/
```bash
# Create LOCAL-ONLY git tracking (not pushed)
# .private/.gitkeep ensures directory exists in repos

# Or use separate local backup:
cd .private
git init  # Local git tracking for .private only
git add .
git commit -m "Initial private state"

# This way you can see changes locally but never push
```

### 🔐 When Sharing with Colleagues

**DON'T:** Send `.private/` directory in email or Slack!

**DO:**
1. Give them a copy of this PUBLIC repository
2. They create their OWN `.private/` directory
3. You send infrastructure details via **secure channel**:
   - 1Password (team vault)
   - LastPass (shared vault)
   - Encrypted email with GPG
   - In-person discussion
4. They populate their `.private/` locally
5. They NEVER commit `.private/` to git

---

## Next Steps

### After Initial Setup
1. ✅ Verify all devices are reachable (`ansible all -m ping`)
2. ✅ Run playbooks with `--check` (dry-run)
3. ✅ Review all tasks: `ansible-playbook playbooks/... --list-tasks`
4. ✅ Deploy to non-critical devices first (test playbooks)
5. ✅ Then deploy to production infrastructure

### Keep It Secure
1. ✅ Always git-ignore `.private/` (already set up)
2. ✅ Backup `.private/` separately (encrypted)
3. ✅ Rotate vault password periodically
4. ✅ Audit who has access to `.private/`
5. ✅ Use strong SSH keys (4096-bit RSA or better)

### Expand Your Setup
1. ✅ Document changes in `.private/security/audit_log.txt`
2. ✅ Keep `.private/network/vlan_mapping.yml` updated
3. ✅ Create playbook-specific variable files as needed
4. ✅ Consider using Ansible roles for complexity

---

## Summary

| Task | Location | Example |
|------|----------|---------|
| **Inventory** | `.private/inventory/hosts.yml` | Device IPs, SSH keys |
| **Vault Password** | `.private/credentials/vault_password.txt` | Random 32-char string |
| **VLAN Config** | `.private/network/vlan_mapping.yml` | VLAN ID → Name mapping |
| **Firewall Rules** | `.private/security/firewall_rules.txt` | Actual rules deployed |
| **Public Playbooks** | `automation/playbooks/*.yml` | Works with `.private/inventory` |

**Remember**: If you wouldn't post it on public WiFi, it belongs in `.private/` 🔐

---

## Getting Help

- See [`.private/README.md`](.private/README.md) for full documentation
- See [OPSEC_POLICY.md](OPSEC_POLICY.md) for security policies
- See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for deployment steps
- See [automation/README.md](automation/README.md) for Ansible specifics
