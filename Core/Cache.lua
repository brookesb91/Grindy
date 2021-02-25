Cache = {}

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