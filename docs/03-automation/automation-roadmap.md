# Automation Roadmap & Future Enhancements

Strategic planning for expanding automation coverage and infrastructure-as-code maturity.

**Note**: This document outlines future development. See [IMPROVEMENTS.md](../../IMPROVEMENTS.md) for prioritized enhancement list.

## Current Automation Status

### Implemented (NOW ✅)
- ✅ Cisco switch VLAN and trunk configuration (core + PoE)
- ✅ OPNsense firewall/routing setup via NETCONF
- ✅ Proxmox cluster bootstrapping and storage
- ✅ GPU node Ubuntu setup with NVIDIA drivers
- ✅ Vault-based secret management (AES256)
- ✅ Ansible playbook validation and dry-run testing

### Gaps (TO DO ⚠️)
- ⚠️ No Kubernetes/container orchestration
- ⚠️ Limited monitoring and alerting automation
- ⚠️ No backup/disaster recovery automation
- ⚠️ No Terraform for IaC (Ansible-based only)
- ⚠️ Manual inventory management required
- ⚠️ No CI/CD pipeline integration

## Phase 1: Near-Term (1-3 Months)

### 1.1 Inventory Management Automation

**Objective**: Auto-discovery and dynamic inventory

```yaml
# Goal: Replace manual inventory/hosts with dynamic discovery
# Option A: Ansible custom dynamic inventory script
# Option B: Integration with existing IPAM solution
# Option C: SNMP-based device discovery

Tasks:
  - Create custom inventory script for your environment
  - Auto-detect devices on VLAN 10 (management)
  - Generate inventory from device responses
  - Test with existing playbooks
```

**Timeline**: 2-3 weeks
**Effort**: Medium (requires custom script)
**Benefit**: Reduce manual inventory updates

### 1.2 Basic Monitoring & Alerting

**Objective**: Real-time infrastructure status

```yaml
# Goal: Monitor switch health, OPNsense performance, Proxmox status
# Tools: Prometheus (metrics), Alertmanager (alerts)

Tasks:
  - Deploy Prometheus on GPU node (or Proxmox VM)
  - Configure Proxmox monitoring (built-in)
  - Add Cisco switch SNMP exporters
  - Add OPNsense metrics collection
  - Create Grafana dashboards
  - Configure alerts for critical issues
```

**Timeline**: 4-6 weeks
**Effort**: Medium (requires new toolchain)
**Benefit**: Visibility into infrastructure health

### 1.3 Configuration Backup Automation

**Objective**: Regular device configuration backups

```yaml
# Goal: Backup all device configs weekly
# Methods: Ansible backup modules, git integration

Tasks:
  - Backup switch running configs (cisco.ios)
  - Backup OPNsense configs (NETCONF export)
  - Backup Proxmox cluster configuration
  - Store in git repository with version history
  - Test restore procedures quarterly
```

**Timeline**: 1-2 weeks
**Effort**: Low (straightforward with Ansible)
**Benefit**: Disaster recovery capability

## Phase 2: Mid-Term (2-6 Months)

### 2.1 Infrastructure as Code (Terraform)

**Objective**: Infrastructure definition in code

```yaml
# Goal: Define infrastructure requirements in Terraform
# Scope: Proxmox resource definition, network topology

Structure:
  terraform/
    main.tf              # Primary configuration
    variables.tf        # Input variables
    outputs.tf          # Output values
    provisioners/       # Ansible integration
    modules/
      proxmox/          # Proxmox VE provider
      vm/               # VM definition module
      storage/          # Storage backend module

Tasks:
  - Learn Terraform basics (HCL syntax)
  - Install Terraform and Proxmox provider
  - Define VM infrastructure as code
  - Define storage volumes
  - Integrate with Ansible for OS provisioning
  - Test create/destroy/rebuild workflows
```

**Timeline**: 6-8 weeks
**Effort**: High (new tool + learning curve)
**Benefit**: Reproducible infrastructure, version control

