function SlashHandler(arg1)
  if arg1:lower():find("reset") then
    Grindy:Init()
  else
    Grindy:AddMessage("Option not found.")
  end
end

SlashCmdList["GrindyCommand"] = SlashHandler;
SLASH_GrindyCommand1 = "/grindy"