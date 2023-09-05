function Math(elem)
  if elem.mathtype == "DisplayMath" then
    return pandoc.RawBlock('markdown', '```math\n' .. elem.text .. '```\n')
  else
    return elem
  end
end
