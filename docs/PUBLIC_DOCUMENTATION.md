# PUBLIC Documentation - Sanitized for Sharing

**IMPORTANT**: This directory contains examples and generic documentation suitable for sharing externally, in pull requests, or with contractors.

**DO NOT INCLUDE**: Actual IP addresses, VLAN names, device details, firewall rules, or any infrastructure specifics.

## Information Classification

### What Can Be Public ✅
- HOW to use Ansible playbooks (command examples with placeholders)
- WHAT tools are used (Ansible, Cisco IOS, OPNsense, Proxmox, Suricata)
- General architecture patterns (network segmentation, DMZ, IDS, etc.)
- Best practices for infrastructure automation
- Troubleshooting methodologies (not specific to your setup)

### What Must Stay Private 🔒
- Any VLAN numbers or names (use `<VLAN_ID>`, `<MGMT_VLAN>`, etc.)
- Any IP addresses or subnets (use `<internal_subnet>`, `<gateway>`, etc.)
- Device counts or specific models (generalize: "multiple", "redundant")
- Firewall rules or traffic patterns
- Authentication mechanisms or credential formats
- Physical location, rack positions, or device serial numbers

---

## Example: How to Run Playbooks (PUBLIC VERSION)

```bash
# Deploy network configuration
ansible-playbook playbooks/core_switches.yml \
  --inventory inventory/hosts \
  --vault-password-file .vault_pass

# Verify configuration (dry-run)
ansible-playbook playbooks/opnsense.yml \
  --check \
  --vault-password-file .vault_pass

# Troubleshoot connectivity
ansible <DEVICE_GROUP> -m ping
```

---

## Example: Generic Architecture Explanation

Our infrastructure uses **network segmentation** (VLANs) to create security boundaries:

- **Management VLAN**: Out-of-band access for switches, firewall, and infrastructure
- **Infrastructure VLAN**: Trusted services (hypervisor, storage, monitoring)
- **User VLAN**: Regular workstations and user devices
- **Guest VLAN**: Virtual machines or temporary systems
- **IoT VLAN**: Isolated devices with restricted network access

Each VLAN:
- ✅ Has a dedicated subnet
- ✅ Is connected via a trunk link
- ✅ Has firewall rules enforced at layer 3
- ✅ Can be rapidly isolated in case of breach

---

## Example: Generalized Firewall Policy (PUBLIC)

```
DEFAULT POLICY: DENY
- All traffic blocked by default
- Only explicitly allowed traffic flows

ALLOW LIST (Examples):
- Infrastructure VLAN → Virtual Machine VLAN: SSH, RDP (management)
- User VLAN → Internet: HTTP, HTTPS (user access)
- Management VLAN → All: (restricted to authorized staff only)

BLOCK LIST:
- Management VLAN ← Everything: (isolated, no inbound except from console)
- IoT VLAN → Everything: (complete isolation, inbound monitoring only)
- All ← All foreign traffic: (no port scanning, no unexpected sources)
```

---

## For Sharing With Teams

When sharing infrastructure documentation with new operators:

1. **Create a REDACTED version** by replacing:
   - `10.0.10.0/24` → `<MGT_SUBNET>`
   - `Rivendell` → `<MGT_VLAN>`
   - `Cisco 3750 TS` → `<CORE_SWITCH>`
   - `10 devices` → `multiple`

2. **Share only HOW-TO guides**:
   - How to run playbooks
   - How to troubleshoot connections
   - How to interpret logs
   - What to do in an emergency

3. **Keep in vault** (encrypted):
   - Actual IPs, subnets, VLAN names
   - Device credentials or access methods
   - Specific firewall rules
   - Recovery procedures

---

## Creating Sanitized Versions

Use search-and-replace to anonymize documentation:

```bash
# Replace specific values with placeholders
sed -i 's/10\.0\.10\.0\/24/<MGT_SUBNET>/g' docs/architecture.md
sed -i 's/Rivendell/<MGT_VLAN>/g' docs/architecture.md
sed -i 's/Cisco 3750/<SWITCH_MODEL>/g' docs/architecture.md
```

---

## Links to Real Documentation

Real infrastructure documentation is stored in:
- `automation/group_vars/` (encrypted via vault)
- `automation/inventory/` (encrypted or git-ignored)
- Private folders (not in git repository)

---

