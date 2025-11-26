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

This repository contains no sensitive data, passwords, or production credentials.  
Configuration files include placeholder values or encrypted secrets managed via Ansible Vault.

---

## Getting Started

Please see the [automation/README.md](automation/README.md) for setup instructions on running Ansible playbooks and securely managing secrets.

---

## Contribution & Feedback

This is primarily a personal learning project, but suggestions and improvements are welcome via GitHub issues and pull requests.

---

## Acknowledgments

Inspired by open-source projects and hands-on homelab communities focusing on practical cybersecurity, automation, and modern infrastructure principles.