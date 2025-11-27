# Home Lab Network Automation

**Modern Ansible-based infrastructure as code for deploying and managing a secure, multi-VLAN home lab network.**

This directory contains Ansible playbooks, inventories, group variables, and Jinja2 templates that automate the complete network infrastructure setup:

- **OPNsense firewall** — VLANs, DHCP, DNS, firewall rules, IDS/IPS
- **Cisco core switches** — VLAN creation, trunk/access port configuration
- **Cisco PoE switches** — Access port and PoE power management
- **Proxmox hypervisors** — Network bridge setup, cluster formation
- **GPU compute node** — CUDA, iSCSI storage, ML model hosting

---

## 📁 Directory Structure

```
automation/
├── README.md                          # This file
├── VAULT_GUIDE.md                     # Vault & secrets management
├── ansible.cfg                        # Ansible runtime configuration
├── requirements.txt                   # Python dependencies
├── requirements.yml                   # Ansible collections
├── venv310/                           # Python 3.10 virtual environment (git-ignored)
│
├── inventory/
│   └── hosts.example                  # Public template for inventory
│
├── group_vars/
│   ├── all/
│   │   └── vault.yml                  # Vault config documentation (not encrypted)
│   ├── opnsense.yml                   # OPNsense-specific variables
│   ├── core_switches.yml              # Core switch variables
│   ├── poe_switches.yml               # PoE switch variables
│   ├── proxmox.yml                    # Proxmox cluster variables
│   └── gpu_node.yml                   # GPU node variables
│
├── playbooks/
│   ├── deploy-network.yml             # Master orchestration playbook ⭐
│   ├── opnsense.yml                   # Configure OPNsense firewall
│   ├── core_switches.yml              # Configure core Cisco switches
│   ├── poe_switches.yml               # Configure PoE switches
│   ├── proxmox.yml                    # Configure Proxmox cluster
│   ├── gpu_node.yml                   # Configure GPU compute node
│   └── preview-network-vars.yml       # Validate vault configuration
│
└── templates/
    ├── vlans.xml.j2                   # OPNsense VLAN template
    ├── dhcp.xml.j2                    # OPNsense DHCP template
    ├── nat.xml.j2                     # OPNsense NAT template
    ├── firewall.xml.j2                # OPNsense firewall rules template
    ├── dns.xml.j2                     # OPNsense DNS template
    ├── ntp.xml.j2                     # OPNsense NTP template
    └── suricata.xml.j2                # OPNsense IDS/IPS template
```

**Private (git-ignored) directories:**

```
.private/
├── vault-config.yml                   # 🔐 Single source of truth for all infrastructure
├── credentials/
│   └── vault_password.txt             # Vault decryption key
├── inventory/
│   └── hosts.yml                      # Actual device IPs and credentials
├── generated/                         # Playbook-generated artifacts
│   ├── deployment_manifest.json
│   ├── network_vars.json
│   └── ...
└── old/                               # Archive of legacy configurations
```

---

## 🚀 Quick Start

### 1. Prerequisites

- Ansible 2.13+ (installed in `venv310/`)
- All network devices configured with SSH access
- `.private/vault-config.yml` populated with your infrastructure
- `.private/inventory/hosts.yml` created from `hosts.example` with real IPs

### 2. Activate Virtual Environment

```bash
cd automation/
source venv310/bin/activate
```

### 3. Create Private Inventory

```bash
# Copy example inventory to private directory
cp inventory/hosts.example ../.private/inventory/hosts.yml

# Edit with your actual device IPs, credentials, connection settings
vim ../.private/inventory/hosts.yml
```

### 4. Validate Configuration

```bash
# Preview what vault-config looks like
ansible-playbook playbooks/preview-network-vars.yml

# Validate YAML syntax of all playbooks
ansible-playbook playbooks/deploy-network.yml --syntax-check
```

### 5. Dry-Run (No Changes)

```bash
# Preview all changes without modifying devices
ansible-playbook playbooks/deploy-network.yml \
  --inventory ../.private/inventory/hosts.yml \
  --check -vv
```

