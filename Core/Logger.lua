Logger = {}

function Logger:Log(message)
  DEFAULT_CHAT_FRAME:AddMessage(""
    ..Colors:Blue("[Grindy] ")..""..message..
  "")
end