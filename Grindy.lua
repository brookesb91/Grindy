Grindy = CreateFrame("Frame");

local session = {
  experience = { total = 0, rate = 0 },
  start = GetTime(),
}

local logger = {
  log = function(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF8BE9FD[Grindy]: " .. message .. "|r")
  end
}

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
  local xp_to_level = xp_max - xp_current
  -- Amount of [thing] required to level.
  local things_to_level = ceil(xp_to_level / amount)

  -- Increment session experience.
  session.experience.total = session.experience.total + amount

  -- Experience earned per second & hour this session.
  local xp_per_second = session.experience.total / delta
  local xp_per_hour = ceil(xp_per_second * 3600)
  -- Change in experience rate.
  local rate_change = (xp_per_hour - session.experience.rate)

  -- Time to next level.
  local seconds_to_level = ceil(xp_to_level / xp_per_second)
  local minutes_to_level = ceil(seconds_to_level / 60)

  -- Update session rate.
  session.experience.rate = xp_per_hour

  local output_time = string.format(
    "~%d %s to level (~%d mins)",
    things_to_level,
    thing,
    minutes_to_level
  )

  local output_rate = string.format(
    "~%d xp/hour (%s%d)",
    xp_per_hour,
    rate_change > 0 and "+" or "",
    rate_change
  )

  local output_rate_color = rate_change >= 0 and "FF50FA7B" or "FFFF5555"

  logger.log(output_time)
  logger.log("|C" .. (output_rate_color) .. output_rate .. "|r")
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
    logger.log("Session was reset.")
  else
    logger.log("Command not recognised.")
  end
end

SlashCmdList["GrindyCommand"] =
    SlashHandler;
SLASH_GrindyCommand1 = "/grindy"

logger.log("Ready!")
