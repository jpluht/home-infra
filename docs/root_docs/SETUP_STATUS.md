# Home Infrastructure Automation - Setup Status

**Last Updated:** November 26, 2025  
**Status:** ✅ Mostly Complete - Ready for Testing and Deployment

---

## 📊 Current State Overview

### ✅ Completed Components

| Component | Status | Details |
|-----------|--------|---------|
| **Ansible Configuration** | ✅ | ansible.cfg configured with correct inventory path |
| **Python Dependencies** | ✅ | requirements.txt with Ansible 2.15+, Jinja2, httpx |
| **Ansible Collections** | ✅ | All required collections defined in requirements.yml |
| **Playbooks** | ✅ | 5 playbooks created (OPNsense, Core Switches, PoE Switches, Proxmox, GPU Node) |
| **Group Variables** | ✅ | Configured for all device groups with vault integration |
| **Jinja2 Templates** | ✅ | 6 templates for device configurations (DHCP, VLAN, NAT, NTP, DNSBL, Suricata) |
| **Vault Security** | ✅ | Encrypted with strong password (256-bit random) |
| **Documentation** | ⚠️ | Partial - README updated but needs expansion |
| **Inventory** | ❌ | Empty - requires device IP and connection details |

---

## 📁 Directory Structure

```
home-infra/
├── automation/
│   ├── README.md                    # Updated with vault instructions
│   ├── ansible.cfg                  # ✅ Correctly configured
│   ├── requirements.txt             # ✅ Python dependencies
│   ├── requirements.yml             # ✅ Ansible collections
│   ├── group_vars/
│   │   ├── all/
│   │   │   └── vault.yml            # ✅ Encrypted VLAN names (LoTR themed)
│   │   ├── core_switches.yml        # ✅ Cisco 3750 core switches
│   │   ├── poe_switches.yml         # ✅ Cisco 3750 PoE switches
│   │   ├── opnsense.yml             # ✅ Firewall/router configuration
│   │   ├── proxmox.yml              # ✅ Cluster configuration
│   │   └── gpu_node.yml             # ✅ GPU node configuration
│   ├── playbooks/
│   │   ├── core_switches.yml        # ✅ VLAN & port configuration
│   │   ├── poe_switches.yml         # ✅ VLAN & port configuration
│   │   ├── opnsense.yml             # ✅ NETCONF-based firewall config
│   │   ├── proxmox.yml              # ✅ Cluster initialization
│   │   ├── gpu_node.yml             # ✅ LLM & iSCSI setup
│   │   └── hosts                    # ❌ Example inventory (needs customization)
│   ├── templates/
│   │   ├── vlans.xml.j2             # ✅ VLAN configuration template
│   │   ├── dhcp.xml.j2              # ✅ DHCP server template
│   │   ├── nat.xml.j2               # ✅ NAT rules template
│   │   ├── ntp.xml.j2               # ✅ NTP configuration template
│   │   ├── dnsbl.xml.j2             # ✅ DNSBL configuration template
│   │   └── suricata.xml.j2          # ✅ IDS/IPS configuration template
│   └── inventory/                   # ❌ Empty - needs host definitions
├── docs/
│   ├── 01-hardware/                 # Hardware documentation
│   ├── 02-initial-setup/            # Initial setup guides
│   ├── 03-automation/               # Automation documentation
│   └── 04-security/                 # Security documentation
├── .vault_pass                      # ✅ Vault password (excluded from git)
├── requirements.txt                 # ✅ Root-level Python deps
├── requirements.yml                 # ✅ Root-level collection deps
└── README.md                        # Main documentation

```

---

## 🔐 Vault Security

### Encrypted Content
Located: `automation/group_vars/all/vault.yml`

```yaml
vault_vlan_10_name: Rivendell      # Infrastructure (OOB, switches, APs, servers)
vault_vlan_20_name: Fellowship     # Trusted personal devices
vault_vlan_30_name: Shire          # User devices and entertainment
vault_vlan_40_name: Mordor         # Virtual machines
vault_vlan_50_name: Mirkwood       # IoT and isolated devices
```

### Password Security
- **Type:** 256-bit Base64-encoded random password
- **Storage:** `.vault_pass` (git-ignored)
- **Algorithm:** AES256

### Usage
```bash
# View encrypted content
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Edit encrypted content
ansible-vault edit automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Run playbooks with vault
cd automation
ansible-playbook playbooks/core_switches.yml --vault-password-file ../.vault_pass
```

---

## 🎯 Playbook Overview

### 1. **Core Switches** (`playbooks/core_switches.yml`)
- **Hosts:** core_switches
- **Purpose:** Configure Cisco 3750 TS switches
- **Tasks:**
  - Create VLANs (10, 20, 30, 40, 50)
  - Configure trunk ports
  - Configure infrastructure access ports
- **Connection:** network_cli

### 2. **PoE Switches** (`playbooks/poe_switches.yml`)
- **Hosts:** power_switch
- **Purpose:** Configure Cisco 3750 PoE switches
- **Tasks:**
  - Create VLANs
  - Configure trunk ports
  - Configure access ports for APs and devices
- **Connection:** network_cli

