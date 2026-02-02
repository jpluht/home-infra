# Home Lab Infrastructure - Setup & Deployment Guide

This guide combines project status tracking with detailed deployment instructions.

---

## 📊 Project Status Overview

### ✅ COMPLETED - Phase 1: Private Configuration Setup
- [x] Create .private directory structure
- [x] Create .private/vault-config.yml with 6 VLANs, devices, and firewall rules
- [x] Create .private/inventory/hosts.yml template
- [x] Create .private/credentials/vault_password.txt setup

### ✅ COMPLETED - Phase 2: OPNsense Playbook
- [x] Implement oxlorg.opnsense collection (v25.7.8)
- [x] Create opnsense.yml playbook with REST API calls
- [x] Add firewall rules template (firewall.xml.j2)
- [x] Complete NAT rules template (nat.xml.j2)
- [x] Add all OPNsense templates (DHCP, DNS, NTP, Suricata, VLANs)

### ✅ COMPLETED - Phase 3: Firewall Rules Definition
- [x] Define comprehensive inter-VLAN firewall rules (10 rules)
- [x] Add NAT rules for internet access
- [x] Configure IDS/IPS rules in Suricata
- [x] Add Jellyfin access for family (USER_VLAN → VM_VLAN)
- [x] Add camera internet access (CAMERA_VLAN → Internet)
- [x] Complete IoT isolation (IOT_VLAN blocked)

### ✅ COMPLETED - Phase 4: Ansible Environment Setup
- [x] Set up Python virtual environment
- [x] Install Ansible collections (oxlorg.opnsense v25.7.8)
- [x] Install Python dependencies
- [x] Update requirements.yml
- [x] Run syntax checks on all playbooks

### ✅ COMPLETED - Phase 5: Documentation
- [x] Update README with setup instructions
- [x] Create comprehensive deployment guides
- [x] Add troubleshooting guides
- [x] Document all firewall rules

### ⏳ PENDING - Phase 6: Testing and Deployment
- [ ] Update .private/vault-config.yml with actual device IPs
- [ ] Create .private/inventory/hosts.yml with real credentials
- [ ] Enable OPNsense API (System → Settings → API)
- [ ] Test connectivity to all devices
- [ ] Run playbooks with --check mode (dry-run)
- [ ] Test individual playbooks
- [ ] Run full deployment playbook
- [ ] Validate configurations on devices

---

## 🎯 Current Status: READY FOR DEPLOYMENT

**Automation Complete:** 95%
- Configuration: ✅ 100%
- Playbooks: ✅ 100%
- Templates: ✅ 100%
- Documentation: ✅ 100%
- Testing: ⏳ 0% (requires your infrastructure)

---

## 📋 Complete Deployment Checklist

Use this comprehensive checklist to ensure a smooth deployment.

### Pre-Deployment Checklist

#### Environment Preparation
- [ ] All hardware is physically installed and powered on
- [ ] All network cables are connected correctly
- [ ] Console access to all devices is available
- [ ] Backup of current device configurations (if any) is saved
- [ ] Python virtual environment is activated (`source automation/venv310/bin/activate`)

#### Configuration Files
- [ ] `.private/vault-config.yml` is populated with actual network details
- [ ] `.private/inventory/hosts.yml` contains correct device IPs
- [ ] All credentials are encrypted using ansible-vault
- [ ] Vault password file (`.vault_pass`) is accessible
- [ ] VLAN IDs and subnets are finalized
- [ ] Firewall rules are reviewed and approved

#### Ansible Environment
- [ ] Python dependencies installed (`pip install -r requirements.txt`)
- [ ] Ansible collections installed (`ansible-galaxy collection install -r requirements.yml`)
- [ ] `oxlorg.opnsense` collection is installed (verify with `ansible-galaxy collection list`)
- [ ] `requirements.yml` references `oxlorg.opnsense` (not `ansibleguy.opnsense`)

