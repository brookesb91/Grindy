Cache = { creatures = {} }

function Cache:Init()
  self.creatures = {}
end

function Cache:Add(key, time)
  local total = self.creatures[key] ~= nil and self.creatures[key].Count + 1 or 1

  self.creatures[key] = {
    Count = total,
    Time = time
  }
end

function Cache:Print()
  for index, val in pairs(self.creatures) do
    Logger:Log(""..val.Count.." - "..index.."")
  end
end