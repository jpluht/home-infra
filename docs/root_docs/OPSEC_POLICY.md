# Operational Security (OpSec) Policy

**Status**: CONFIDENTIAL - Restrict Distribution  
**Last Updated**: 2025-11-26

## 1. Information Classification

This infrastructure contains multiple security domains. Information is classified as follows:

### PUBLIC ✅ (Safe to share)
- Generic Ansible concepts and playbook structure
- Tool names and versions (Ansible, Cisco IOS, OPNsense, Proxmox)
- References to standards (IEEE 802.1Q, NETCONF, SSH, HTTPS)
- General best practices (defense-in-depth, least privilege)

### INTERNAL 🔒 (Share only with authorized operators)
- General network segmentation concepts
- Playbook file names and purposes (core_switches.yml, opnsense.yml, etc.)
- Template names (vlans.xml.j2, dhcp.xml.j2, etc.)
- High-level architecture diagrams (without details)

### CONFIDENTIAL 🛑 (MUST NOT BE SHARED)
- **VLAN names** (Rivendell, Fellowship, Shire, Mordor, Mirkwood)
- **VLAN numbers** (10, 20, 30, 40, 50)
- **IP subnets** (10.0.10.0/24, 10.0.20.0/24, etc.)
- **IP addresses** for any devices (switches, firewall, hosts, storage)
- **Firewall rules** (allow/deny patterns, port numbers, protocols)
- **DHCP pools** (IP ranges for each VLAN)
- **Device names, models, serial numbers**
- **Physical locations** or rack positions
- **Usernames or credentials** (any form)
- **DNS names, hostnames** in your infrastructure
- **Vault contents** (passwords, API keys, etc.)

### SENSITIVE ⚠️ (Compartmentalized - need-to-know basis)
- Actual device credentials and passwords
- Vault encryption key and password
- SSH keys and certificate information
- Backup/restore procedures and storage locations
- Disaster recovery activation procedures

## 2. Documentation Guidelines

### What SHOULD Be Documented (PUBLIC/INTERNAL)
- HOW to run playbooks (command syntax, error handling)
- WHAT each template does (general description)
- WHY certain approaches were chosen (trade-offs, design decisions)
- Standards compliance and best practices

### What SHOULD NOT Be Documented (in public/shared docs)
- IP addresses or subnets (use generic examples like `<VLAN_XX_SUBNET>`)
- VLAN names or purposes (use numbers: `VLAN 1`, `VLAN 2`, etc.)
- Specific firewall rules (describe pattern only)
- Device count or specs (generalize to "multiple" or "N+1 redundancy")
- Any actual configuration values

### Example: Right vs Wrong

❌ **WRONG** (Too specific):
```markdown
| 10 | Rivendell | Infrastructure | 10.0.10.0/24 | 10.0.10.1 | Switches, OPNsense, OOB serial |
```

✅ **RIGHT** (Generic):
```markdown
| Management VLAN | Out-of-band access | Internal RFC1918 subnet | Firewall, switches, serial access |
```

## 3. File Security Requirements

### Documentation Files (PUBLIC/SHARED)
- **Location**: `docs/` directory
- **Content**: Anonymized, generic examples only
- **Permissions**: Can be shared with teams, contractors, or published
- **Constraint**: NO real IPs, VLAN names, counts, or configurations

### Configuration Files (INTERNAL/SENSITIVE)
- **Location**: `automation/group_vars/` directory
- **Content**: Real configuration values, encrypted where possible
- **Permissions**: Only authorized infrastructure operators
- **Requirement**: NEVER commit to public Git repos unencrypted
- **Tool**: Use Ansible Vault (AES256) for all sensitive data

### Vault Files (CONFIDENTIAL)
- **Location**: `automation/group_vars/all/vault.yml`
- **Content**: Encrypted secrets (VLAN names, credentials, keys)
- **Encryption**: AES256 with `.vault_pass` key (Git-ignored)
- **Access**: Only persons with vault password
- **Rotation**: Change password quarterly
- **Backup**: Store encrypted backup separate from plaintext key

### Deployment & Logs (SENSITIVE)
- **Deployment**: Execute only from secure, isolated network
- **Logs**: May contain IP addresses or configuration details
- **Retention**: Keep encrypted, delete after 30 days if not needed
- **Sharing**: Redact IPs/configs before sharing for troubleshooting

## 4. Threat Model

### Assumptions
An attacker who gains read access to documentation should NOT be able to:
1. Identify device types or count
2. Determine IP scheme or VLAN layout
3. Understand firewall policy or traffic flows
4. Locate management interfaces or backup systems
5. Enumerate storage or compute resources

### Attack Scenarios
| Threat | Exposure | Mitigation |
|--------|----------|-----------|
| GitHub repo leaked | VLAN names, IPs, subnets in plaintext docs | Remove from docs, keep only in vault |
| Disgruntled employee shares config | Firewall rules, DHCP pools exposed | Vault encryption + access control |
| Device capture during RMA | Might contain VLAN configs | Wipe and redeploy, rotate credentials |
| Network scanning (external) | If docs published, attacker knows to scan 10.0.x.x | Don't mention subnets in public docs |
| Insider threat | Access to git repo and vault | Separate vault password, different access levels |

## 5. Git Repository Security