### 6. Deploy (Apply Changes)

```bash
# Full network deployment in order:
# 1. OPNsense → 2. Core Switches → 3. PoE Switches → 4. Proxmox → 5. GPU Node

ansible-playbook playbooks/deploy-network.yml \
  --inventory ../.private/inventory/hosts.yml \
  -v
```

---

## 📋 Playbooks & Usage

### Master Deployment Playbook

**`deploy-network.yml`** — Orchestrates all infrastructure in proper sequence.

```bash
# Full deployment (all devices)
ansible-playbook playbooks/deploy-network.yml --inventory ../.private/inventory/hosts.yml

# Dry-run to preview changes
ansible-playbook playbooks/deploy-network.yml --inventory ../.private/inventory/hosts.yml --check

# Deploy only firewall
ansible-playbook playbooks/deploy-network.yml --inventory ../.private/inventory/hosts.yml --tags firewall

# Deploy switches only
ansible-playbook playbooks/deploy-network.yml --inventory ../.private/inventory/hosts.yml --tags switches
```

### Individual Playbooks

#### OPNsense Firewall

**`opnsense.yml`** — Configure firewall VLANs, DHCP, DNS, firewall rules, IDS/IPS.

```bash
# Full OPNsense config
ansible-playbook playbooks/opnsense.yml \
  --inventory ../.private/inventory/hosts.yml

# Configure only VLANs
ansible-playbook playbooks/opnsense.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags vlans

# Configure only DHCP
ansible-playbook playbooks/opnsense.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags dhcp

# Preview without applying
ansible-playbook playbooks/opnsense.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags summary \
  --check
```

**Available tags:** `vlans`, `dhcp`, `dns`, `firewall`, `ids_ips`, `nat`, `summary`, `export`, `debug`

#### Cisco Switches

**`core_switches.yml`** — Configure core switch VLANs, trunks, access ports, management interface.

```bash
# Full configuration
ansible-playbook playbooks/core_switches.yml \
  --inventory ../.private/inventory/hosts.yml

# Configure only VLANs
ansible-playbook playbooks/core_switches.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags vlans

# Configure only access ports
ansible-playbook playbooks/core_switches.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags ports,access

# Dry-run
ansible-playbook playbooks/core_switches.yml \
  --inventory ../.private/inventory/hosts.yml \
  --check -v
```

**Available tags:** `vlans`, `trunk`, `access`, `ports`, `management`, `summary`, `verify`

#### PoE Switches

**`poe_switches.yml`** — Configure PoE switch access ports, power settings, VLAN assignments.

```bash
# Full configuration
ansible-playbook playbooks/poe_switches.yml \
  --inventory ../.private/inventory/hosts.yml

# Configure only PoE power
ansible-playbook playbooks/poe_switches.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags poe,power
```

**Available tags:** `vlans`, `trunk`, `access`, `poe`, `power`, `summary`, `verify`

#### Proxmox Cluster

**`proxmox.yml`** — Configure Proxmox network bridges, cluster formation, storage.

```bash
# Full configuration
ansible-playbook playbooks/proxmox.yml \
  --inventory ../.private/inventory/hosts.yml

# Configure only network bridges
ansible-playbook playbooks/proxmox.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags networking,bridges
```

**Available tags:** `packages`, `bridges`, `cluster`, `storage`, `ha`, `backup`, `summary`

#### GPU Node

**`gpu_node.yml`** — Configure GPU node system packages, CUDA, iSCSI storage, ML frameworks.

```bash
# Full configuration
ansible-playbook playbooks/gpu_node.yml \
  --inventory ../.private/inventory/hosts.yml

# Install only CUDA drivers
ansible-playbook playbooks/gpu_node.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags gpu,drivers

# Configure only iSCSI storage
ansible-playbook playbooks/gpu_node.yml \
  --inventory ../.private/inventory/hosts.yml \
  --tags iscsi,storage
```

