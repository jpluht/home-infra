# Automation Documentation

Complete Ansible automation framework for repeatable, secure infrastructure management.

## Overview

This section documents the Ansible playbooks, configurations, and procedures used to automate infrastructure management. All automation is secured with Vault encryption and follows infrastructure-as-code best practices.

## Architecture

### Playbooks (5 Total)
| Playbook | Purpose | Connection Type | Target |
|----------|---------|-----------------|--------|
| **core_switches.yml** | VLAN & trunk configuration | Cisco IOS | Core switches (distribution) |
| **poe_switches.yml** | Access port & VLAN config | Cisco IOS | PoE switches (access layer) |
| **opnsense.yml** | Firewall & routing config | NETCONF | OPNsense firewall |
| **proxmox.yml** | Cluster & storage config | SSH | Proxmox nodes |
| **gpu_node.yml** | GPU/compute stack setup | SSH | GPU computation node |

### Collections Used
- **ansible.netcommon** (5.0.0+) - NETCONF & network automation base
- **community.general** (7.0.0+) - General utilities and system modules
- **cisco.ios** (4.0.0+) - Cisco device management
- **ansible.posix** (1.5.0+) - POSIX system operations
- **ansibleguy.opnsense** (git/main) - OPNsense-specific management

### Security (Vault Encryption)
- **Type**: AES256 encryption
- **Password**: 256-bit random (stored in .vault_pass, git-ignored)
- **Content**: VLAN names and secrets (never in plaintext)
- **Management**: See VAULT_GUIDE.md for procedures

## Jinja2 Templates (6 Total)

| Template | Purpose | Format |
|----------|---------|--------|
| **vlans.xml.j2** | VLAN definitions | XML (OPNsense) |
| **dhcp.xml.j2** | DHCP/DNS server config | XML (OPNsense) |
| **nat.xml.j2** | NAT rule definitions | XML (OPNsense) |
| **ntp.xml.j2** | NTP server configuration | XML (OPNsense) |
| **dnsbl.xml.j2** | DNS blocklist setup | XML (OPNsense) |
| **suricata.xml.j2** | IDS/IPS configuration | XML (OPNsense) |

## Setup Prerequisites

Before running playbooks, ensure:
1. ✅ **Inventory Created**: automation/inventory/hosts exists with device addresses
2. ✅ **Network Access**: Devices are reachable and have SSH/NETCONF enabled
3. ✅ **Credentials**: Device credentials configured in group_vars or vault
4. ✅ **Python Modules**: `pip install -r automation/requirements.txt`
5. ✅ **Ansible Collections**: `ansible-galaxy install -r automation/requirements.yml`

## Quick Start Examples

### Test Connectivity
```bash
cd automation
ansible all -i inventory/hosts -m ping --vault-password-file ../.vault_pass
```

### Validate Playbooks
```bash
# Syntax check
ansible-playbook playbooks/core_switches.yml --syntax-check --vault-password-file ../.vault_pass

# Dry-run preview
ansible-playbook playbooks/core_switches.yml --check --vault-password-file ../.vault_pass
```

### Run Single Playbook
```bash
# Configure core switches with VLANs
ansible-playbook -i inventory/hosts playbooks/core_switches.yml \
  --vault-password-file ../.vault_pass

# Dry-run before applying
ansible-playbook -i inventory/hosts playbooks/core_switches.yml \
  --check --vault-password-file ../.vault_pass
```

### Run All Playbooks
```bash
# Execute all playbooks in sequence
for playbook in core_switches poe_switches opnsense proxmox gpu_node; do
  ansible-playbook -i inventory/hosts playbooks/${playbook}.yml \
    --vault-password-file ../.vault_pass
done
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Vault errors** | Verify .vault_pass exists and is readable, check vault password correctness |
| **Connection timeouts** | Ensure devices are online, SSH/NETCONF ports open, firewall allows Ansible connection |
| **Template rendering errors** | Run with `--check` flag to see rendered templates, verify variable names match group_vars |
| **SSH key errors** | Verify SSH key locations in group_vars, ensure devices have correct public key |
| **NETCONF failures** | OPNsense must support NETCONF; verify connection type is netconf in group_vars |

## Next Steps

1. **Create inventory**: Edit automation/inventory/hosts with your device addresses
2. **Update credentials**: Configure device credentials in group_vars files
3. **Test connectivity**: Run `ansible all -m ping` to verify access
4. **Run playbooks**: Execute with `--check` first, then apply changes
5. **Monitor execution**: Review logs for any configuration issues

## Additional Resources

- [Vault Management Guide](./vault-and-secrets.md)
- [Playbook Details](./playbooks-and-templates.md)
- [Ansible Overview](./ansible-overview.md)
- [Troubleshooting Guide](./troubleshooting.md)
- [Automation Roadmap](./automation-roadmap.md)