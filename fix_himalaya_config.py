#!/usr/bin/env python3
# Fix himalaya config to make iih_clawdia the default account

import re

config_path = "/Users/clawdia/.config/himalaya/config.toml"

# Read the config
with open(config_path, 'r') as f:
    content = f.read()

# Remove all default = lines first
content = re.sub(r'\s*default\s*=\s*(true|false)\s*\n', '\n', content)

# Add default = false to zoho account
zoho_section = re.search(r'(\[accounts\.zoho\].*?)(?=\n\[|\Z)', content, re.DOTALL)
if zoho_section:
    zoho_content = zoho_section.group(1)
    zoho_content = re.sub(r'(\[accounts\.zoho\])', r'\1\ndefault = false', zoho_content)
    content = content.replace(zoho_section.group(1), zoho_content)

# Add default = true to iih_clawdia account
iih_section = re.search(r'(\[accounts\.iih_clawdia\].*?)(?=\n\[|\Z)', content, re.DOTALL)
if iih_section:
    iih_content = iih_section.group(1)
    iih_content = re.sub(r'(\[accounts\.iih_clawdia\])', r'\1\ndefault = true', iih_content)
    content = content.replace(iih_section.group(1), iih_content)

# Write back
with open(config_path, 'w') as f:
    f.write(content)

print("✅ Fixed himalaya config:")
print("   - iih_clawdia (clawdia.ai@iih.ng) is now default")
print("   - zoho (temi.kolawole@iih.ng) is not default")