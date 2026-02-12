-- Pandoc Lua filter to handle format-specific content.
-- Supports filtering for different output formats: HTML, Beamer, LaTeX, and Typst.

function RawBlock(el)
  -- This function ensures that raw LaTeX blocks (assumed to be for Beamer)
  -- are ONLY included in the Beamer output.
  if el.format == "latex" or el.format == "beamer" then
    if FORMAT == "beamer" then
      return el -- Keep raw LaTeX/Beamer for Beamer output
    else
      return {} -- Remove from all other formats (HTML, Typst, main LaTeX PDF)
    end
  end
  return el
end

function Figure(el)
  -- Handle MyST metadata attributes like {no-pdf: true}
  
  -- Check if figure has attributes indicating it should be excluded
  if el.attributes and el.attributes['no-pdf'] then
    -- Exclude from PDF and typst formats
    if FORMAT == 'latex' or FORMAT == 'typst' then
      return {}
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
    -- For Beamer: Only keep beamer-only divs and normal divs
    if is_web_only or is_pdf_only then
      return {}
    end
  elseif FORMAT == 'latex' or FORMAT == 'typst' then
    -- For PDF/Typst reports: Only keep pdf-only divs and normal divs
    if is_web_only or is_beamer_only then
      return {}
    end
  elseif FORMAT == 'html' then
    -- For HTML: Show everything (visibility controlled by CSS if needed)
    -- but you can optionally hide beamer-only here
    if is_beamer_only then
      return {}
    end
  end

  -- Default: keep the div
  return el
end