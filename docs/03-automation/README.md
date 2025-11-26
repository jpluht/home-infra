# Automation

Detailed documentation on Ansible automation for secure and repeatable infrastructure management.

Includes:
- Playbook descriptions with example commands
- Variable and template explanations
- Running automation pipelines with troubleshooting tips

## Quick Start Example
To run a playbook (e.g., for OPNsense configuration):
```
ansible-playbook -i inventory/hosts playbooks/opnsense.yml --vault-password-file ~/.ansible_vault_pass
```
Ensure Ansible Vault is used for secrets to maintain OpSec.

## Troubleshooting Tips
- **Vault Errors**: Verify vault password file path and permissions.
- **Connection Issues**: Check SSH keys and firewall rules; use `ansible -m ping` to test connectivity.
- **Template Rendering**: Validate Jinja2 templates with `ansible-playbook --check`.
