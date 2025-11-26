# Quick Reference Card - Home Infrastructure Automation

## 🚀 Before You Deploy (Checklist)

- [ ] Created `automation/inventory/hosts` with your devices
- [ ] All devices have IP addresses assigned
- [ ] SSH/NETCONF access verified
- [ ] Credentials stored in vault (optional but recommended)
- [ ] Run `ansible-playbook --syntax-check` for validation
- [ ] Run with `--check` flag for dry-run

## 📋 Most Common Commands

### View Vault Contents
```bash
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

### Edit Vault
```bash
ansible-vault edit automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

### Test Connectivity
```bash
cd automation
ansible all -i inventory/hosts -m ping --vault-password-file ../.vault_pass
```

### Validate Playbook Syntax
```bash
ansible-playbook playbooks/core_switches.yml --syntax-check --vault-password-file ../.vault_pass
```

### Dry Run (Preview Changes)
```bash
ansible-playbook playbooks/core_switches.yml --check --vault-password-file ../.vault_pass
```

### Deploy (Apply Changes)
```bash
ansible-playbook playbooks/core_switches.yml --vault-password-file ../.vault_pass
```

### Deploy with Verbose Output
```bash
ansible-playbook playbooks/core_switches.yml -vv --vault-password-file ../.vault_pass
```

## 🔐 Vault Password Management

### Generate Strong Password
```bash
openssl rand -base64 32 | tr -d '\n'
```

### Change Vault Password
```bash
# 1. Generate new password (copy output)
NEW_PASS=$(openssl rand -base64 32 | tr -d '\n')

# 2. Create temp file
echo -n "$NEW_PASS" > /tmp/new_vault_pass

# 3. Rekey vault
ansible-vault rekey automation/group_vars/all/vault.yml \
  --vault-password-file .vault_pass \
  --new-vault-password-file /tmp/new_vault_pass

# 4. Replace password file
mv /tmp/new_vault_pass .vault_pass

# 5. Verify
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

## 📚 File Locations

| File | Purpose |
|------|---------|
| `automation/playbooks/` | All playbooks |
| `automation/group_vars/` | Device configuration |
| `automation/group_vars/all/vault.yml` | Encrypted secrets |
| `automation/inventory/hosts` | Device inventory |
| `automation/templates/` | Jinja2 configuration templates |
| `.vault_pass` | Vault password (git-ignored) |
| `SETUP_STATUS.md` | Setup checklist |
| `automation/VAULT_GUIDE.md` | Vault management |
| `IMPROVEMENTS.md` | Future enhancements |

## 🎯 Playbooks Available

1. **core_switches.yml** - Cisco 3750 core switches
2. **poe_switches.yml** - Cisco 3750 PoE switches
3. **opnsense.yml** - OPNsense firewall/router
4. **proxmox.yml** - Proxmox hypervisor
5. **gpu_node.yml** - GPU nodes with LLM support

## 🐛 Troubleshooting

### Issue: "Decryption failed"
```bash
# Check password file exists and is not empty
cat .vault_pass | wc -c  # Should be > 0
# Verify vault file exists
file automation/group_vars/all/vault.yml
```

### Issue: "Invalid vault password"
```bash
# Check for extra whitespace
cat -A .vault_pass  # Should end with %, not newline
# Recreate if needed
echo -n "your_password" > .vault_pass
```

### Issue: "Module not found"
```bash
# Install collections
cd automation
ansible-galaxy collection install -r ../requirements.yml
```

### Issue: "Device not reachable"
```bash
# Test connectivity
ansible all -i inventory/hosts -m ping
# Check inventory syntax
ansible-inventory -i inventory/hosts --list
```

## 📋 Inventory Format Example

```ini
# Core Switches
[core_switches]
core_sw_1 ansible_host=10.0.1.1 ansible_user=admin
core_sw_2 ansible_host=10.0.1.2 ansible_user=admin

# PoE Switches
[power_switch]
poe_sw_1 ansible_host=10.0.1.3 ansible_user=admin

# Firewall
[opnsense]
fw_1 ansible_host=10.0.1.254 ansible_connection=netconf ansible_user=admin

# Proxmox
[proxmox_nodes]
pve_1 ansible_host=10.0.1.10 ansible_user=root
pve_2 ansible_host=10.0.1.11 ansible_user=root

# GPU Nodes
[gpu_node]
gpu_1 ansible_host=10.0.1.20 ansible_user=admin
gpu_2 ansible_host=10.0.1.21 ansible_user=admin
```

## 🔧 Environment Setup

### First Time Setup
```bash
cd automation

# Install Python dependencies
pip install -r ../requirements.txt

# Install Ansible collections
ansible-galaxy collection install -r ../requirements.yml
```

### Verify Setup
```bash
# Check Ansible version
ansible --version

# Check installed collections
ansible-galaxy collection list

# Check Python packages
pip list | grep -E "ansible|netaddr|jinja2"
```

## 🎨 VLAN Names (Encrypted in Vault)

| VLAN ID | Name | Purpose |
|---------|------|---------|
| 10 | Rivendell | Infrastructure (OOB, switches, APs) |
| 20 | Fellowship | Trusted personal devices |
| 30 | Shire | User devices and entertainment |
| 40 | Mordor | Virtual machines |
| 50 | Mirkwood | IoT and isolated devices |

## ⚡ Quick Deploy Script

Save as `deploy.sh`:

```bash
#!/bin/bash
set -e

PLAYBOOK=${1:-"core_switches"}
VAULT_PASS_FILE=".vault_pass"

if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "❌ Vault password file not found"
    exit 1
fi

cd automation

echo "Running $PLAYBOOK playbook..."
echo "1. Syntax check..."
ansible-playbook "playbooks/${PLAYBOOK}.yml" \
  --syntax-check \
  --vault-password-file ../$VAULT_PASS_FILE

echo ""
echo "2. Dry run (--check)..."
ansible-playbook "playbooks/${PLAYBOOK}.yml" \
  --check \
  --vault-password-file ../$VAULT_PASS_FILE

echo ""
echo "3. Ready to deploy? (Ctrl+C to cancel, Enter to continue)"
read

echo "Deploying..."
ansible-playbook "playbooks/${PLAYBOOK}.yml" \
  --vault-password-file ../$VAULT_PASS_FILE

echo "✅ Deployment complete!"
```

Usage:
```bash
chmod +x deploy.sh
./deploy.sh core_switches
```

## 📞 Support Resources

- **Ansible Documentation:** https://docs.ansible.com/
- **Cisco IOS Collection:** https://github.com/ansible-collections/cisco.ios
- **Vault Guide:** See `automation/VAULT_GUIDE.md`
- **Setup Guide:** See `SETUP_STATUS.md`
- **Improvements:** See `IMPROVEMENTS.md`

## 📝 Important Notes

⚠️ **NEVER:**
- Commit `.vault_pass` to git
- Share vault password via email/chat
- Use simple passwords like "password"
- Store credentials in playbooks

✅ **ALWAYS:**
- Use strong random passwords (32+ chars)
- Back up `.vault_pass` securely
- Test with `--check` before deploying
- Keep documentation updated
- Review playbook diffs before applying

---

**Last Updated:** November 26, 2025  
**Framework Version:** 1.0  
**Status:** Production Ready
