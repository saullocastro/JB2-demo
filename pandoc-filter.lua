-- Pandoc Lua filter to handle format-specific content.

-- This filter processes two types of elements:
-- 1. RawBlock: It ensures that raw LaTeX blocks are ONLY included in Beamer output.
-- 2. Div: It removes divs with the class 'pdf-only' from Beamer output.

function RawBlock(el)
  if el.format == "latex" then
    if FORMAT == "beamer" then
      return el -- Keep raw LaTeX for Beamer output
    else
      return {} -- Remove raw LaTeX from all other formats
    end
  end
  return el -- Keep other raw blocks (e.g., raw html)
end

function Div(el)
  if el.classes:includes('pdf-only') then
    if FORMAT == 'beamer' then
      return {} -- Remove the 'pdf-only' div from Beamer output
    end
  end
  return el
end
