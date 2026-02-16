#!/usr/bin/env python3
r"""
Inject input commands into LaTeX template.

Usage: inject_template.py <template_file> <output_file> <fragment1> [fragment2] ...
"""

import sys
import os

def inject_fragments(template_file, output_file, fragments):
    r"""Inject \input{} commands into template at placeholder."""
    
    # Read template
    with open(template_file, 'r') as f:
        content = f.read()
    
    # Generate input commands
    input_commands = []
    for frag in fragments:
        basename = os.path.basename(frag)
        input_commands.append(f"\\input{{{basename}}}")
    
    # Join with newlines
    input_section = '\n'.join(input_commands)
    
    # Replace placeholder
    placeholder = "% --- CONTENT WILL BE INJECTED HERE ---"
    if placeholder in content:
        content = content.replace(placeholder, input_section)
    else:
        print(f"WARNING: Placeholder '{placeholder}' not found in {template_file}", file=sys.stderr)
        # Try to append before \end{document}
        content = content.replace("\\end{document}", f"{input_section}\n\n\\end{document}")
    
    # Write output
    with open(output_file, 'w') as f:
        f.write(content)
    
    print(f"✓ Injected {len(fragments)} fragments into {os.path.basename(output_file)}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: inject_template.py <template> <output> <fragment1> [fragment2] ...", file=sys.stderr)
        sys.exit(1)
    
    template = sys.argv[1]
    output = sys.argv[2]
    fragments = sys.argv[3:]
    
    inject_fragments(template, output, fragments)
