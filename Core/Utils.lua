Utils = {}

function Utils:FormatNumber(amount)
  return string.gsub(amount, "^(-?%d+)(%d%d%d)", '%1,%2')
end