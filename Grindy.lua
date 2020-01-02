local Grindy = CreateFrame("Frame");
local Player, Cache, Last, Rate;

Grindy:RegisterEvent("PLAYER_LOGIN")
Grindy:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
Grindy:SetScript("OnEvent",
  function(self, event, ...)
    self:SetPlayerXp()
    if event == "CHAT_MSG_COMBAT_XP_GAIN" then
      self:OnXpGain(...)
    end
  end
)

function Grindy:OnXpGain(...)
  local text = ...
  local gained = tonumber(string.match(text, "(%d+)"))
  local enemy = string.match(text, "(.+).dies")
  local formatted = enemy:lower():gsub("%s", "_")

  Player.Latest = gained;
  Player.Session = Player.Session + gained;

  if (gained > 0) then
    local toLevel = ceil((Player.Max - Player.Current) / gained)
    self:AddMessage(
      self:GetDiffString(gained, Player.Latest).." |C0000FFFF"
      ..toLevel.." |C007FBA32more |C00FFFFFF"..enemy.." |C007FBA32to level."
    )
  end

  if Cache[formatted] then
    Cache[formatted] = {
      Yield = gained,
      Count = Cache[formatted].Count + 1,
      Time = GetTime()
    }
  else
    Cache[formatted] = {
      Yield = gained,
      Count = 1,
      Time = GetTime()
    }
  end

  if Last then
    local current = Cache[formatted]
    local rate = ceil(current.Yield / ((current.Time - Last.Time) / 60 / 60))
    Grindy:AddMessage(
      "|C00FFFFFF[Rate] "
      ..self:GetDiffString(rate, Rate)..
      " |C0000FFFF"..string.gsub(rate, "^(-?%d+)(%d%d%d)", '%1,%2')..
      "|C00FFFFFF XP/h"
    )

    Rate = rate;
  end

  Last = Cache[formatted]
end

function Grindy:SetPlayerXp()
  Player.Current = UnitXP("player")
  Player.Max = UnitXPMax("player")
end

function Grindy:GetDiffString(amount, compare)
  local diff;
  if amount > compare then
    diff = "|C0000FF00[+]"
  elseif amount < compare then
    diff = "|C00FF0000[-]"
  else
    diff = "|C00FF00FF[~]"
  end
  return diff;
end


function SlashHandler(arg1)
  if arg1:lower():find("reset") then
    Grindy:Init()
    Grindy:AddMessage("|C007FBA32Successfully reset.")
  else
    Grindy:AddMessage("|C00FFFFFFOption not found.")
  end
end

function Grindy:AddMessage(message)
  local intro = "|C00C0FFEEGrindy:";
  DEFAULT_CHAT_FRAME:AddMessage(""..intro.." "..message.."")
end

function Grindy:Init()
  Cache = {}
  Rate = 0
  Player = {Current = 0, Max = 0, Latest = 0, Session = 0}
  Last =  {Yield = 0, Time = GetTime()}
end

SlashCmdList["GrindyCommand"] = SlashHandler;
SLASH_GrindyCommand1 = "/grindy"

Grindy:Init()
Grindy:AddMessage("|CFF7FBA32Loaded!")