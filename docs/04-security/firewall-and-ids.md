# Firewall and Intrusion Detection System (IDS)

## OPNsense Firewall Overview

OPNsense is the primary firewall/router protecting the infrastructure, deployed via Ansible automation using NETCONF.

### Firewall Architecture

**Network Interfaces**:
- **WAN**: External internet connectivity (uplink)
- **LAN**: Internal network bridge to all VLANs
- **VLAN Tagged Traffic**: All VLANs tagged on single interface

**Security Functions**:
- ✅ Stateful firewall with connection tracking
- ✅ Network Address Translation (NAT) for IP masquerading
- ✅ Port forwarding for controlled external access
- ✅ DHCP server (per VLAN with subnet configuration)
- ✅ DNS server with blocklist support
- ✅ Intrusion Detection/Prevention (Suricata IDS/IPS)
- ✅ NTP server for time synchronization

### Firewall Rules

Rules follow **default deny** principle - only approved traffic passes.

#### Rule Categories

**Inter-VLAN Rules**:
- INFRA_VLAN (VLAN 10) → All other VLANs: DENY (OOB isolation)
- INFRA_VLAN (VLAN 20) → IOT_VLAN (VLAN 40): ALLOW (mgmt traffic)
- Shire (VLAN 30) → External: ALLOW (user internet)
- IOT_VLAN (VLAN 40) → INFRA_VLAN (VLAN 20): ALLOW (mgmt reply)
- Mirkwood (VLAN 50) → Any: DENY (complete isolation, inbound only)

**External Access**:
- All outbound: ALLOW (standard NAT)
- Inbound WAN: DENY (default, except configured port forwards)

**Management Access**:
- SSH to firewall: Limited to INFRA_VLAN (VLAN 10) or VPN
- Web UI (luci): Limited to INFRA_VLAN (VLAN 20) or VPN

#### Automation Configuration

Firewall rules configured via Ansible template: `automation/templates/nat.xml.j2`

```bash
# Preview generated rules (dry-run)
ansible-playbook playbooks/opnsense.yml --check

# Apply firewall rules
ansible-playbook playbooks/opnsense.yml --vault-password-file .vault_pass
```

### Rule Updates

To modify firewall rules:

1. Edit `automation/group_vars/opnsense.yml` - Update firewall rule variables
2. Update `automation/templates/nat.xml.j2` if rule format changes
3. Test with `--check` flag
4. Apply with full playbook run

## Suricata IDS/IPS Engine

Suricata provides real-time threat detection and prevention across all traffic.

### IDS/IPS Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| **IDS (Detection)** | Log threats, generate alerts | Initial monitoring, troubleshooting |
| **IPS (Prevention)** | Block malicious traffic | Production, active threat response |

Current deployment: **IPS mode** (blocking enabled)

### Suricata Configuration

Configuration managed via Ansible template: `automation/templates/suricata.xml.j2`

**Key Settings**:
- Protocol analysis: HTTP, TLS/SSL, DNS, SMB, RTP
- File extraction: Malware detection from HTTP/HTTPS
- Eve logging: Unified JSON log format for alerting
- Flow tracking: Network session monitoring
- Packet logging: Full packet capture for investigation

### Threat Detection

#### Enabled Threat Categories

| Category | Rules | Source | Update Frequency |
|----------|-------|--------|-------------------|
| **Malware** | ClamAV | Emerging Threats | Daily |
| **Exploit** | Exploit kit signatures | ET Pro | Daily |
| **Web Attack** | SQL injection, XSS, RFI | ET Pro | Daily |
| **Botnet** | C2 communication patterns | ET Pro | Daily |
| **Policy** | P2P, streaming protocols | ET Pro | Daily |

#### Rule Management

```bash
# Update Suricata rules (manual)
cd /etc/suricata/rules/
# Download latest rules from Emerging Threats or Snort

# Validate rules syntax
suricata -T -c /etc/suricata/suricata.yaml

# Reload rules without restart
suricatctl -c /var/run/suricata.socket -R
```

### Alert Monitoring

#### Log Locations

- **Eve JSON Logs**: `/var/log/suricata/eve.json` (all events)
- **Unified Alerts**: `/var/log/suricata/unified2.alert.* `
- **Stats**: `/var/log/suricata/stats.log`

#### Alert Investigation

```bash
# Query recent alerts (all types)
tail -f /var/log/suricata/eve.json | jq .

# Filter for blocked traffic only
tail -f /var/log/suricata/eve.json | jq 'select(.alert.action=="drop")'

# Search for specific IP (replace x.x.x.x)
grep "x.x.x.x" /var/log/suricata/eve.json | jq .
```

#### Alert Actions

| Alert Type | Typical Response | Escalation |
|------------|------------------|------------|
| **Policy Violation** | Log, monitor | None (informational) |
| **Exploit Attempt** | Block, investigate | Check if from trusted source |
| **Botnet C2** | Block immediately | Isolate affected host, scan |
| **Malware File** | Block, quarantine | Full system scan, data review |

### Performance Considerations

Suricata IPS processing impacts throughput:

- **CPU**: Rule matching is CPU-intensive; requires adequate core allocation
- **Memory**: Large rule sets consume significant RAM
- **Latency**: IPS adds ~1-5ms per packet (acceptable for home lab)

**Optimization**:
- Disable unused rule categories
- Use rule profiling to identify slow rules
- Monitor CPU/memory during high traffic periods

## Firewall & IDS Maintenance

### Daily Monitoring
```bash
# Check firewall service status
systemctl status opnsense

# Monitor Suricata alerts in real-time
tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

### Weekly Tasks
- Review Suricata alerts for patterns
- Check firewall rule counters
- Verify inter-VLAN traffic flows as expected

### Monthly Maintenance
- Update Suricata rule sets
- Review and clean up firewall rules
- Audit blocked traffic logs

### Security Updates
- Enable OPNsense automatic updates
- Subscribe to Emerging Threats mailing list
- Test rule updates in non-production first

## Related Documentation

- [Security Overview](./security-overview.md) - Security architecture
- [Firewall Configuration](../../automation/group_vars/opnsense.yml)
- [IDS Rules](../../automation/templates/suricata.xml.j2)
- [NAT Rules](../../automation/templates/nat.xml.j2)

