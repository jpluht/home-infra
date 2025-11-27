# Playbooks and Templates

## Playbooks (5 Total)

The automation framework includes five main playbooks for complete infrastructure management:

1. **core_switches.yml** - Configures core Cisco 3750 TS switches with VLAN definitions and trunk port settings
2. **poe_switches.yml** - Manages PoE access layer switches with port assignments and VLAN tagging
3. **opnsense.yml** - Deploys OPNsense firewall configuration via NETCONF (VLANs, routing, DHCP)
4. **proxmox.yml** - Initializes Proxmox cluster nodes and shared storage infrastructure
5. **gpu_node.yml** - Sets up GPU computation nodes with NVIDIA drivers, CUDA, and iSCSI configuration

## Templates (6 Total)

Jinja2 XML templates generate device-specific configurations:

| Template | Purpose | Target Device |
|----------|---------|----------------|
| **vlans.xml.j2** | VLAN definitions and tagging | OPNsense |
| **dhcp.xml.j2** | DHCP server and subnet configuration | OPNsense |
| **nat.xml.j2** | NAT rule definitions | OPNsense |
| **ntp.xml.j2** | NTP server configuration | OPNsense |
| **dnsbl.xml.j2** | DNS blocklist setup | OPNsense |
| **suricata.xml.j2** | IDS/IPS threat detection configuration | OPNsense |

## Playbook Execution

### Basic Validation
```bash
# Syntax check
ansible-playbook playbooks/core_switches.yml --syntax-check

# Dry-run preview
ansible-playbook playbooks/core_switches.yml --check
```

### Full Deployment
```bash
# Single playbook
ansible-playbook -i inventory/hosts playbooks/core_switches.yml --vault-password-file ../.vault_pass

# All playbooks in sequence
for playbook in core_switches poe_switches opnsense proxmox gpu_node; do
  ansible-playbook -i inventory/hosts playbooks/${playbook}.yml --vault-password-file ../.vault_pass
done
```

## Template Rendering

Templates use Jinja2 with dynamic variables from `group_vars/opnsense.yml`. The rendering process:

1. Ansible loads group variables (including vault-encrypted VLAN names)
2. Jinja2 processes templates with variable substitution
3. Output XML is deployed to target device via NETCONF
4. Device applies configuration changes

Example template snippet:
```jinja2
{% for vlan in vlans %}
<vlan>
    <if>igb{{ loop.index }}</if>
    <tag>{{ vlan.id }}</tag>
    <descr>{{ vlan.name }}</descr>
</vlan>
{% endfor %}
```

See [Ansible Overview](./ansible-overview.md) for more details on playbook structure and variables.
