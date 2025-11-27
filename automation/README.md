# Ansible Automation

This directory contains Ansible playbooks, inventories, group variables, and Jinja2 templates to automate the deployment and configuration of my home lab network infrastructure.

## Contents

- `inventory/` : Host inventories with example and real device IPs (excluded from Git)
- `group_vars/` : Group-specific variables for device configuration
- `playbooks/` : Playbook files for different network segments and devices
- `templates/` : Jinja2 templates for device config files (DHCP, VLANs, Firewall, etc.)
- `ansible.cfg` : Ansible configuration specific to this automation environment
- `venv310/` : Python virtual environment for Ansible (excluded via .gitignore)

## Getting Started

1. Activate Python virtual environment:
source venv310/bin/activate


2. Install Python dependencies:
pip install -r requirements.txt


3. Install Ansible collections:
ansible-galaxy collection install -r requirements.yml


4. Copy inventory example and customize:
cp inventory/hosts.example inventory/hosts



5. Adjust variables in `group_vars/` as per your environment.

6. Run syntax check:
ansible-playbook -i inventory/hosts playbooks/opnsense.yml –syntax-check



7. Perform dry-run check:
ansible-playbook -i inventory/hosts playbooks/opnsense.yml –check


8. Execute automation:
ansible-playbook -i inventory/hosts playbooks/opnsense.yml


---

## Vault and Secrets Management

### Overview
VLAN names and other sensitive network topology information are encrypted using Ansible Vault.

### Encrypted Data
- `group_vars/all/vault.yml` - Contains encrypted VLAN names:
  - `vault_vlan_10_name` - Infrastructure VLAN
  - `vault_vlan_20_name` - Trusted devices VLAN
  - `vault_vlan_30_name` - User devices VLAN
  - `vault_vlan_40_name` - Virtual machines VLAN
  - `vault_vlan_50_name` - IoT isolated VLAN

### Using Vault

**View encrypted content:**
```bash
ansible-vault view group_vars/all/vault.yml --vault-password-file=.vault_pass
```

**Edit encrypted content:**
```bash
ansible-vault edit group_vars/all/vault.yml --vault-password-file=.vault_pass
```

**Running playbooks with vault:**
```bash
ansible-playbook -i inventory/hosts playbooks/core_switches.yml --vault-password-file=.vault_pass
```

### Security Best Practices
- Never commit `.vault_pass` or vault passwords to Git (already in `.gitignore`)
- Never commit unencrypted `vault.yml` to Git (already in `.gitignore`)
- Rotate vault passwords periodically
- Store `.vault_pass` in a secure location (not shared)

---

## License

MIT License (see LICENSE in root)
