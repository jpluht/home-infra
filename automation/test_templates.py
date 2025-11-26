#!/usr/bin/env python3
import yaml
import jinja2
import os

# Load variables from group_vars/opnsense.yml
with open('group_vars/opnsense.yml', 'r') as f:
    variables = yaml.safe_load(f)

# Set up Jinja2 environment
env = jinja2.Environment(loader=jinja2.FileSystemLoader('templates'))

# List of templates to test
templates = [
    'dhcp.xml.j2',
    'dnsbl.xml.j2',
    'nat.xml.j2',
    'ntp.xml.j2',
    'suricata.xml.j2',
    'vlans.xml.j2'
]

# Render each template
for template_name in templates:
    try:
        template = env.get_template(template_name)
        rendered = template.render(**variables)
        print(f"\n=== Rendered {template_name} ===")
        print(rendered)
    except Exception as e:
        print(f"Error rendering {template_name}: {e}")