#### Network Access
- [ ] Management station can reach all devices
- [ ] SSH is enabled on all devices
- [ ] OPNsense REST API is enabled
- [ ] Firewall allows SSH from management station
- [ ] Test ping to all devices successful

#### Testing
- [ ] All playbooks pass syntax check (`--syntax-check`)
- [ ] Connectivity test passes (`ansible all -m ping`)
- [ ] Dry-run completed successfully (`--check` mode)
- [ ] Output reviewed and understood

---

## 🚀 Deployment Instructions

### Step 1: Verify Requirements

Ensure you have completed:
```bash
# Check Python virtual environment
cd automation
source venv310/bin/activate
python --version  # Should be 3.10+

# Verify Ansible collections installed
ansible-galaxy collection list | grep oxlorg.opnsense

# Check requirements
pip list | grep ansible
```

### Step 2: Populate Your Infrastructure Details

#### 2.1 Edit Vault Configuration
```bash
nano .private/vault-config.yml
```

Update with your actual:
- Device IPs (replace 192.168.x.x with your IPs)
- VLAN subnets (if different from defaults)
- DHCP ranges for each VLAN
- DNS servers (if using custom DNS)
- Firewall rules (customize for your specific needs)

**Example changes:**
```yaml
# Before (example)
opnsense_ip: "10.0.10.1"

# After (your actual IP)
opnsense_ip: "10.0.10.1"
```

#### 2.2 Create Inventory File
```bash
nano .private/inventory/hosts.yml
```

Replace all placeholder IPs with your actual device IPs:
- OPNsense firewall IP
- Core switch IPs (2 switches)
- PoE switch IP
- Proxmox node IP
- GPU node IP (if applicable)

**Template structure:**
```yaml
all:
  children:
    opnsense:
      hosts:
        fw_main:
          ansible_host: YOUR_OPNSENSE_IP
          ansible_user: root
          ansible_password: !vault |
            $ANSIBLE_VAULT;1.1;AES256
            [encrypted password]
    
    core_switches:
      hosts:
        core_sw1:
          ansible_host: YOUR_SWITCH1_IP
        core_sw2:
          ansible_host: YOUR_SWITCH2_IP
    
    # ... etc
```

### Step 3: Encrypt Your Credentials

For each password, run:
```bash
cd automation
source venv310/bin/activate

# Encrypt a password
ansible-vault encrypt_string 'YOUR_ACTUAL_PASSWORD' \
  --vault-password-file ../.vault_pass \
  --name 'variable_name'
```

Then copy the output and replace the placeholder in `.private/inventory/hosts.yml`.

**Credentials to encrypt:**
1. `opnsense_admin_password` - OPNsense root password
2. `opnsense_api_key` - OPNsense API key
3. `opnsense_api_secret` - OPNsense API secret
4. `cisco_switch_password` - Switch enable password
5. `proxmox_root_password` - Proxmox root password
6. `gpu_node_password` - GPU node password (if applicable)

### Step 4: Enable OPNsense API