**Available tags:** `packages`, `gpu`, `drivers`, `llm`, `iscsi`, `storage`, `debug`, `summary`

---

## 🔐 Configuration Management

### Vault Configuration (Source of Truth)

**`.private/vault-config.yml`** is the single source of truth for all infrastructure:

```yaml
vlans:
  - id: 10
    name: "Valinor"
    subnet: "192.168.10.0/24"
    gateway: "192.168.10.1"
    dhcp_enabled: false
    access_level: "management"
  
  - id: 20
    name: "Rivendell"
    subnet: "192.168.20.0/24"
    gateway: "192.168.20.1"
    dhcp_enabled: true
    access_level: "infrastructure"
  
  # ... 4 more VLANs ...

devices:
  management:
    - name: "admin-pc"
      vlan: 10
      ip: "192.168.10.100"
  
  infrastructure:
    - name: "proxmox-node-1"
      vlan: 20
      ip: "192.168.20.10"
  
  # ... more devices ...

firewall_rules:
  - name: "allow-valinor-to-all"
    source_vlan: 10
    destination_vlan: "any"
    protocol: "any"
    action: "allow"
  
  - name: "deny-mordor-to-infrastructure"
    source_vlan: 50
    destination_vlan: 20
    protocol: "any"
    action: "deny"
  
  # ... more rules ...

dhcp:
  valinor:
    enabled: false
  rivendell:
    enabled: true
    pool: "192.168.20.100 - 192.168.20.200"
    lease_time: 3600
  
  # ... more VLAN DHCP ...

dns:
  resolvers:
    - "1.1.1.1"
    - "1.0.0.1"
  local_records:
    - name: "fw.lab.local"
      ip: "192.168.10.1"
    - name: "gateway.lab.local"
      ip: "192.168.10.1"
  
  # ... more DNS ...

switch_config:
  core_switch_1:
    trunk_ports:
      - "Gi0/1"
      - "Gi0/2"
    access_ports:
      - interface: "Gi0/3"
        vlan_id: 20
        description: "Proxmox"
  
  # ... more switches ...
```

### How Playbooks Load Configuration

Each playbook loads vault-config dynamically:

```yaml
- name: "Load vault configuration"
  include_vars:
    file: "{{ playbook_dir }}/../.private/vault-config.yml"
    name: vault_config
```

This means:
- ✅ No hardcoded IPs or VLANs in playbooks
- ✅ Single source of truth in `.private/vault-config.yml`
- ✅ Easy to update infrastructure by editing one file
- ✅ Playbooks are generic and reusable

---

## 🔒 Secrets & Credentials

### Types of Secrets

1. **Vault-encrypted ansible vault (`group_vars/all/vault.yml`)** — Contains sensitive network topology (in `.gitignore`)
2. **Device credentials** — Admin passwords, API keys, SSH keys (in `.private/inventory/hosts.yml`)
3. **Vault password** — Used to decrypt vault files (in `.private/credentials/vault_password.txt`)

### Storing Credentials Securely

**Example: In `.private/inventory/hosts.yml`**

```yaml
all:
  children:
    opnsense:
      hosts:
        fw_main:
          ansible_password: "{{ opnsense_admin_password }}"  # Encrypted in vault
          opnsense_api_key: "YOUR_API_KEY"                  # Store in vault
```

**Then encrypt with ansible-vault:**

```bash
ansible-vault encrypt_string 'actual_password' \
  --vault-password-file .private/credentials/vault_password.txt
```

### Running Playbooks with Vault

```bash
# With vault password file
ansible-playbook playbooks/deploy-network.yml \
  --inventory .private/inventory/hosts.yml \
  --vault-password-file .private/credentials/vault_password.txt

# With vault password prompt
ansible-playbook playbooks/deploy-network.yml \
  --inventory .private/inventory/hosts.yml \
  --ask-vault-pass
```

See **`VAULT_GUIDE.md`** for comprehensive secrets management.

---

## 📊 Deployment Workflow

### Typical Deployment Sequence