### Secrets Must NOT Be Committed
```bash
# ❌ BAD - Never commit these
git add automation/group_vars/opnsense.yml    # Contains real IPs
git add automation/.vault_pass                 # Never commit key!
git add *.backup                               # May contain configs

# ✅ GOOD - Only commit encrypted or generic
git add automation/group_vars/all/vault.yml    # Only if AES256 encrypted
git add docs/*.md                              # Generic examples only
```

### .gitignore (Must Include)
```
# Already in place - verify these exist:
automation/.vault_pass          # Vault password file
.vault_pass*                    # Any vault key variants
*.backup                        # Configuration backups
*.tar.gz                        # Compressed archives
.private/                       # Private directory
logs/                           # Execution logs
```

### Git Audit
Verify no secrets in history:
```bash
# Search for IP patterns
git grep -i "10\.0\." | head -20

# Search for VLAN names
git grep -E "(Rivendell|Fellowship|Shire|Mordor|Mirkwood)"

# Search for credential patterns
git grep -E "(password|secret|key|token|credential)" | grep -v "vault"
```

## 6. Access Control

### Ansible Vault
- **Password**: Store in `.vault_pass` (Git-ignored)
- **Backup**: Keep separate copy in secure location
- **Rotation**: Change annually or after personnel changes
- **Audit**: Track who decrypts vault

### Inventory File
- **File**: `automation/inventory/hosts`
- **Content**: Device IPs, credentials, VLAN assignments
- **Access**: Only infrastructure operators
- **Protection**: Should be Git-ignored or encrypted

### Configuration Files
- **Location**: `automation/group_vars/`
- **Protection**: File system permissions (mode 600 where applicable)
- **Access**: Principle of least privilege
- **Audit**: Log all runs with `--vault-password-file`

## 7. Incident Response

### If Documentation Leaked
1. Assume attacker knows network topology and IP scheme
2. Rotate all credentials immediately
3. Review logs for unauthorized access attempts
4. Scan for unauthorized devices in network
5. Consider VLAN relabeling or subnet changes
6. Update firewall rules if strategy was exposed

### If Vault Password Compromised
1. Immediately change vault password (or delete/recreate)
2. Assume all encrypted values are compromised
3. Rotate all passwords, keys, API credentials
4. Regenerate encryption keys
5. Update playbooks with new vault references
6. Audit who had access to `.vault_pass` file

### If Device Credentials Leaked
1. Change device SSH/management passwords
2. Regenerate SSH keys on all devices
3. Audit login history for unauthorized access
4. Check for persistence (backdoor accounts, malware)
5. Reset device configurations if necessary

## 8. Personnel & Onboarding

### What New Operators Need
- ✅ How to run playbooks (`ansible-playbook` command)
- ✅ How to troubleshoot (`ping`, `traceroute`, `show` commands)
- ✅ How to access documentation (generic guides)
- ❌ VLAN names, IPs, firewall rules (temporary access only)
- ❌ Vault password or credentials (provide as needed)

### Offboarding
- Change vault password if person had access
- Rotate device credentials used by departed operator
- Revoke SSH keys and VPN access
- Archive logs for audit trail
- Remove inventory access

### Documentation for Operators
Provide a **REDACTED.md** file that operators can read:
```markdown
# How to Troubleshoot (Redacted Version)

## Check Device Connectivity
ansible <DEVICE_GROUP> -m ping

## View Current Configuration
ansible <DEVICE_GROUP> -m debug -a "var=hostvars[inventory_hostname]"

## Deploy Configuration Changes
ansible-playbook playbooks/<PLAYBOOK>.yml --check
ansible-playbook playbooks/<PLAYBOOK>.yml

## Common Issues
- If ping fails: Check network cable, VLAN assignment, firewall
- If SSH fails: Check management interface IP, firewall rules
- If deployment fails: Check syntax with --syntax-check
```

## 9. Regular Audits

### Monthly
- Review vault access logs
- Verify no secrets in recent commits
- Check for new developers with repository access

### Quarterly
- Rotate vault password
- Update documentation classification
- Review new files for secret exposure
- Audit firewall rules (any changes?)

### Annually
- Full OpSec policy review
- Disaster recovery test (with credentials)
- Personnel access review
- Vulnerability assessment of playbooks

## 10. Tools & References

### For Securing Secrets
```bash
# Encrypt a string
ansible-vault encrypt_string 'secret_value'

# Add to vault file
ansible-vault edit automation/group_vars/all/vault.yml

# View encrypted content
ansible-vault view automation/group_vars/all/vault.yml
```

### For Scanning Repo for Secrets
```bash
# Install secret scanner
pip install detect-secrets

# Scan repository
detect-secrets scan

# Baseline
detect-secrets scan > .secrets.baseline
```

### For Secure Documentation
- Keep original docs in private branch
- Publish sanitized version in public branch
- Use search-and-replace to anonymize:
  - VLAN 10 → `<MGT_VLAN>`
  - 10.0.10.0/24 → `<MGT_SUBNET>`
  - Rivendell → `<MGT_VLAN_NAME>`

---

## Summary

**The core principle**: Documentation can be PUBLIC if it explains HOW to operate infrastructure, but must be CONFIDENTIAL if it reveals WHAT that infrastructure looks like.

**If in doubt, encrypt it** in vault or don't document it publicly.

---

