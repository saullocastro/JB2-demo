#!/bin/bash

cd /Users/saullogiovanip/repos/JB2-demo

# Clean and prepare
rm -rf presentations/beamer_build
mkdir -p presentations/beamer_build
cp -r beamer-template/* presentations/beamer_build/

# Generate fragments
echo "=== Generating fragments ==="
for file in content/*.md; do
  base=$(basename "$file" .md)
  python3 filter_content.py beamer "$file" /tmp/$base.md 2>/dev/null
  pandoc --lua-filter=pandoc-filter.lua /tmp/$base.md -t beamer -o presentations/beamer_build/$base.tex 2>/dev/null
  echo "✓ $base.tex ($(wc -l < presentations/beamer_build/$base.tex) lines)"
done

# Create input commands
echo ""
echo "=== Creating input commands ==="
INPUTS=""
for f in presentations/beamer_build/Conclusion.tex presentations/beamer_build/Index.tex presentations/beamer_build/Introduction.tex; do
  if [ -f "$f" ]; then
    INPUTS="$INPUTS\\\\input{$(basename $f)}"$'\n'
  fi
done

echo "Input commands:"
echo "$INPUTS"

# Inject into template  
echo ""
echo "=== Injecting into template ==="
TEMPLATE=presentations/beamer_build/presentation.tex
sed -i.bak "s|% --- CONTENT WILL BE INJECTED HERE ---|${INPUTS%$'\n'}|" "$TEMPLATE"

echo "Template after injection:"
grep -A 5 "input" "$TEMPLATE" || grep -A 5 "CONTENT" "$TEMPLATE"

# Check final template
echo ""
echo "=== Final template structure ==="
wc -l "$TEMPLATE"
echo ""

# Try to compile
echo "=== Attempting compilation ==="
cd presentations/beamer_build
pdflatex -interaction=nonstopmode presentation.tex > /tmp/pdflatex.log 2>&1
if [ -f presentation.pdf ]; then
  echo "✓ PDF generated: $(ls -lh presentation.pdf | awk '{print $5}')"
  file presentation.pdf
else
  echo "✗ PDF generation failed"
  echo "Last 50 lines of log:"
  tail -50 /tmp/pdflatex.log
fi
