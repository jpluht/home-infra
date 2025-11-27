# Home Lab Infrastructure

This personal home lab project aims to document and learn the full process of building, securing, and automating a home network infrastructure — from physical hardware setup to Infrastructure as Code using Ansible.

---

## Project Goals

- **Hands-on learning and documentation**: Gain practical skills by designing, building, and automating the home network infrastructure step-by-step.
- **Professional skill showcase**: Create a portfolio-quality project demonstrating expertise in IT support, cybersecurity, network automation, and system engineering.
- **Security-first mindset**: Emphasize network segmentation, firewall hardening, intrusion detection/prevention, and secure automation practices for a robust environment.
- **Hybrid personal cloud**: Build a private “cloud-like” setup for local VMs and services accessible securely from anywhere, minimizing dependence on public cloud platforms.
- **Scalable, production-ready foundation**: Develop reliable automation that can evolve towards production use as your skills mature.
- **Budget-conscious design**: Use cost-effective hardware and open-source software, keeping expenses reasonable (~700 € so far).

---

## How This Guides the Project Structure

- The repository covers everything from **physical hardware documentation and network topology**, through **security policies**, to **automation with Ansible and Infrastructure as Code principles**.
- The `automation/` directory contains reusable and extensible Ansible playbooks and templates, focusing on secure network services management.
- Documentation (in `docs/`) details decisions, setup guides, and security best practices, with awareness of GDPR and NIS2 where applicable.
- The initial focus is on security and automation, with room to expand into cloud and container technologies as you gain experience.

---

## Repository Structure Overview

`
.
├── README.md
├── automation
│   ├── README.md
│   ├── ansible.cfg
│   ├── dhs-test-output.xml
│   ├── group_vars
│   ├── inventory
│   ├── playbooks
│   ├── templates
│   ├── test_templates.py
│   └── venv310
├── diagrams
├── dir_maker.sh
├── docs
│   ├── 01-hardware
│   ├── 02-initial-setup
│   ├── 03-automation
│   └── 04-security
├── requirements.txt
├── requirements.yml
└── structure.txt

13 directories, 9 files
`
---

## Security & Privacy Notice

**This public repository contains no sensitive data, passwords, or production credentials.**

- Configuration files include **placeholder values** only
- Encrypted secrets managed via **Ansible Vault** (vault password never committed)
- **Actual infrastructure details stored locally** in `.private/` directory (git-ignored)

### 🔐 Private Infrastructure Information

This project uses a **public/private separation model** for GitHub-ready documentation:

**📖 Public (in Git):**
- Generic playbooks with example variables
- Security policies and best practices
- Documentation templates
- Installation guides

**🔒 Private (local only, git-ignored):**
- Actual device IPs and credentials
- Real VLAN names and assignments
- Network topology specifics
- Firewall rules for your setup

**How to use this:**

1. **Clone this repo** (public content only)
   ```bash
   git clone https://github.com/your-username/home-infra.git
   cd home-infra
   ```

2. **Create private directory** (local storage)
   ```bash
   mkdir -p .private/{inventory,network,credentials,security}
   ```

3. **Populate with your infrastructure** (never committed)
   ```bash
   # Copy example inventory and customize with your IPs
   cp automation/inventory/hosts.example .private/inventory/hosts.yml
   # Edit with your actual infrastructure details
   ```

4. **Run Ansible against your infrastructure**
   ```bash
   ansible-playbook playbooks/opnsense.yml \
     --inventory .private/inventory/hosts.yml \
     --vault-password-file .private/credentials/vault_password.txt \
     --check
   ```

See **[`.private/README.md`](.private/README.md)** for complete setup and usage guide.

---

## Getting Started

1. **For active Ansible automation**: See [automation/README.md](automation/README.md) — this is the core of the project
2. **For reference documentation**: See [docs/](docs/) for hardware guides, setup procedures, security policies, and automation concepts
3. **For setting up on your infrastructure**: Follow the workflow in [`.private/README.md`](.private/README.md)
4. **For managing secrets securely**: Reference guides moved to `.private/old/docs_root_docs/` (includes deployment checklists, setup guides, OPSEC policy)

---

## Repository Philosophy

- **`automation/`** — Live, active Ansible code (playbooks, templates, group_vars, inventory structure)
- **`docs/`** — Reference documentation (hardware, setup, security, automation concepts)
- **`.private/`** — Your local infrastructure (git-ignored; never committed)
- **`.private/old/`** — Historical/reference files (archived for future reference)

---

## Contribution & Feedback

This is primarily a personal learning project, but suggestions and improvements are welcome via GitHub issues and pull requests.

---

## Acknowledgments

Inspired by open-source projects and hands-on homelab communities focusing on practical cybersecurity, automation, and modern infrastructure principles.