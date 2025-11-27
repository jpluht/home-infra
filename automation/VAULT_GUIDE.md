# Vault Password Management Guide

## Current Setup

**Vault Password File:** `.vault_pass` (root directory)  
**Vault Data File:** `automation/group_vars/all/vault.yml` (encrypted)  
**Encryption Algorithm:** AES256  
**Password Strength:** 256-bit random (Base64-encoded)

---

## How to Generate a Strong Vault Password

### Option 1: Using OpenSSL (Recommended)
```bash
openssl rand -base64 32 | tr -d '\n'
```

### Option 2: Using Python
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Option 3: Using /dev/urandom
```bash
head -c 32 /dev/urandom | base64 | tr -d '\n'
```

---

## How to Change Your Vault Password

### Step 1: Generate a New Strong Password
```bash
NEW_PASS=$(openssl rand -base64 32 | tr -d '\n')
echo "$NEW_PASS"  # Copy this value
```

### Step 2: Save Current Password to Temp File
```bash
cp .vault_pass /tmp/old_vault_pass
```

### Step 3: Create New Password File
```bash
echo -n "YOUR_NEW_PASSWORD_HERE" > /tmp/new_vault_pass
```

### Step 4: Rekey the Vault
```bash
ansible-vault rekey automation/group_vars/all/vault.yml \
  --vault-password-file /tmp/old_vault_pass \
  --new-vault-password-file /tmp/new_vault_pass
```

### Step 5: Replace the Main Password File
```bash
mv /tmp/new_vault_pass .vault_pass
```

### Step 6: Verify It Works
```bash
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

### Step 7: Clean Up Temp Files
```bash
rm /tmp/old_vault_pass /tmp/new_vault_pass
```

---

## How to Encrypt New Secrets

### Add New Variable to Vault
```bash
ansible-vault edit automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

Then add your new secret:
```yaml
vault_new_secret: your_secret_value
```

Save and exit (`:wq` in vim).

---

## How to View Vault Contents

```bash
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass
```

---

## How to Use Vault Variables in Playbooks

In your group_vars files (e.g., `group_vars/core_switches.yml`):
```yaml
vlan_definitions:
  - id: 10
    name: "{{ vault_vlan_10_name }}"
```

When running playbook:
```bash
ansible-playbook playbooks/core_switches.yml --vault-password-file .vault_pass
```

---

## Security Best Practices

### ✅ DO:
- Use long, random passwords (32+ characters)
- Store `.vault_pass` in a secure location
- Use different passwords for different environments (dev/prod)
- Rotate passwords periodically (quarterly)
- Use environment variables for CI/CD: `ANSIBLE_VAULT_PASSWORD_FILE=path/to/pass`
- Back up `.vault_pass` to a secure location (encrypted)

### ❌ DON'T:
- Use simple passwords like "password" or "vault123"
- Share `.vault_pass` over unencrypted channels
- Commit `.vault_pass` to Git (it's in `.gitignore`)
- Commit unencrypted `vault.yml` to Git
- Use the same password for multiple vaults
- Store `.vault_pass` in plaintext in scripts

---

## Password Recovery

If you lose your vault password, the encrypted files cannot be recovered. 
**Always backup `.vault_pass` separately.**

### Create Backup
```bash
# Encrypt the password file itself
gpg -c .vault_pass  # Creates .vault_pass.gpg
# Store in secure location
```

### Restore from Backup
```bash
gpg .vault_pass.gpg  # Enter GPG password to decrypt
```

---

## Automated Password Changes (CI/CD)

For GitHub Actions or other CI/CD:

```bash
# Generate and rotate password automatically
NEW_PASS=$(openssl rand -base64 32 | tr -d '\n')
echo "$NEW_PASS" > .vault_pass
ansible-vault rekey automation/group_vars/all/vault.yml \
  --vault-password-file .vault_pass
```

Or use environment variable:
```bash
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook playbooks/core_switches.yml
```

---

## Troubleshooting

### Issue: "Decryption failed"
**Solution:** Verify correct `.vault_pass` file is being used
```bash
cat .vault_pass  # Check it's not empty
file automation/group_vars/all/vault.yml  # Should show "Ansible Vault"
```

### Issue: "Invalid vault password"
**Solution:** Ensure password file doesn't have extra whitespace
```bash
# Show hidden characters
cat -A .vault_pass
# Should end with % (no newline), not newline
```

### Issue: Can't remember which password is active
**Solution:** Try to view vault; if it works, that's your current password
```bash
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass
# If it works without error, password is correct
```

---

## Reference Commands

```bash
# View vault
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Edit vault
ansible-vault edit automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# Encrypt existing file
ansible-vault encrypt filename.yml --vault-password-file .vault_pass

# Decrypt file
ansible-vault decrypt filename.yml --vault-password-file .vault_pass

# Rekey (change password)
ansible-vault rekey filename.yml --vault-password-file .vault_pass --new-vault-password-file new_pass

# Check file status
file automation/group_vars/all/vault.yml
```

---

**Last Updated:** November 26, 2025  
**Vault Password Strength:** 256-bit random (Base64)
