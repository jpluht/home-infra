# Troubleshooting Automation Issues

Comprehensive guide for diagnosing and resolving Ansible automation problems.

## Pre-Execution Checks

### 1. Inventory Verification
```bash
# Verify inventory file exists
ls -la automation/inventory/hosts

# Test inventory parsing
ansible-inventory -i automation/inventory/hosts --list

# Check host reachability
ansible all -i automation/inventory/hosts -m ping
```

**Common Issues**:
- ❌ File not found: Create `automation/inventory/hosts` with your devices
- ❌ Parse errors: Check INI syntax (brackets, colons, spacing)
- ❌ Unreachable hosts: Verify network connectivity, SSH/NETCONF ports open

### 2. Vault Password Validation
```bash
# Test vault password file accessibility
ansible-vault view automation/group_vars/all/vault.yml --vault-password-file .vault_pass

# If fails: verify password file exists and is readable
cat .vault_pass | wc -c  # Should output 44+ characters
```

**Common Issues**:
- ❌ "Decryption failed": Wrong password, corrupt .vault_pass file
- ❌ "Permission denied": Check file permissions (`chmod 600 .vault_pass`)

## Playbook Execution Issues

### 3. Syntax Errors
```bash
# Always run syntax check first
ansible-playbook playbooks/core_switches.yml --syntax-check --vault-password-file .vault_pass
```

**Error Examples**:
- ❌ `ERROR! Unexpected end of file`: Missing closing bracket or quote
- ❌ `ERROR! conflicting action statements`: Duplicate module names

**Solution**: Check YAML indentation and syntax in the playbook

### 4. Connection Failures

| Error | Cause | Solution |
|-------|-------|----------|
| `Host unreachable` | Network connectivity | Verify device IP, ping target, check firewall |
| `Permission denied (publickey)` | SSH key auth failed | Verify key path in group_vars, SSH permissions |
| `NETCONF port not open` | Device doesn't support NETCONF | Check if device has NETCONF enabled |
| `Connection timeout` | Device not responding | Ensure device is powered on and reachable |

```bash
# Debug connection issues
ansible -i inventory/hosts [hostname] -m debug -a "msg='Test'" -vvv
```

### 5. Module Execution Failures

| Module | Common Issues | Solution |
|--------|---------------|----------|
| `cisco.ios.ios_config` | Device returned error | Check device supports config format |
| `netconf_config` | XML parse error | Validate Jinja2 template rendering with `--check` |
| `apt` | Package not found | Verify package name matches distro version |
| `pip` | Module not available | Ensure Python and pip installed on target |

```bash
# Test module with verbosity
ansible-playbook playbooks/core_switches.yml --check -vvv
```

### 6. Variable Issues

**Missing Variables**:
```bash
# Check if variable is defined
ansible all -i inventory/hosts -m debug -a "var=vault_vlan_10_name"
```

**Expected Issues**:
- ❌ `UNDEFINED variable`: Variable not in group_vars or vault
- ❌ `Type error`: Variable format doesn't match expectation

**Solution**: Check `group_vars/[group].yml` and ensure variables exist

### 7. Template Rendering Problems

```bash
# Preview rendered template without applying
ansible-playbook playbooks/opnsense.yml --check --diff

# Show template variable values
ansible -i inventory/hosts opnsense -m template -a "src=templates/vlans.xml.j2 dest=/tmp/vlans.xml"
```

**Common Issues**:
- ❌ Undefined variables in template
- ❌ Incorrect Jinja2 filter syntax
- ❌ Missing loop variables

## Diagnostic Commands

### Gather Facts from Target Host
```bash
ansible [hostname] -i inventory/hosts -m setup -a "filter=ansible_os_family"
```

### Check Ansible Version Compatibility
```bash
ansible --version
ansible-galaxy collection list | grep -E "ansible|cisco|community"
```

### Enable Maximum Verbosity
```bash
# Most verbose debugging (use sparingly - large output)
ansible-playbook playbooks/core_switches.yml -vvvv --vault-password-file .vault_pass
```

### Validate Group Variables
```bash
# Show variables for specific host
ansible [hostname] -i inventory/hosts -m debug -a "var=hostvars[inventory_hostname]"
```

## Recovery Procedures

### Rollback Failed Configuration
1. Keep backup of original device configuration
2. Use `--check` flag to preview changes before applying
3. If config fails, restore from backup manually

### Retry Failed Playbook
```bash
# Re-run specific task with verbose output
ansible-playbook playbooks/core_switches.yml --start-at-task="Task Name" -vvv
```

## Support Resources

- **Vault Issues**: See [Vault and Secrets](./vault-and-secrets.md) and [VAULT_GUIDE.md](../../automation/VAULT_GUIDE.md)
- **Playbook Details**: See [Playbooks and Templates](./playbooks-and-templates.md)
- **Ansible Docs**: https://docs.ansible.com/
- **Network Device Modules**: https://docs.ansible.com/ansible/latest/collections/cisco/ios/