1. Log into OPNsense WebGUI (https://YOUR_OPNSENSE_IP)
2. Navigate to: **System → Settings → API**
3. Enable **REST API**
4. Click **Create** to generate API key and secret
5. Copy the key and secret
6. Encrypt them using ansible-vault (Step 3)
7. Add encrypted values to your inventory file

### Step 5: Test Basic Connectivity

```bash
# Ping your devices
ping YOUR_OPNSENSE_IP      # OPNsense
ping YOUR_CORE_SWITCH1_IP  # Core switch 1
ping YOUR_CORE_SWITCH2_IP  # Core switch 2
ping YOUR_POE_SWITCH_IP    # PoE switch
ping YOUR_PROXMOX_IP       # Proxmox
ping YOUR_GPU_NODE_IP      # GPU node (if applicable)
```

### Step 6: Verify SSH Access

```bash
# Test SSH to each device
ssh root@YOUR_OPNSENSE_IP      # OPNsense
ssh admin@YOUR_CORE_SWITCH1_IP # Core switch 1
ssh admin@YOUR_CORE_SWITCH2_IP # Core switch 2
ssh admin@YOUR_POE_SWITCH_IP   # PoE switch
ssh root@YOUR_PROXMOX_IP       # Proxmox
ssh root@YOUR_GPU_NODE_IP      # GPU node (if applicable)
```

---

## 🎯 Deployment Sequence

### Phase 1: OPNsense Firewall
- [ ] Review OPNsense playbook one more time
- [ ] Run OPNsense playbook in check mode
- [ ] Deploy OPNsense configuration
- [ ] Verify VLANs created in OPNsense WebGUI
- [ ] Verify DHCP servers configured
- [ ] Verify firewall rules applied
- [ ] Verify Suricata IDS/IPS enabled
- [ ] Test internet connectivity from OPNsense

### Phase 2: Core Switches
- [ ] Review core switches playbook
- [ ] Run core switches playbook in check mode
- [ ] Deploy core switches configuration
- [ ] Verify VLANs created (`show vlan brief`)
- [ ] Verify trunk ports configured (`show interfaces trunk`)
- [ ] Verify management VLAN interface is up
- [ ] Test SSH access to switches via management VLAN

### Phase 3: PoE Switches
- [ ] Review PoE switches playbook
- [ ] Run PoE switches playbook in check mode
- [ ] Deploy PoE switches configuration
- [ ] Verify VLANs created
- [ ] Verify access ports configured
- [ ] Verify PoE is enabled on required ports
- [ ] Test PoE device connectivity (AP, camera, phone)

### Phase 4: Proxmox Cluster (if applicable)
- [ ] Review Proxmox playbook
- [ ] Run Proxmox playbook in check mode
- [ ] Deploy Proxmox configuration
- [ ] Verify network bridges created
- [ ] Verify cluster formation (if multiple nodes)
- [ ] Test VM creation and network connectivity

### Phase 5: GPU Node (if applicable)
- [ ] Review GPU node playbook
- [ ] Run GPU node playbook in check mode
- [ ] Deploy GPU node configuration
- [ ] Verify NVIDIA drivers installed
- [ ] Verify CUDA toolkit installed
- [ ] Verify iSCSI storage configured
- [ ] Test GPU functionality (`nvidia-smi`)

---

## 🧪 Testing Sequence

### Test 1: Syntax Validation

```bash
cd automation
source venv310/bin/activate

# Check all playbooks for syntax errors
ansible-playbook playbooks/deploy-network.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass

ansible-playbook playbooks/opnsense.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass

ansible-playbook playbooks/core_switches.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass

ansible-playbook playbooks/poe_switches.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass

ansible-playbook playbooks/proxmox.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass

ansible-playbook playbooks/gpu_node.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass
```

**Expected output:** `playbook: playbooks/xxx.yml` (no errors)

### Test 2: Ansible Connectivity Test

```bash
# Test Ansible can reach all devices
ansible all \
  -i ../.private/inventory/hosts.yml \
  -m ping \
  --vault-password-file ../.vault_pass
```

**Expected output:** All devices respond with `"ping": "pong"`

### Test 3: Dry-Run (Check Mode)

```bash
# Run full deployment in check mode (no changes made)
ansible-playbook playbooks/deploy-network.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  --check -vv
```

**Review the output carefully:**
- Check what changes would be made
- Verify no errors occur
- Ensure changes match your expectations

### Test 4: Deploy Individual Components

Start with OPNsense (safest to test first):

```bash
# Deploy OPNsense configuration
ansible-playbook playbooks/opnsense.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v
```

**Verify in OPNsense WebGUI:**
- VLANs created
- DHCP servers configured
- Firewall rules applied
- Suricata IDS/IPS enabled

Then deploy switches:

```bash
# Deploy core switches
ansible-playbook playbooks/core_switches.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v

# Deploy PoE switches
ansible-playbook playbooks/poe_switches.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v
```

**Verify on switches:**
```bash
# SSH to switch and check
ssh admin@YOUR_SWITCH_IP
show vlan brief
show interfaces trunk
```

### Test 5: Full Deployment

Once individual components work:

```bash
# Deploy entire network
ansible-playbook playbooks/deploy-network.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v
```

---

## ✅ Post-Deployment Verification

### Network Connectivity
- [ ] Devices on each VLAN can ping their gateway
- [ ] DHCP is assigning addresses correctly
- [ ] DNS resolution works
- [ ] Internet access works (where allowed by firewall)
- [ ] Inter-VLAN communication follows firewall rules

### Security
- [ ] Firewall rules are enforced correctly
- [ ] Blocked traffic is actually blocked
- [ ] Allowed traffic is actually allowed
- [ ] IDS/IPS is generating alerts (test with known signatures)
- [ ] Management VLAN is isolated
- [ ] IoT VLAN is restricted

### Services
- [ ] DHCP servers are running
- [ ] DNS servers are responding
- [ ] NTP is synchronizing time
- [ ] Suricata is monitoring traffic
- [ ] All critical services are up

### Device-Specific Verification

#### OPNsense
- [ ] WebGUI accessible at `https://YOUR_OPNSENSE_IP`
- [ ] All interfaces are up
- [ ] All VLANs are configured
- [ ] DHCP leases are being issued
- [ ] Firewall rules are active
- [ ] Suricata is running
- [ ] System logs show no errors

#### Switches
- [ ] All VLANs are created (`show vlan brief`)
- [ ] Trunk ports are operational (`show interfaces trunk`)
- [ ] Access ports are in correct VLANs
- [ ] PoE is delivering power (if applicable)
- [ ] No spanning tree errors
- [ ] Management interface is accessible

#### Proxmox (if applicable)
- [ ] WebGUI accessible at `https://YOUR_PROXMOX_IP:8006`
- [ ] All nodes are in cluster (if multiple nodes)
- [ ] Network bridges are functional
- [ ] Storage is accessible
- [ ] VMs can be created and started

#### GPU Node (if applicable)
- [ ] SSH accessible
- [ ] NVIDIA drivers loaded (`nvidia-smi`)
- [ ] CUDA available
- [ ] iSCSI storage mounted (if configured)
- [ ] LLM models directory accessible (if applicable)

---

## 📝 Post-Deployment Documentation

After successful deployment:

- [ ] Document actual device IPs used
- [ ] Document any deviations from plan
- [ ] Document any issues encountered and solutions
- [ ] Update network topology diagram
- [ ] Create runbook for common operations
- [ ] Document backup and recovery procedures

### Backup and Recovery

- [ ] Save device configurations
  - [ ] OPNsense: System → Configuration → Backups
  - [ ] Switches: `copy running-config startup-config` + backup to TFTP
  - [ ] Proxmox: Backup `/etc/pve/`
- [ ] Test configuration restore procedure
- [ ] Document recovery steps
- [ ] Store backups securely (encrypted, off-site)

### Monitoring Setup (Optional)

- [ ] Configure syslog collection
- [ ] Set up monitoring dashboards
- [ ] Configure alerting for critical events
- [ ] Document monitoring procedures

### Final Sign-Off

- [ ] All phases completed successfully
- [ ] All verification checks passed
- [ ] Documentation updated
- [ ] Backups created and tested
- [ ] Team/stakeholders notified (if applicable)
- [ ] Deployment marked as complete

### Deployment Notes Template

**Date**: _______________

**Deployed by**: _______________

**Issues encountered**:
- 
- 
- 

**Deviations from plan**:
- 
- 
- 

**Next steps**:
- 
- 
- 

**Sign-off**: _______________

---

## 🔧 Troubleshooting

### Issue: Ansible Cannot Connect to Device

**Symptoms:** `UNREACHABLE` or connection timeout errors

**Solutions:**
1. Verify device IP is correct in inventory
2. Test SSH manually: `ssh user@device_ip`
3. Check firewall allows SSH from management station
4. Verify credentials are correct and properly encrypted
5. Check device is powered on and network cable connected

### Issue: OPNsense API Calls Fail

**Symptoms:** API authentication errors or 401/403 responses

**Solutions:**
1. Verify API is enabled in OPNsense (System → Settings → API)
2. Check API key and secret are correct
3. Ensure credentials are properly encrypted in inventory
4. Test API manually with curl:
```bash
curl -k -u "KEY:SECRET" https://YOUR_OPNSENSE_IP/api/core/firmware/status
```

### Issue: Playbook Fails on Specific Task

**Symptoms:** Task fails with error message

**Solutions:**
1. Run with verbose output: `-vvv`
2. Check the specific error message
3. Verify the configuration in vault-config.yml
4. Test the specific module manually
5. Check device logs for more details

### Issue: Changes Not Applied

**Symptoms:** Playbook runs successfully but changes not visible

**Solutions:**
1. Check if running in `--check` mode (dry-run)
2. Verify device configuration manually
3. Check if device requires reboot or service restart
4. Review playbook output for "changed" vs "ok" status
5. Check device logs for errors

### If Deployment Fails

1. **Check Ansible output**
   - [ ] Review error messages carefully
   - [ ] Run with `-vvv` for detailed output
   - [ ] Check which task failed

2. **Verify device state**
   - [ ] SSH to device manually
   - [ ] Check device logs
   - [ ] Verify configuration manually

3. **Check connectivity**
   - [ ] Ping device
   - [ ] Verify SSH access
   - [ ] Check firewall rules

4. **Review configuration**
   - [ ] Verify vault-config.yml syntax
   - [ ] Check inventory file
   - [ ] Verify credentials are correct

5. **Rollback if needed**
   - [ ] Restore device configuration from backup
   - [ ] Document what went wrong
   - [ ] Fix issue before retrying

---

## 🎓 Project Highlights

**Network Architecture:**
- 6 VLANs with security segmentation
- 10 firewall rules with granular access control
- Family can access Jellyfin media server
- Cameras can send internet notifications
- IoT devices completely isolated

**Automation:**
- Infrastructure as Code with Ansible
- Automated OPNsense configuration
- Automated switch configuration
- Automated hypervisor setup

**Security:**
- Defense in depth
- Least privilege access
- IDS/IPS monitoring
- Complete IoT isolation

---

## 📚 Additional Resources

- **Main README:** [README.md](README.md) - Project overview
- **Automation Guide:** [automation/README.md](automation/README.md) - Ansible details
- **Documentation:** [docs/](docs/) - Hardware, setup, security guides
- **Private Setup:** [.private/README.md](.private/README.md) - Private configuration guide

---

## 🚀 Quick Reference Commands

### Activate Environment
```bash
cd automation
source venv310/bin/activate
```

### Deploy All
```bash
ansible-playbook playbooks/deploy-network.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v
```

### Deploy Individual Component
```bash
ansible-playbook playbooks/opnsense.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  -v
```

### Check Mode (Dry-Run)
```bash
ansible-playbook playbooks/deploy-network.yml \
  -i ../.private/inventory/hosts.yml \
  --vault-password-file ../.vault_pass \
  --check -vv
```

### Test Connectivity
```bash
ansible all \
  -i ../.private/inventory/hosts.yml \
  -m ping \
  --vault-password-file ../.vault_pass
```

### Syntax Check
```bash
ansible-playbook playbooks/deploy-network.yml \
  --syntax-check \
  --vault-password-file ../.vault_pass
```

---

**Ready to deploy!** 🚀

**Remember:** Always run in check mode first, review the output, and only then deploy to production!
