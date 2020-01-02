local Grindy, Store

local Actions = {
  Types = {
    Init = "INIT",
    RegisterEvent = "REGISTER_EVENT",
    RecordExperience = "RECORD_EXPERIENCE",
    AddMessage = "ADD_MESSAGE"
  }
}

function Store:Reduce(state, action, ...)
  if action == Actions.Types.Init then
    -- Initialise
    return Actions:Init(state, ...)
  elseif action == Actions.Types.RecordExperience then
    -- Record Player XP
    return Actions:RecordExperience(state, ...)
  elseif action == Actions.Types.AddMessage then
    -- Post message
    return Actions:AddMessage(state, ...)
  end
end

function Store:Dispatch(action, ...)
  Grindy = self:Reduce(Grindy, action, ...)
end

function Actions:Init(state, ...)
  return {
    Player = {
      CurrentXp = 0,
      MaxXp = 0
    },
    Session = {
      Total = 0,
      Latest = 0
    },
    Rate = 0
  }
end

function Actions:RecordExperience(state, ...)

end

function Actions:AddMessage(state, ...)

end