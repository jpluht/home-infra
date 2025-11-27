This repository is a personal home-lab infrastructure project focused on secure network automation with Ansible. The goal of these instructions is to help AI coding assistants be immediately productive by pointing out the project's structure, conventions, and practical workflows.

Quick orientation
- Top-level automation lives in `automation/` (Ansible playbooks, `ansible.cfg`, `group_vars`, `inventory`, `playbooks`, `templates`). See `automation/README.md` for more context.
- Public docs live under `docs/` (moved from repo root into `docs/root_docs/` for long-form materials).
- Sensitive, real-world configuration is intentionally stored locally in `.private/` (git-ignored). Examples used by playbooks are under `automation/inventory/hosts.example` and `automation/playbooks/preview-network-vars.yml`.

What to do first (short checklist for the assistant)
- Inspect `README.md` and `automation/README.md` for high-level goals and the public/private split.
- Open `automation/group_vars/core_switches.yml` to see the canonical VLAN and port mapping structure used by switch playbooks.
- Review `.private/vault-config.yml` (local only) when the user instructs you to modify live variables — never commit `.private` files.
- Run or simulate `automation/playbooks/preview-network-vars.yml` to validate variable loading and structure.

Project-specific conventions
- Secrets and site-specific values live in `.private/` (not in git). The repo uses a public/private separation model: public playbooks are generic; `.private/` contains the real inventory and credentials.
- VLAN naming: LOTR-themed names are used in `automation/group_vars/core_switches.yml` and `.private/vault-config.yml` (e.g., Valinor, Rivendell, Moria, Mordor). Use those files as the authoritative mapping between human names and VLAN IDs.
- Ansible patterns: playbooks are structured to include vars from `group_vars` or included local files. The preview playbook demonstrates `include_vars` patterns and writing a JSON dump to `.private/generated/` for inspection.
- Idempotency and non-destructive defaults: many automation tasks are designed to be safe (run with `--check` first). Prefer generating dry-run outputs and test artifacts in `.private/generated/` rather than changing live config without user approval.

Key files to reference in edits and code generation
- `automation/ansible.cfg` — ansible runtime settings used by playbooks.
- `automation/inventory/hosts.example` — example inventory; use it to create `.private/inventory/hosts.yml`.
- `automation/group_vars/core_switches.yml` — VLAN definitions and per-port access mappings; mirror this structure when adding ports or VLANs.
- `automation/playbooks/preview-network-vars.yml` — safe example of loading site vars from `.private/` and exporting JSON; use as a template for variable validation tasks.
- `docs/root_docs/` — contains long-form decision docs, checklists, and the deployment checklist; reference these when making non-trivial architectural changes.

Developer workflows and useful commands
- Populate local private data (example): `cp automation/inventory/hosts.example .private/inventory/hosts.yml` then edit `.private/inventory/hosts.yml`.
- Validate variable loading (safe, local): `ansible-playbook automation/playbooks/preview-network-vars.yml` (this reads `.private/vault-config.yml` and writes `.private/generated/network_vars.json`).
- Typical run pattern for idempotent testing: `ansible-playbook playbooks/opnsense.yml --inventory .private/inventory/hosts.yml --vault-password-file .private/credentials/vault_password.txt --check`

Integration points and external dependencies
- OPNsense GUI/API: playbooks target OPNsense for VLAN, DHCP, DNS, and firewall rules — inspect playbooks before running against the firewall.
- Cisco/Catalyst switches (SSH/NetConf): `automation/playbooks` may contain templates for switch config; map `access_ports` keys in `core_switches.yml` to actual interface names in `.private/inventory/hosts.yml`.
- Local Proxmox and VMs: network bridging and VLAN-aware bridges are managed via playbooks; check `docs/02-initial-setup/proxmox-bootstrap.md` for platform specifics.

Assistant best practices for this repo (do these when making changes)
- Never add or commit `.private/` files. If you must create example data, use `automation/inventory/hosts.example` or `automation/group_vars/*.example.yml`.
- When creating new playbooks, follow the preview pattern: include a dry-run mode, explicit `include_vars` of `.private/` where applicable, and write a generated artifact under `.private/generated/` for the user to inspect before applying changes.
- Use precise edits: mention and update `automation/group_vars/core_switches.yml` when changing VLANs or port mappings, and mirror those changes in any templates under `automation/templates/`.
- Keep doc pointers updated: if you modify architecture or workflows, add a 2–3 line summary into `docs/03-automation/automation-roadmap.md` and update `README.md` if top-level behavior changes.

When uncertain, ask the user for the `.private` details or permission to simulate changes. Provide diff-only patches for review and avoid running playbooks that modify live infrastructure without explicit go-ahead.

If anything here is unclear or you want me to expand a section (examples, commands, or reference files), tell me which area to improve.
