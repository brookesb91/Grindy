local Grindy = CreateFrame("Frame");

local Player, Cache, Rate, Info, Colors;

Player = { StartTime = GetTime() }
Info = {}
Cache = {}
Rate = { Change = 0, Current = 0 }

Colors = {
  green = "FF10C15C",
  red = "FFD05353",
  blue = "FF227C9D",
  yellow = "FFFFCB77",
  white = "FFFFFFFF"
}

function Colors:Color(str, color)
  return "|C"..color..""..str..""
end

function Colors:Green(str)
  return self:Color(str, Colors.green)
end

function Colors:Red(str)
  return self:Color(str, Colors.red)
end

function Colors:Blue(str)
  return self:Color(str, Colors.blue)
end

function Colors:Yellow(str)
  return self:Color(str, Colors.yellow)
end

function Colors:White(str)
  return self:Color(str, Colors.white)
end

function Cache:Init()
  self = {}
end

function Cache:Add(key, time)
  local total = self[key] ~= nil and self[key].Count + 1 or 1

  self[key] = {
    Count = total,
    Time = time
  }
end

function Info:From(message)
  local PATTERN_XP_GAINED = "(%d+)"
  local PATTERN_UNIT_NAME = "(.+).dies"

  local amount = tonumber(string.match(message, PATTERN_XP_GAINED))
  local name = string.match(message, PATTERN_UNIT_NAME)
  local key = name:lower():gsub("%s", "_")

  return name, key, amount
end

function Rate:Init()
  self.Change = 0
  self.Current = 0
end

function Rate:Update(rate)
  self.Change = (rate - self.Current)
  self.Current = rate
end

function Player:Init()
  self.StartTime = GetTime()
end

function Player:Update(amount)
  self.Current = UnitXP("player")
  self.Max = UnitXPMax("player")
  self.Latest = amount
  self.Total = self.Total ~= nil and self.Total + amount or amount
  self.ToLevel = self.Max - self.Current
end

local function format_number(amount)
  return string.gsub(amount, "^(-?%d+)(%d%d%d)", '%1,%2')
end

function Grindy:Handle(...)
  local message = ...
  local name, key, amount = Info:From(message)

  if amount > 0 then
    Player:Update(amount)

    local time = GetTime()
    local rate = ceil(Player.Total / ((time - Player.StartTime) / 60 / 60))
    local to_level = ceil(Player.ToLevel / amount)

    Rate:Update(rate)

    local to_level_str = format_number(to_level)
    local rate_current_str = format_number(Rate.Current)
    local rate_change_str = format_number(Rate.Change)
    local change_color = Rate.Change == 0 and Colors.blue or
      (Rate.Change < 0 and Colors.red or Colors.green)

    Cache:Add(key, time)
    self:AddMessage(""..Colors:Yellow(to_level_str).." "..Colors:White(name).." "..Colors:Blue("to level.").."")
    self:AddMessage("Current Rate: "..Colors:Yellow(rate_current_str).." xp/h ("..Colors:Color(rate_change_str, change_color)..")")
  end
end

function Grindy:AddMessage(message)
  DEFAULT_CHAT_FRAME:AddMessage(""..Colors:Blue("[Grindy] ")..""..message.."")
end

function Grindy:Init()
  Cache:Init()
  Player:Init()
  Rate:Init()
  self:AddMessage("Initialised!")
end

function SlashHandler(arg1)
  if arg1:lower():find("reset") then
    Grindy:Init()
  else
    Grindy:AddMessage("Option not found.")
  end
end

SlashCmdList["GrindyCommand"] = SlashHandler;
SLASH_GrindyCommand1 = "/grindy"

Grindy:RegisterEvent("PLAYER_LOGIN")
Grindy:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
Grindy:SetScript("OnEvent",
  function(self, event, ...)
    if event == "CHAT_MSG_COMBAT_XP_GAIN" then
      self:Handle(...)
    end
  end
)

Grindy:Init()