### 3. **OPNsense** (`playbooks/opnsense.yml`)
- **Hosts:** opnsense
- **Purpose:** Configure firewall and router
- **Tasks:**
  - VLAN configuration (NETCONF)
  - DHCP server setup
  - Firewall rules
  - NAT rules
  - NTP configuration
  - DNSBL configuration
  - Suricata IDS/IPS
- **Connection:** netconf

### 4. **Proxmox** (`playbooks/proxmox.yml`)
- **Hosts:** proxmox_nodes
- **Purpose:** Configure hypervisor cluster
- **Tasks:**
  - Package management
  - Network bridge configuration
  - Cluster initialization
  - Storage configuration
  - Backup scheduling
- **Connection:** ssh

### 5. **GPU Node** (`playbooks/gpu_node.yml`)
- **Hosts:** gpu_node
- **Purpose:** Configure GPU nodes for LLM models
- **Tasks:**
  - Install essential packages
  - NVIDIA driver and CUDA setup
  - Python ML libraries installation
  - iSCSI configuration
  - LLM model directory setup
  - Inference script deployment
- **Connection:** ssh

---

## ⚠️ Things to Do Before Production

### 1. **CRITICAL - Setup Inventory** 
   - [ ] Create `automation/inventory/hosts` with actual device IPs
   - [ ] Define host groups: `[core_switches]`, `[power_switch]`, `[opnsense]`, etc.
   - [ ] Set connection parameters (IP, port, credentials)
   - [ ] Example format:
     ```ini
     [core_switches]
     core_sw_1 ansible_host=10.0.x.x ansible_user=admin

     [power_switch]
     poe_sw_1 ansible_host=10.0.x.x ansible_user=admin

     [opnsense]
     firewall ansible_host=10.0.x.x ansible_user=admin

     [proxmox_nodes]
     pve_node_1 ansible_host=10.0.x.x ansible_user=root

     [gpu_node]
     gpu_1 ansible_host=10.0.x.x ansible_user=admin
     ```

### 2. **Network Connectivity**
   - [ ] Ensure all devices are reachable via SSH/NETCONF
   - [ ] Configure SSH keys or credentials (use vault for passwords!)
   - [ ] Test connectivity: `ansible all -i inventory/hosts -m ping`

### 3. **Credentials & Secrets**
   - [ ] Add device credentials to vault
   - [ ] SSH keys for passwordless authentication
   - [ ] API tokens if applicable

### 4. **Dry Run Tests**
   - [ ] Run syntax check: `ansible-playbook playbooks/*.yml --syntax-check`
   - [ ] Run with `--check` flag for dry-run
   - [ ] Run with `-vv` for debugging if needed

### 5. **Documentation Updates**
   - [ ] Document your actual network topology
   - [ ] Update VLAN IP ranges based on your setup
   - [ ] Document device models and firmware versions
   - [ ] Create runbooks for common operations

### 6. **Backup Strategies**
   - [ ] Add backup jobs for Proxmox
   - [ ] Backup OPNsense configurations
   - [ ] Test backup restore procedures

---

## 🚀 Quick Start Commands

```bash
# 1. Activate virtual environment (if using one)
cd automation
source venv310/bin/activate

# 2. Install dependencies
pip install -r ../requirements.txt
ansible-galaxy collection install -r ../requirements.yml

# 3. Verify syntax
ansible-playbook playbooks/core_switches.yml --syntax-check --vault-password-file ../.vault_pass

# 4. Dry run (preview changes)
ansible-playbook playbooks/core_switches.yml --check --vault-password-file ../.vault_pass

# 5. Execute (actually apply changes)
ansible-playbook playbooks/core_switches.yml --vault-password-file ../.vault_pass

# 6. Debug mode (verbose output)
ansible-playbook playbooks/core_switches.yml -vv --vault-password-file ../.vault_pass
```

---

## 🔍 Improvements Made from Initial Review

### Security
✅ VLAN topology anonymized  
✅ MAC addresses removed  
✅ Specific device details removed  
✅ Vault encryption enabled with strong password  
✅ All credentials excluded from git  

### Code Quality
✅ All comments converted to English  
✅ Playbook syntax validated  
✅ Collections properly specified  
✅ NETCONF used instead of SSH file manipulation  
✅ Error handling with `ignore_errors` where needed  

### Configuration Management
✅ Inventory path corrected in ansible.cfg  
✅ Required collections added to requirements.yml  
✅ Group variables properly organized  
✅ Templates consolidated for reusability  

---

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Cisco IOS Collection](https://github.com/ansible-collections/cisco.ios)
- [Ansible Vault Guide](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [NETCONF Plugin](https://docs.ansible.com/ansible/latest/plugins/netconf.html)
- [OPNsense Ansible Collection](https://github.com/O-X-L/ansible-opnsense)

---

## 📝 Next Steps

1. **Setup Inventory** - This is the most critical step
2. **Test Connectivity** - Verify all devices are reachable
3. **Run Dry-Runs** - Use `--check` flag to preview changes
4. **Deploy Stage by Stage** - Test one playbook at a time
5. **Monitor and Log** - Enable verbose logging during deployment
6. **Document Issues** - Keep track of any adjustments needed

---

**Status Summary:** Infrastructure automation framework is complete and ready for inventory setup and testing!
