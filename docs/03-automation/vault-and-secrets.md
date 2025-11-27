# Vault and Secrets Management

Complete guide to Ansible Vault encryption and secret management for sensitive infrastructure data.

## Overview

Ansible Vault provides AES256 encryption for sensitive data in Ansible playbooks, protecting secrets while allowing code to remain in version control.

## Current Vault Configuration

### Vault Location and Content
```
File: automation/group_vars/all/vault.yml
Encryption: AES256 (256-bit key)
Password: 44-character random string (stored in .vault_pass, git-ignored)
```

### Encrypted Data (VLAN Names - Lord of the Rings Theme)
```yaml
vault_vlan_10_name: Rivendell      # Infrastructure/OOB
vault_vlan_20_name: Fellowship     # Trusted devices
vault_vlan_30_name: Shire          # User devices
vault_vlan_40_name: Mordor         # Virtual machines
vault_vlan_50_name: Mirkwood       # IoT/isolated
```

## Vault Operations

### Viewing Vault Contents
```bash
# Display all encrypted variables
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Example output shows VLAN names (verify contents match expectations)
```

### Editing Vault File
```bash
# Open vault in text editor for modifications
ansible-vault edit automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Make changes, save, and vault automatically re-encrypts
```

### Creating New Vault Files
```bash
# Create new vault file (prompts for password)
ansible-vault create automation/group_vars/new_secrets.yml

# Add password to .vault_pass for automated access
echo "your-256-bit-password" >> .vault_pass
```

### Rekeying Vault Password
```bash
# Change vault password (prompts for old and new password)
ansible-vault rekey automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# If password lost, vault contents cannot be recovered - keep backup!
```

## Using Vault in Playbooks

### Referencing Vault Variables

Playbooks automatically decrypt vault variables when `--vault-password-file` is provided:

```yaml
- name: Configure VLANs
  hosts: core_switches
  vars:
    vlan_infra_name: "{{ vault_vlan_10_name }}"  # Decrypted from vault
  tasks:
    - name: Create Infrastructure VLAN
      cisco.ios.ios_config:
        lines: "vlan {{ vlan_id }}"
        parents: "vlan {{ vlan_id }}"
        context: "description {{ vlan_infra_name }}"  # Uses decrypted value
```

### Running Playbooks with Vault

```bash
# All three methods work - provide vault password:

# Method 1: Password file (recommended, automated)
ansible-playbook playbooks/core_switches.yml --vault-password-file .vault_pass

# Method 2: Prompt for password (interactive)
ansible-playbook playbooks/core_switches.yml --ask-vault-pass

# Method 3: Environment variable (CI/CD pipelines)
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook playbooks/core_switches.yml
```

## Vault Security Best Practices

### Password Management

| Practice | Description | Status |
|----------|-------------|--------|
| **Strong Password** | 256-bit random minimum | ✅ Implemented |
| **Secure Storage** | .vault_pass git-ignored | ✅ Configured |
| **No Hardcoding** | Never commit password in code | ✅ Enforced |
| **Backup Password** | Store separately from vault file | ⚠️ User responsibility |
| **Rotation** | Change password periodically | ⚠️ Quarterly recommended |

### Backup Strategy

```bash
# Create backup of vault before major changes
cp automation/group_vars/all/vault.yml \
   automation/group_vars/all/vault.yml.backup.$(date +%Y%m%d)

# Verify backup can be decrypted (don't test on critical files!)
ansible-vault view automation/group_vars/all/vault.yml.backup.DATE --vault-password-file .vault_pass
```

### Access Control

- **File Permissions**: `.vault_pass` should be `600` (user read/write only)
- **Repository Access**: Restrict who can push code (includes git history with past passwords)
- **Vault File**: Even encrypted, restrict read access to authorized users
- **CI/CD**: Use secrets management (GitHub Secrets, GitLab Variables, etc.)

```bash
# Verify permissions
ls -la .vault_pass automation/group_vars/all/vault.yml
# Should show: -rw------- (600 for .vault_pass)
```

## Advanced Vault Features

### Encrypting Individual Variables

```bash
# Encrypt specific variable within YAML file
ansible-vault encrypt_string 'secret_value' --vault-password-file .vault_pass

# Output can be pasted into any Ansible file:
!vault |
  $ANSIBLE_VAULT;1.1;AES256
  66653937373833373634633232653061333763383636613563633763333639393...
```

### Mixing Encrypted and Plaintext

```yaml
# Some variables encrypted, others plaintext (valid YAML)
vault_secret_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  ...

plaintext_description: "This is not encrypted"
```

### Vault Filtering in Output

```bash
# Run playbook but don't display vault variable values
ansible-playbook playbooks/opnsense.yml --vault-password-file .vault_pass \
  | grep -v "vault_"
```

## Troubleshooting Vault Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Vault password not provided" | Missing --vault-password-file flag | Add `--vault-password-file .vault_pass` to command |
| "Decryption failed" | Wrong password | Verify .vault_pass file content and permissions |
| "Undefined variable" | Vault variable not in group_vars | Check variable name matches exactly |
| "Permission denied" | .vault_pass file not readable | Run `chmod 600 .vault_pass` |
| "Cannot decrypt backup" | Old password, new vault used | Use correct password file for that backup |

## CI/CD Integration

### GitHub Actions Example
```yaml
# Never store plain password in secrets!
# Use VAULT_PASSWORD in GitHub Actions:

- name: Run Ansible Playbook
  env:
    VAULT_PASSWORD: ${{ secrets.VAULT_PASSWORD }}
  run: |
    echo "$VAULT_PASSWORD" > /tmp/.vault_pass
    chmod 600 /tmp/.vault_pass
    ansible-playbook playbooks/core_switches.yml --vault-password-file /tmp/.vault_pass
    rm /tmp/.vault_pass
```

## Related Documentation

- **Full Vault Guide**: [automation/VAULT_GUIDE.md](../../automation/VAULT_GUIDE.md)
- **Security Policies**: [Security Overview](./security-overview.md)
- **Playbook Examples**: [Playbooks and Templates](./playbooks-and-templates.md)
- **Ansible Documentation**: https://docs.ansible.com/ansible/latest/user_guide/vault.html

ecrets Management

## Ansible Vault

- Encrypt sensitive data (passwords, API keys).
- Store vault password securely (not in Git).
- Use encrypted files in playbooks.

## Example

''''
vault_opnsense_password: !vault | $ANSIBLE_VAULT;1.1;AES256 33616639386639643437323964663835346662396438613934643835386235656639353966643566 64643835663562396664386235663566623566356635623566
''''