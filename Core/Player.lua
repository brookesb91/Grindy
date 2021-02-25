Player = { StartTime = GetTime() }

function Player:Init()
  self.StartTime = GetTime()
  self.Latest = 0
  self.Total = 0
end

function Player:Update(amount)
  self.Current = UnitXP("player")
  self.Max = UnitXPMax("player")
  self.Latest = amount
  self.Total = self.Total ~= nil and self.Total + amount or amount
  self.ToLevel = self.Max - self.Current
end