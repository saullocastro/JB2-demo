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
    """Remove format-specific containers based on target format."""
    
    # Define which containers to remove for each format
    exclude_patterns = {
        'html': [r'::::{pdf-only}.*?::::', r'::::{beamer-only}.*?::::'],
        'pdf': [r'::::{web-only}.*?::::', r'::::{beamer-only}.*?::::'],
        'typst': [r'::::{web-only}.*?::::', r'::::{beamer-only}.*?::::'],
        'beamer': [r'::::{web-only}.*?::::', r'::::{pdf-only}.*?::::'],
    }
    
    result = content
    
    # Remove excluded patterns with DOTALL flag to match across newlines
    for pattern in exclude_patterns.get(format_target, []):
        result = re.sub(pattern, '', result, flags=re.DOTALL)
    
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
