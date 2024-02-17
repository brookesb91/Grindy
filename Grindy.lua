---@class Frame
Grindy = CreateFrame("Frame");

local session = {
  experience = {
    total = 0,
    rate = 0
  },
  start = GetTime(),
}

--- Log a message to the chat frame.
--- @param message string The message to log.
local log = function(message)
  DEFAULT_CHAT_FRAME:AddMessage("|cFF8BE9FDGrindy: " .. message .. "|r")
end

--- Format a number with commas.
--- @param value string|number The value to format.
local format_number = function(value)
  return string.gsub(value, "^(-?%d+)(%d%d%d)", '%1,%2')
end


--- Reset the session.
function Grindy:Reset()
  session.start = GetTime()
  session.experience.total = 0
  session.experience.rate = 0
end

--- Track experience gained.
--- @param thing string The thing that rewarded the experience.
--- @param amount integer The amount of experience rewarded.
function Grindy:TrackExperience(thing, amount)
  -- Current time.
  local now = GetTime()
  -- Time since session started.
  local delta = now - session.start
  -- Player's current experience.
  local xp_current = UnitXP("player")
  -- Player's maximum experience.
  local xp_max = UnitXPMax("player")
  -- Experience required to level.
  -- Amount has not yet been subtracted so must be done manually.
  local xp_to_level = (xp_max - xp_current - amount)
  -- Amount of [thing] required to level.
  local things_to_level = ceil(xp_to_level / amount)

  -- Increment session experience.
  session.experience.total = session.experience.total + amount

  -- Experience earned per second & hour this session.
  local xp_per_second = session.experience.total / delta
  local xp_per_hour = ceil(xp_per_second * 3600)
  -- Change in experience rate.
  local rate_change = ceil(xp_per_hour - session.experience.rate)

  -- Time to next level.
  local seconds_to_level = ceil(xp_to_level / xp_per_second)
  local minutes_to_level = ceil(seconds_to_level / 60)

  -- Update session rate.
  session.experience.rate = xp_per_hour

  local output_time = string.format(
    "~%s %s to level (~%s mins)",
    format_number(things_to_level),
    thing,
    format_number(minutes_to_level)
  )

  local output_rate = string.format(
    "~%s xp/hour (%s%s)",
    format_number(xp_per_hour),
    rate_change > 0 and "+" or "",
    format_number(rate_change)
  )

  local output_rate_color = rate_change >= 0 and "FF50FA7B" or "FFFF5555"

  log(output_time)
  log("|c" .. (output_rate_color) .. output_rate .. "|r")
end

Grindy:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

Grindy:SetScript("OnEvent",
  function(self, event, ...)
    if event == "CHAT_MSG_COMBAT_XP_GAIN" then
      local message = ...
      -- This is not suitable for all languages.
      -- The thing that rewarded the experience.
      local thing = string.match(message, "(.+).dies") or "Quest"
      -- The amount of experience rewarded.
      local amount = tonumber(string.match(message, "(%d+).experience"))

      self:TrackExperience(thing, amount)
    end
  end
)

--- Handle slash commands.
--- @param arg1 string
function SlashHandler(arg1)
  local command = arg1:lower()

  if command:find("reset") then
    Grindy:Reset()
    log("Session was reset.")
  else
    log("Command not recognised.")
  end
end

SlashCmdList["GrindyCommand"] =
    SlashHandler;
SLASH_GrindyCommand1 = "/grindy"

log("Ready!")