### 2.2 Container & Orchestration

**Objective**: Containerized application deployment

```yaml
# Goal: Docker + Docker Compose for simple containers
# Optional: Kubernetes for advanced orchestration

Docker Compose (Phase 2a - 4-6 weeks):
  - Deploy monitoring stack (Prometheus, Grafana)
  - Deploy log aggregation (ELK stack)
  - Deploy application containers
  - Auto-start and health checks

Kubernetes (Phase 2b - 8-12 weeks):
  - Deploy k3s lightweight cluster on Proxmox VMs
  - Define application deployments as code
  - Set up ingress controller for services
  - Implement persistent storage
  - CI/CD integration for deployments
```

**Timeline**: 8-16 weeks total
**Effort**: Very High (complex ecosystem)
**Benefit**: Modern application deployment

### 2.3 CI/CD Pipeline Integration

**Objective**: Automate testing and deployment

```yaml
# Goal: GitHub Actions or GitLab CI for automation

Pipeline Stages:
  1. Syntax Check: Ansible playbook validation
  2. Lint: YAML linting, best practices
  3. Security: Vault validation, credential scanning
  4. Integration: Test against lab environment
  5. Deploy: Automatically apply changes if approved

GitHub Actions Example:
  - On git push to main branch
  - Run playbook syntax check
  - Run against non-prod environment (--check)
  - Notify on Slack/email
  - Manual approval for prod deployment

Tasks:
  - Create GitHub Actions workflow
  - Set up testing environment
  - Implement change approval process
  - Document runbook procedures
```

**Timeline**: 3-4 weeks
**Effort**: Medium (requires CI platform knowledge)
**Benefit**: Automated validation and safer deployments

## Phase 3: Long-Term (6+ Months)

### 3.1 Full HA/DR Automation

**Objective**: Automatic failover and disaster recovery

```yaml
# Goal: Detect failures, failover automatically, recover

Implementation:
  - Monitor cluster quorum and node status
  - Automatic VM migration on node failure
  - iSCSI failover between storage backends
  - Firewall failover (CARP - active/passive)
  - Automated backup→restore testing

Tasks:
  - Implement cluster watchdog and fencing
  - Test failover scenarios monthly
  - Document recovery procedures
  - Create runbooks for manual intervention if needed
```

**Timeline**: 8-12 weeks
**Effort**: High (complex failure modes)
**Benefit**: Reduced downtime, automated recovery

### 3.2 Advanced Observability

**Objective**: Comprehensive infrastructure insights

```yaml
# Goal: Logs, metrics, traces, events in single pane

Stack:
  - Prometheus: Metrics collection
  - Loki: Log aggregation
  - Grafana: Visualization dashboard
  - Jaeger: Distributed tracing (for apps)
  - Elasticsearch: Extended search/analytics

Tasks:
  - Deploy observability stack
  - Configure all devices to export metrics
  - Create comprehensive dashboards
  - Set up alert escalation rules
  - Document log analysis procedures
```

**Timeline**: 10-14 weeks
**Effort**: Very High (large deployment)
**Benefit**: Deep infrastructure insights

### 3.3 Multi-Environment Support

**Objective**: Development, staging, production environments

```yaml
# Goal: Replicate across multiple environments

Structure:
  environments/
    dev/          # Development (loose change control)
    staging/      # Pre-production (test changes)
    prod/         # Production (strict change control)

Tasks:
  - Create separate inventory per environment
  - Implement change approval workflow
  - Test changes in staging first
  - Automated promotion to production
  - Separate backups per environment
```

**Timeline**: 6-8 weeks
**Effort**: Medium (process + infrastructure)
**Benefit**: Risk reduction, safer experimentation

## Technology Stack Additions

### Monitoring & Observability
| Tool | Purpose | Timeline | Difficulty |
|------|---------|----------|------------|
| Prometheus | Metrics collection | Phase 1 | Medium |
| Grafana | Visualization | Phase 1 | Low |
| Loki | Log aggregation | Phase 3 | High |
| Elasticsearch | Search/analytics | Phase 3 | High |
| Jaeger | Tracing | Phase 3 | High |

