Rate = { Change = 0, Current = 0 }

function Rate:Init()
  self.Change = 0
  self.Current = 0
end

function Rate:Update(rate)
  self.Change = (rate - self.Current)
  self.Current = rate
end