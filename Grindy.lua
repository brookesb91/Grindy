Grindy = CreateFrame("Frame");

function Grindy:Handle(...)
  local message = ...
  local name, key, amount = Info:From(message)

  if amount > 0 then
    Player:Update(amount)

    local time = GetTime()
    local rate = ceil(Player.Total / ((time - Player.StartTime) / 60 / 60))
    local to_level = ceil(Player.ToLevel / amount)

    Rate:Update(rate)

    local time_to_level = string.format("%.2f", Player.ToLevel / rate)
    local time_to_level_str = Utils:FormatNumber(time_to_level)
    local to_level_str = Utils:FormatNumber(to_level)
    local rate_current_str = Utils:FormatNumber(Rate.Current)
    local rate_change_str = Utils:FormatNumber(Rate.Change)
    local rate_change_sign = Rate.Change > 0 and "+" or ""
    local change_color = Rate.Change == 0 and Colors.blue or
      (Rate.Change < 0 and Colors.red or Colors.green)

    Cache:Add(key, time)

    self:AddMessage(""
      ..Colors:Yellow(to_level_str).." "
      ..Colors:White(name).." "
      ..Colors:Blue("to level").." "
      ..Colors:Yellow("(~"..time_to_level_str.."hrs)")..
    "")
    self:AddMessage(
      "Current Rate: "
      ..Colors:Yellow(rate_current_str).." xp/h "
      ..Colors:Color("("..rate_change_sign..""..rate_change_str..")", change_color)..
    "")
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