Info = {}

function Info:From(message)
  local PATTERN_XP_GAINED = "(%d+)"
  local PATTERN_UNIT_NAME = "(.+).dies"

  local amount = tonumber(string.match(message, PATTERN_XP_GAINED))
  local name = string.match(message, PATTERN_UNIT_NAME)
  local key = name:lower():gsub("%s", "_")

  return name, key, amount
end