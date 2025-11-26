# Vault and Secrets Management

## Ansible Vault

- Encrypt sensitive data (passwords, API keys).
- Store vault password securely (not in Git).
- Use encrypted files in playbooks.

## Example

''''
vault_opnsense_password: !vault | $ANSIBLE_VAULT;1.1;AES256 33616639386639643437323964663835346662396438613934643835386235656639353966643566 64643835663562396664386235663566623566356635623566
''''