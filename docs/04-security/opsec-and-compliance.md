# OpSec and Compliance

Operational Security (OpSec) principles are integrated throughout the home lab setup to protect against unauthorized access, data breaches, and operational disruptions. This section outlines key practices aligned with GDPR and NIS2 compliance.

## GDPR Considerations

- **Minimize data collection**: Only collect necessary data for lab operations; avoid storing personal information unnecessarily.
- **Encrypt sensitive data**: Use full-disk encryption on devices and encrypt backups.
- **Regularly audit access**: Log and review access to systems; implement least-privilege access controls.
- **Data retention**: Delete unnecessary data periodically to reduce exposure.

## NIS2 Compliance

- **Implement security policies**: Define clear policies for network segmentation, patching, and incident response.
- **Regularly update and patch systems**: Automate updates for OPNsense, Proxmox, and switches to address vulnerabilities.
- **Conduct security audits**: Perform quarterly reviews of configurations, logs, and access controls.

## Additional OpSec Practices for Home Lab

- **Physical Security**: Secure hardware in a locked rack or cabinet; use tamper-evident seals on devices.
- **Network Segmentation**: Isolate VLANs (e.g., IoT on separate segment) to contain breaches.
- **Access Controls**: Use strong, unique passwords; enable multi-factor authentication where possible; limit SSH access to trusted IPs.
- **Logging and Monitoring**: Enable comprehensive logging on firewalls and switches; monitor for anomalies.
- **Backup Security**: Encrypt backups and store off-site; test restoration procedures regularly.
- **Incident Response**: Have a plan for isolating compromised devices and reporting incidents.
- **Supply Chain Security**: Source hardware from reputable vendors; verify firmware integrity.
