-- Pandoc Lua filter to remove raw LaTeX blocks when the output format is not LaTeX.

function RawBlock(el)
  if FORMAT ~= "latex" and FORMAT ~= "beamer" then
    return {} -- Return an empty list of elements, effectively removing the block
  end
  -- For all other formats, or if the format is latex or beamer, keep the block
  return el
end
