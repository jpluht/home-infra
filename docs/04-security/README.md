# Security Documentation

Comprehensive security practices, policies, and incident response procedures for infrastructure protection.

## Overview

This section documents all security-related configurations, policies, and best practices implemented across the infrastructure. Security is enforced at multiple layers: network segmentation (VLANs), access control (firewall), intrusion detection (Suricata), and secret management (Vault).

## Security Layers

### 1. Network Segmentation (VLAN Isolation)
- **VLAN 10** (Rivendell): Out-of-band management - isolated, minimal traffic
- **VLAN 20** (Fellowship): Infrastructure & trusted devices - restricted access
- **VLAN 30** (Shire): User devices - limited to necessary services only
- **VLAN 40** (Mordor): Virtual machines - guest systems with no host access
- **VLAN 50** (Mirkwood): IoT & untrusted devices - maximum isolation and filtering

**Benefits**: Device compromise is limited to its VLAN; inter-VLAN traffic is filtered by firewall

### 2. Firewall & Routing (OPNsense)
- **Role**: Edge security, inter-VLAN routing, threat prevention
- **Configuration**: NETCONF-automated via Ansible (firewall rules in Jinja2 templates)
- **Capabilities**: 
  - Stateful firewall with connection tracking
  - NAT for IP masquerading (internal 10.0.x.x → external)
  - Port forwarding for controlled external access
  - Rate limiting and DDoS protection

**Firewall Rules**: See nat.xml.j2 template for current rule set

### 3. Intrusion Detection & Prevention (IDS/IPS)
- **Tool**: Suricata IDS/IPS engine
- **Purpose**: Real-time threat detection and blocking
- **Coverage**: All VLAN traffic passes through Suricata
- **Configuration**: suricata.xml.j2 template (automated deployment)
- **Logging**: Generates alerts and blocks malicious traffic

### 4. Secret Management (Vault Encryption)
- **Tool**: Ansible Vault with AES256 encryption
- **Protected Content**: VLAN names, device credentials, API keys
- **Password**: 256-bit random (not stored in repo, git-ignored)
- **Access Control**: Only users with .vault_pass can decrypt secrets

**Critical Files**:
- `.vault_pass` (git-ignored) - Vault password file
- `automation/group_vars/all/vault.yml` - Encrypted secrets

See [VAULT_GUIDE.md](../automation/VAULT_GUIDE.md) for management procedures

## Security Policies

### Access Control
- **SSH Access**: Limited to authorized keys only
- **Web UI Access**: Authentication required, HTTPS/TLS enforced
- **VLAN Access**: Firewall enforces segmentation rules
- **Privilege Escalation**: SSH keys used instead of passwords where possible

### Network Traffic Rules
1. **Default Deny**: All traffic blocked by default
2. **Explicit Allow**: Only approved traffic is permitted
3. **Rate Limiting**: Prevents DoS and abuse
4. **Logging**: All denied traffic is logged for investigation

### Credential Rotation Policy
- **Initial Setup**: Temporary credentials during bootstrap
- **Post-Deployment**: Change credentials to unique, strong values
- **Storage**: Credentials encrypted in Vault
- **Rotation Frequency**: Quarterly minimum (quarterly for keys, annually for passwords)

### Incident Response
1. **Detection**: Suricata alerts trigger on malicious patterns
2. **Logging**: All traffic logged with full packet capture capability
3. **Isolation**: Compromised VLAN can be isolated at firewall
4. **Analysis**: Logs retained for post-incident forensics
5. **Recovery**: Ansible playbooks allow rapid re-deployment of clean configs

## Compliance & Hardening

### Implemented Best Practices
- ✅ Principle of least privilege (minimal access by default)
- ✅ Defense in depth (multiple security layers)
- ✅ Encryption at rest (Vault) and in transit (TLS)
- ✅ Audit logging of all configuration changes
- ✅ Automated security policy enforcement via IaC

### Security Scanning
- Run regular Suricata rule updates for latest threat signatures
- Monitor firewall logs for policy violations
- Review Ansible logs for unauthorized changes
- Quarterly security audit of firewall rules and VLAN policies

## Related Documentation

- [Firewall & IDS Configuration](./firewall-and-ids.md)
- [Monitoring & Alerting Setup](./monitoring-and-alerting.md)
- [VPN & Authentication](./vpn-and-authentication.md)
- [OPSec & Compliance](./opsec-and-compliance.md)
- [Security Overview](./security-overview.md)