#!/bin/bash
# Repository Sanitization Script
# Replaces real VLAN names and IP addresses with generic placeholders

set -e

echo "🔒 Starting repository sanitization..."

# Backup original files
echo "📦 Creating backup..."
tar -czf repo_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
  docs/ automation/ TODO.md SETUP_GUIDE.md .github/ 2>/dev/null || true

# Files to sanitize (excluding .private/ directory)
FILES=$(find docs automation TODO.md SETUP_GUIDE.md .github -type f \
  \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) \
  2>/dev/null || true)

echo "📝 Sanitizing files..."

for file in $FILES; do
  if [ -f "$file" ]; then
    echo "  Processing: $file"
    
    # Replace VLAN names (Tolkien → Generic)
    sed -i '' 's/Valinor/MGMT_VLAN/g' "$file"
    sed -i '' 's/Rivendell/INFRA_VLAN/g' "$file"
    sed -i '' 's/Bree/USER_VLAN/g' "$file"
    sed -i '' 's/Moria/VM_VLAN/g' "$file"
    sed -i '' 's/Barad-dur/CAMERA_VLAN/g' "$file"
    sed -i '' 's/Mordor/IOT_VLAN/g' "$file"
    sed -i '' 's/Fellowship/INFRA_VLAN/g' "$file"
    
    # Replace IP addresses (192.168.x.x → 10.0.x.x)
    sed -i '' 's/192\.168\.10\./10.0.10./g' "$file"
    sed -i '' 's/192\.168\.20\./10.0.20./g' "$file"
    sed -i '' 's/192\.168\.30\./10.0.30./g' "$file"
    sed -i '' 's/192\.168\.40\./10.0.40./g' "$file"
    sed -i '' 's/192\.168\.41\./10.0.41./g' "$file"
    sed -i '' 's/192\.168\.50\./10.0.50./g' "$file"
    sed -i '' 's/192\.168\.60\./10.0.60./g' "$file"
    
    # Replace generic 192.168 references
    sed -i '' 's/192\.168\.0\.0\/16/10.0.0.0\/16/g' "$file"
  fi
done

echo "✅ Sanitization complete!"
echo ""
echo "📊 Summary:"
echo "  - VLAN names: Tolkien themes → Generic (MGMT_VLAN, INFRA_VLAN, etc.)"
echo "  - IP addresses: 192.168.x.x → 10.0.x.x"
echo "  - .private/ directory: UNTOUCHED (your real config safe)"
echo ""
echo "⚠️  Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test that nothing broke"
echo "  3. Commit: git add -A && git commit -m 'Security: Sanitize public documentation'"
echo "  4. Force push to rewrite history (if needed)"