### Infrastructure Management
| Tool | Purpose | Timeline | Difficulty |
|------|---------|----------|------------|
| Terraform | IaC | Phase 2 | High |
| Packer | Image building | Phase 2 | Medium |
| Ansible Tower/AWX | Job orchestration | Phase 2 | Medium |
| Vault (HashiCorp) | Secret management | Phase 2 | Medium |

### Container & Orchestration
| Tool | Purpose | Timeline | Difficulty |
|------|---------|----------|------------|
| Docker Compose | Container orchestration | Phase 2 | Low |
| k3s | Kubernetes distribution | Phase 2 | High |
| Helm | Kubernetes package manager | Phase 3 | Medium |
| ArgoCD | GitOps CD | Phase 3 | Medium |

### CI/CD
| Platform | Use | Timeline | Difficulty |
|----------|-----|----------|------------|
| GitHub Actions | Cloud CI/CD | Phase 2 | Low |
| GitLab CI | On-prem CI/CD | Phase 2 | Medium |
| Jenkins | Advanced orchestration | Phase 2 | High |

## Resource Estimation

### Personnel
- **Phase 1**: 40-60 hours (1-2 weeks part-time)
- **Phase 2**: 150-200 hours (3-4 months part-time)
- **Phase 3**: 200-300 hours (4-6 months part-time)
- **Total**: 400-500 hours (~10-12 months at 8 hrs/week)

### Infrastructure
- **Storage**: +100GB for monitoring/logs per month
- **CPU**: +2 cores for monitoring VMs
- **Memory**: +8GB for monitoring stack
- **Backup**: +500GB for additional backups

### Cost (Rough Estimates - Lab Only)
- **Monitoring Tools**: Free (open-source)
- **Terraform**: Free (open-source)
- **Container Orchestration**: Free (open-source)
- **CI/CD**: Free tier available (GitHub Actions 2000 min/month)
- **Total**: $0-50/month (mostly optional services)

## Success Metrics

### Phase 1
- [ ] Inventory auto-discovery working
- [ ] Monitoring dashboard operational
- [ ] All configs backed up, tested restore

### Phase 2
- [ ] Terraform infrastructure defined
- [ ] Docker Compose stack running
- [ ] CI/CD pipeline passing checks

### Phase 3
- [ ] Automatic failover tested and working
- [ ] Full observability stack operational
- [ ] Multi-environment deployments working

## Dependencies & Prerequisites

### Before Starting
- [ ] Current Ansible playbooks stable and tested
- [ ] All infrastructure fully documented
- [ ] Inventory file standardized
- [ ] Basic networking verified

### External Resources
- [ ] Terraform AWS/Proxmox provider documentation
- [ ] Kubernetes learning resources (k3s docs)
- [ ] ELK stack deployment guide
- [ ] GitHub Actions workflow documentation

## Rollback & Risk Mitigation

### For Each Phase
1. **Test in non-production first**
2. **Document current state before changes**
3. **Implement gradual rollout** (not all devices at once)
4. **Maintain manual procedures** as backup
5. **Train team members** on new tools

### Example Rollback Plan (Phase 2)
- If Terraform destroy fails: Manual SSH to clean up
- If Docker breaks networking: SSH to host, restart containers
- If CI/CD blocks deployments: Manual ansible-playbook execution

## Communication Plan

### Stakeholders
- Self (primary operator)
- Backup operator (if available)
- Incident response team (if applicable)

### Updates
- Monthly progress reviews
- Quarterly roadmap adjustments
- Annual comprehensive review

## Related Documentation

- [IMPROVEMENTS.md](../../IMPROVEMENTS.md) - Prioritized task list
- [README.md](../../README.md) - Project overview
- [SETUP_STATUS.md](../../SETUP_STATUS.md) - Current infrastructure status
