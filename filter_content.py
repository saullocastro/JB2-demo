#!/usr/bin/env python3
"""
Filter content based on format markers.
Usage: python filter_content.py <format> <input_file> <output_file>
Formats: html, pdf, typst, beamer
"""

import sys
import re
from pathlib import Path

def filter_content(content: str, format_target: str) -> str:
    """Remove format-specific containers based on target format.
    
    For blocks that are excluded for a format, remove the entire block including container markers.
    For blocks that are included, remove only the container markers and keep the content.
    """
    
    result = content
    
    # Convert MyST-specific syntax to Pandoc-compatible syntax
    # Convert {numref}`label` to [label] for simple references
    result = re.sub(r'\{numref\}`([^`]+)`', r'[\1]', result)
    
    # Convert MyST figure containers to Pandoc image syntax
    # Handle :::{figure} path ... ::: syntax
    # Extract the figure path and caption, convert to markdown image syntax
    def convert_myst_figure(match):
        figure_block = match.group(0)
        # Extract figure path from the opening line
        # :::{figure} ../figures/diagram.*
        path_match = re.search(r':::\{figure\}\s+([^\n]+)', figure_block)
        if path_match:
            path = path_match.group(1).strip()
        else:
            return ''  # No path found, remove the block
        
        # Extract caption/content (lines between opening and closing markers)
        # that don't start with ':'
        lines = figure_block.split('\n')
        caption_lines = []
        for line in lines[1:]:  # Skip the opening :::{figure} line
            if line.strip().startswith(':'):
                continue  # Skip attribute lines
            if line.strip() == ':::':
                break  # Stop at closing marker
            if line.strip():  # Keep non-empty content lines
                caption_lines.append(line)
        
        caption = ' '.join(caption_lines)
        # Convert to markdown image syntax: ![caption](path)
        return f'![{caption}]({path})'
    
    # Match :::{figure} ... ::: blocks
    result = re.sub(
        r':::\{figure\}[^\n]*\n(?::[^\n]*\n)*(?:^[^\n]*\n)*?^:::\s*$',
        convert_myst_figure,
        result,
        flags=re.MULTILINE | re.DOTALL
    )
    
    # Resolve wildcard patterns in image/figure paths for formats that don't support them
    # Replace .* with .png (most common format) - do this AFTER figure conversion
    result = re.sub(r'\.\*', '.png', result)
    
    # For beamer format, adjust figure paths since they'll be relative to presentations/beamer_build/
    # Change ../figures/ to figures/
    if format_target == 'beamer':
        result = re.sub(r'\.\./figures/', 'figures/', result)
    
    # Define which containers to remove entirely for each format
    # For HTML (website): keep web-only, remove pdf-only and beamer-only
    # For PDF: keep pdf-only, remove web-only and beamer-only
    # For Beamer: keep beamer-only, remove web-only and pdf-only
    remove_entirely = {
        'html': [r'::::{\.pdf-only}.*?::::', r'::::{\.beamer-only}.*?::::'],
        'pdf': [r'::::{\.web-only}.*?::::', r'::::{\.beamer-only}.*?::::'],
        'typst': [r'::::{\.web-only}.*?::::', r'::::{\.beamer-only}.*?::::'],
        'beamer': [r'::::{\.web-only}.*?::::', r'::::{\.pdf-only}.*?::::'],
    }
    
    # Define which containers to unwrap (keep content, remove container markers)
    unwrap_patterns = {
        'html': [r'::::{pdf-only}', r'::::{beamer-only}'],  # These are removed entirely above
        'pdf': [r'::::{web-only}', r'::::{pdf-only}', r'::::{beamer-only}'],
        'typst': [r'::::{web-only}', r'::::{pdf-only}', r'::::{beamer-only}'],
        'beamer': [r'::::{web-only}', r'::::{pdf-only}', r'::::{beamer-only}'],
    }
    
    # Remove citations for typst format (typst doesn't support pandoc citations)
    if format_target == 'typst':
        # Match [@citationkey], {[@citationkey]}, or bare @citationkey
        result = re.sub(r'\[@[\w\-]+\]', '', result)  # [@key]
        result = re.sub(r'\{@[\w\-]+\}', '', result)  # {@key}
        result = re.sub(r'(?<!\[)@[\w\-]+(?!\])', '', result)  # bare @key (avoiding ][)
    
    # Remove entire blocks that shouldn't appear in this format
    for pattern in remove_entirely.get(format_target, []):
        result = re.sub(pattern, '', result, flags=re.DOTALL)
    
    # Remove container markers for blocks that are being kept
    # Remove opening marker: ::::{...}
    result = re.sub(r'::::{[^}]*}', '', result)
    # Remove closing marker: ::::
    result = re.sub(r'^::::\s*$', '', result, flags=re.MULTILINE)
    
    # Clean up extra blank lines
    result = re.sub(r'\n\n\n+', '\n\n', result)
    
    return result

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <format> <input_file> <output_file>")
        print("Formats: html, pdf, typst, beamer")
        sys.exit(1)
    
    format_target = sys.argv[1]
    input_file = sys.argv[2]
    output_file = sys.argv[3]
    
    if format_target not in ['html', 'pdf', 'typst', 'beamer']:
        print(f"Error: Invalid format '{format_target}'")
        sys.exit(1)
    
    try:
        content = Path(input_file).read_text()
        filtered = filter_content(content, format_target)
        Path(output_file).write_text(filtered)
        print(f"✓ Filtered {input_file} for {format_target} format")
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)
