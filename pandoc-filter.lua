-- Pandoc Lua filter to handle format-specific content.

function RawBlock(el)
  -- This function ensures that raw LaTeX blocks (assumed to be for Beamer)
  -- are ONLY included in the Beamer output.
  if el.format == "latex" then
    if FORMAT == "beamer" then
      return el -- Keep raw LaTeX for Beamer
    else
      return {} -- Remove from all other formats (Typst, main LaTeX PDF)
    end
  end
  return el
end

function Div(el)
  -- This function filters divs based on their class to show them only in the
  -- intended output format.
  local classes = el.classes
  local is_web_only = classes:includes('web-only')
  local is_pdf_only = classes:includes('pdf-only')
  local is_beamer_only = classes:includes('beamer-only')

  if FORMAT == 'beamer' then
    -- For Beamer, we ONLY want 'beamer-only' divs and normal divs.
    if is_web_only or is_pdf_only then
      return {}
    end
  elseif FORMAT == 'latex' or FORMAT == 'typst' then
    -- For PDF/Typst reports, we ONLY want 'pdf-only' divs and normal divs.
    if is_web_only or is_beamer_only then
      return {}
    end
  end

  -- Note: The HTML build is not affected by this filter.
  -- It renders all divs and their visibility is controlled by CSS.
  return el
end