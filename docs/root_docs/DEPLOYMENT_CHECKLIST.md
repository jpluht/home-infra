# 📋 DEPLOYMENT CHECKLIST - OPNsense Security Updates

**Purpose**: Step-by-step guide for deploying new OPNsense configuration safely

---

## Pre-Deployment (Lab Environment)

### 1. Review Changes
- [ ] Read `SECURITY_IMPROVEMENTS.md` (understand what's changing)
- [ ] Review firewall rules in `automation/playbooks/opnsense.yml`
- [ ] Check new configuration in `automation/group_vars/opnsense.yml`

### 2. Syntax Validation
```bash
# Validate playbook syntax
ansible-playbook playbooks/opnsense.yml --syntax-check

# Expected output:
# playbook: playbooks/opnsense.yml
#   [WARNING]: unable to parse XXX as an inventory source
#   [OK]
```
- [ ] Playbook syntax OK

### 3. Dry-Run in Lab
```bash
# Test WITHOUT making changes
ansible-playbook playbooks/opnsense.yml \
  --check \
  --vault-password-file .vault_pass \
  -i inventory/hosts

# Review proposed changes carefully
```
- [ ] Dry-run completed successfully
- [ ] No unexpected rule changes proposed
- [ ] No errors in output

### 4. Configure Logging Destination
```bash
# Edit vault to add syslog server destination
ansible-vault edit automation/group_vars/all/vault.yml

# Add or update:
# vault_syslog_server: <IP_OF_SYSLOG_COLLECTOR>
```
- [ ] Syslog server IP added to vault
- [ ] Vault file re-encrypted successfully

### 5. Verify Inventory Connectivity
```bash
# Test that Ansible can reach firewall
ansible opnsense -m ping -i inventory/hosts

# Expected output:
# <firewall_name> | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```
- [ ] OPNsense device responds to ping

---

## Deployment (Production)

### 6. Backup Current Configuration
```bash
# Before ANY changes, export current config
ansible opnsense -m debug -a "var=hostvars[inventory_hostname]" \
  -i inventory/hosts > /tmp/opnsense_backup_$(date +%s).txt
```
- [ ] Backup file created
- [ ] Backup stored in secure location

### 7. Deploy to Production
```bash
# Deploy actual configuration
ansible-playbook playbooks/opnsense.yml \
  --vault-password-file .vault_pass \
  -i inventory/hosts
```

**Monitor output for**:
- [ ] All tasks show "changed" status (or "ok" if idempotent)
- [ ] No error messages
- [ ] No failed tasks
- [ ] All handlers execute (commit netconf changes)

### 8. Verify Firewall is Reachable
```bash
# Test SSH to management VLAN only
ssh admin@<MGMT_VLAN_IP> -i <ssh_key>

# From other VLAN, this should FAIL
# Expected error: Connection refused or timeout
```
- [ ] SSH works from Management VLAN
- [ ] SSH blocked from other VLANs (verify with test device)

### 9. Verify Web UI
```bash
# Test HTTPS access from management VLAN
# Go to: https://<MGMT_VLAN_IP>
# Expected: HTTPS works, session timeout visible
```
- [ ] HTTPS connection works
- [ ] Session timeout configured (verify in UI)

---

## Post-Deployment Verification

### 10. Check Logging
```bash
# Verify logs are being received by syslog server
ssh <syslog_server>
tail -f /var/log/syslog | grep opnsense

# Should see firewall events flowing in
```
- [ ] Logs arriving at syslog server
- [ ] Logs are in readable format (JSON or syslog)

### 11. Test Firewall Rules
```bash
# From User VLAN device:
ping <MGMT_VLAN_IP>          # Should FAIL (rule blocks)
curl http://www.example.com  # Should SUCCEED (WAN allowed)

# From IoT VLAN device:
ping <OTHER_VLAN_IP>         # Should FAIL (isolated)
curl http://www.example.com  # Should FAIL (all blocked)

# From Infrastructure VLAN:
ssh <VM_VLAN_DEVICE> -p 22   # Should SUCCEED (if rule allows)
```
- [ ] Inter-VLAN rules working as expected
- [ ] Isolation rules functioning
- [ ] User internet access working

### 12. Monitor Logs for Issues
```bash
# Check for blocked connections (should be many)
tail -100 /var/log/syslog | grep "block\|deny"

# Check for errors or warnings
tail -50 /var/log/syslog | grep "error\|warning"
```
- [ ] No unexpected errors in logs
- [ ] Blocked traffic being logged
- [ ] No firewall errors

### 13. Verify DDoS Protection Active
```bash
# From external IP, attempt port scan (if applicable)
nmap -sS <WAN_IP>

# Should see:
# - Port scan detection in logs
# - Most ports appear closed/filtered
# - No services exposed
```
- [ ] Port scan detected (check logs)
- [ ] DDoS protection active

### 14. Test Suricata IDS/IPS
```bash
# Check Suricata alert logs
tail -20 /var/log/suricata/eve.json | jq '.'

# Or via syslog:
grep suricata /var/log/syslog | tail -10
```
- [ ] IDS/IPS logs showing alerts
- [ ] Suricata rules loaded

---

## Rollback Plan (If Needed)

### Emergency Rollback
```bash
# If firewall becomes unreachable or breaks network:

# Option 1: Via console (physical access required)
# 1. Connect to OPNsense serial console
# 2. Log in as admin
# 3. Restore from backup configuration

# Option 2: Via Ansible (if Ansible connectivity exists)
# Upload previous working config via backup

# Option 3: Wipe & rebuild
# Redeploy OPNsense ISO, restore from backup
```

### Verification After Rollback
```bash
# Confirm network restored
ansible all -m ping

# Verify firewall status
ansible opnsense -m debug -a "var=hostvars"
```

---

## Post-Deployment Documentation

### 15. Update Inventory
```bash
# Document what was deployed
git log --oneline automation/playbooks/opnsense.yml | head -5

# Expected to see:
# <commit> Updated OPNsense firewall with hardening rules
```
- [ ] Changes committed to git (with vault password)
- [ ] Commit message describes changes

### 16. Train Operators
- [ ] Show operators where logs are collected
- [ ] Demonstrate how to interpret Suricata alerts
- [ ] Explain new firewall rule structure
- [ ] Document how to request new rules

### 17. Schedule Follow-up Review
```
Date for next review: _________________
Reviewer: _________________
Focus areas: 
  - [ ] Log volume and quality
  - [ ] Any false positives from Suricata
  - [ ] Firewall rule changes needed
```

---

## Troubleshooting

### ❌ Playbook Fails with NETCONF Error
```
Error: "netconf_config: Unable to connect to NETCONF"

Solution:
  1. Verify OPNsense has NETCONF enabled
  2. Check SSH connectivity manually
  3. Verify vault password correct
  4. Check ansible inventory for correct host/IP
```

### ❌ Cannot SSH to Firewall After Deployment
```
Error: "Connection refused"

Solution:
  1. SSH may be restricted to Management VLAN now
  2. Test from Management VLAN device
  3. Check firewall rules (should allow SSH from VLAN 10)
  4. If truly broken: use console access to revert
```

### ❌ Logs Not Arriving at Syslog Server
```
Error: "No syslog entries from OPNsense"

Solution:
  1. Check syslog_server IP in vault is correct
  2. Verify firewall can route to syslog server
  3. Check syslog server is listening on port 6514 (TLS)
  4. Review firewall rules (syslog must be allowed)
```

### ❌ Internet Access Broken for Users
```
Error: "User devices can't reach internet"

Solution:
  1. Check User VLAN → WAN rule exists (should be in rules)
  2. Verify NAT rule for outbound traffic
  3. Check DNS servers (should be Quad9 or Cloudflare)
  4. Test manually: ping 8.8.8.8 from user device
```

---

## Success Criteria

You know the deployment was successful when:

✅ **All** of the following are true:
1. Playbook execution: NO errors, all tasks "changed" or "ok"
2. SSH works from Management VLAN, blocked from other VLANs
3. HTTPS web UI accessible and responds normally
4. Logs arriving at syslog server in TLS-encrypted format
5. Firewall rules block inter-VLAN traffic correctly
6. User devices can access internet
7. IoT devices are isolated (blocked from other VLANs)
8. Port scans detected and logged
9. No unexpected firewall errors
10. Suricata IDS/IPS active and logging

If **ANY** of these fail:
- Check the Troubleshooting section above
- Review logs: `tail -50 /var/log/syslog | grep -i error`
- Verify firewall rules: `ansible opnsense -m debug -a "var=hostvars" -i inventory/hosts`

---

## Timeline

| Phase | Time | What to Do |
|-------|------|-----------|
| Pre-Deployment | -24h | Review documentation, lab testing |
| Deployment | 15-30min | Run playbook, monitor execution |
| Immediate | +5min | Verify connectivity & logging |
| Short-term | +1hr | Test firewall rules, document changes |
| Follow-up | +7 days | Review logs, train operators |
| Ongoing | Monthly | Check log quality, audit rules |

---

**Questions?** Refer to `SECURITY_IMPROVEMENTS.md` or `OPSEC_POLICY.md`