1. **Validate Configuration**
   ```bash
   ansible-playbook playbooks/preview-network-vars.yml
   ```

2. **Syntax Check**
   ```bash
   ansible-playbook playbooks/deploy-network.yml --syntax-check
   ```

3. **Dry-Run (Preview Changes)**
   ```bash
   ansible-playbook playbooks/deploy-network.yml --check -vv
   ```

4. **Deploy (Apply Changes)**
   ```bash
   ansible-playbook playbooks/deploy-network.yml -v
   ```

5. **Verify**
   - SSH to each device and confirm configuration
   - Check logs: OPNsense WebGUI, switch console, Proxmox GUI
   - Test connectivity between VLANs

### Common Patterns

**Deploy only specific devices:**
```bash
ansible-playbook playbooks/deploy-network.yml \
  --limit core_switches
```

**Deploy only specific tasks:**
```bash
ansible-playbook playbooks/deploy-network.yml \
  --tags vlans
```

**Skip specific tasks:**
```bash
ansible-playbook playbooks/deploy-network.yml \
  --skip-tags debug
```

**Verbose output for troubleshooting:**
```bash
ansible-playbook playbooks/deploy-network.yml -vvv
```

---

## 🛠️ Troubleshooting

### Connection Issues

**Cisco switches not responding:**
```bash
# Test connectivity
ansible all -i .private/inventory/hosts.yml -m ping -u admin

# Check SSH access
ssh -i ~/.ssh/ansible_rsa admin@192.168.10.20

# Try with explicit network OS
ansible core_switches -i .private/inventory/hosts.yml \
  -m ios_command \
  -a "commands='show version'"
```

**OPNsense API connection failed:**
```bash
# Check REST API is enabled in OPNsense WebGUI
# System → Settings → API
# Verify API key and secret in .private/inventory/hosts.yml

# Test API manually
curl -k -X GET \
  https://192.168.10.1/api/core/system/status \
  -H "X-API-Key: YOUR_KEY" \
  -H "X-API-Secret: YOUR_SECRET"
```

### Playbook Failures

**YAML syntax errors:**
```bash
# Validate specific playbook
ansible-playbook playbooks/opnsense.yml --syntax-check -vv
```

**Variable not defined:**
```bash
# Check vault-config is loaded correctly
ansible-playbook playbooks/preview-network-vars.yml -v
```

**Task failed on device:**
```bash
# Re-run with maximum verbosity
ansible-playbook playbooks/deploy-network.yml -vvv

# Check device logs:
# - OPNsense: System → Log Files
# - Cisco: terminal, show log
# - Proxmox: /var/log/syslog
```

---

## 📚 Additional Resources

- **VAULT_GUIDE.md** — Comprehensive Ansible Vault setup and secrets management
- **docs/03-automation/ansible-overview.md** — Ansible architecture and best practices
- **docs/03-automation/playbooks-and-templates.md** — Detailed playbook and template documentation
- **docs/03-automation/vlan-connectivity.md** — 🔥 **VLAN routing, firewall rules, inter-VLAN policies** (ESSENTIAL READ)
- **docs/03-automation/automation-roadmap.md** — Project roadmap and planned improvements
- **docs/03-automation/troubleshooting.md** — Detailed troubleshooting guide

---

## 🔄 Maintenance

### Regular Tasks

1. **Backup configurations** — After any major changes, backup via playbooks
2. **Review logs** — Check OPNsense, switch, and Proxmox logs periodically
3. **Test disaster recovery** — Periodically test restore from backups
4. **Update firmware** — Keep OPNsense and switch firmware current
5. **Review firewall rules** — Audit rules for effectiveness and cleanup

### Extending Playbooks

To add a new device or VLAN:

1. Add entry to `.private/vault-config.yml`
2. Add device to `.private/inventory/hosts.yml`
3. (Optional) Create device-specific group in `group_vars/`
4. Run playbook with `--check` first
5. Deploy with `--diff` to see exact changes

---

## 📝 License

MIT License — See LICENSE in repository root
