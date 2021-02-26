function SlashHandler(arg1)
  if arg1:lower():find("reset") then
    Grindy:Init()
  elseif arg1:lower():find("list") then
    Cache:Print()
  else
    Logger:Log("Option not found.")
  end
end

SlashCmdList["GrindyCommand"] = SlashHandler;
SLASH_GrindyCommand1 = "/grindy"