---@class Frame
Grindy = CreateFrame("Frame");

local session = {
  experience = {
    total = 0,
    rate = 0
  },
  start = GetTime(),
  things = {}
}

local patterns = {
  quest = "You gain (%d+) experience.",
  kill = "(.+) dies, you gain (%d+) experience."
}

--- Log a message to the chat frame.
--- @param message string The message to log.
local log = function(message)
  DEFAULT_CHAT_FRAME:AddMessage("|cFF8BE9FD[Grindy] " .. message .. "|r")
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
    "≈%s %s to level — ≈%s mins",
    format_number(things_to_level),
    thing,
    format_number(minutes_to_level)
  )

  local output_rate = string.format(
    "≈%s XP per hour — %s%s",
    format_number(xp_per_hour),
    rate_change > 0 and "↑" or "↓",
    format_number(rate_change)
  )

  local output_rate_color = rate_change >= 0 and "FF50FA7B" or "FFFF5555"

  log(output_time)
  log("|c" .. (output_rate_color) .. output_rate .. "|r")

  if not session.things[thing] then
    session.things[thing] = {
      total = {
        count = 0,
        experience = 0
      },
      average = 0
    }
  end

  session.things[thing].total.count = session.things[thing].total.count + 1
  session.things[thing].total.experience = session.things[thing].total.experience + amount
  session.things[thing].average = ceil(session.things[thing].total.experience / session.things[thing].total.count)
end

Grindy:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

Grindy:SetScript("OnEvent",
  function(self, event, ...)
    if event == "CHAT_MSG_COMBAT_XP_GAIN" then
      local message = ...
      local thing, amount = message:match(patterns.kill)

      if thing and amount then
        self:TrackExperience(thing, tonumber(amount))
        return
      end

      amount = message:lower():match(patterns.quest)
      if amount then
        self:TrackExperience("Quest", tonumber(amount))
        return
      end
    end
  end
)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  local name = UnitName("mouseover")
  if not name then return end
  if session.things[name] then
    local average = session.things[name].average
    local total = session.things[name].total.experience
    local count = session.things[name].total.count

    self:AddDoubleLine("|cFFFFFFFFAverage XP", format_number(average))
    self:AddDoubleLine("|cFFFFFFFFSession Total XP", format_number(total))
    self:AddDoubleLine("|cFFFFFFFFSession Total", format_number(count))
    self:AddDoubleLine("|cFFFFFFFFTo Next Level", format_number(ceil((UnitXPMax("player") - UnitXP("player")) / average)))
  end
end)

--- Handle slash commands.
--- @param arg1 string
function SlashHandler(arg1)
  local command = arg1:lower()

  if command:find("reset") then
    Grindy:Reset()
    log("Session was reset.")
  elseif command:find("status") then
    local now = GetTime()
    local delta = now - session.start
    log(string.format(
      "Session Time: %s mins, Total XP: %s, XP per hour: ≈%s",
      format_number(ceil(delta / 60)),
      format_number(session.experience.total),
      format_number(session.experience.rate)
    ))
  else
    log("Command not recognised.")
  end
end

SlashCmdList["GrindyCommand"] = SlashHandler
SLASH_GrindyCommand1 = "/grindy"

log("Ready!")
