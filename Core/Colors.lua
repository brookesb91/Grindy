Colors = {
  green = "FF50FA7B",
  red = "FFFF5555",
  blue = "FF8BE9FD",
  yellow = "FFF1FA8C",
  white = "FFFFFFFF"
}

function Colors:Color(str, color)
  return "|C"..color..""..str..""
end

function Colors:Green(str)
  return self:Color(str, Colors.green)
end

function Colors:Red(str)
  return self:Color(str, Colors.red)
end

function Colors:Blue(str)
  return self:Color(str, Colors.blue)
end

function Colors:Yellow(str)
  return self:Color(str, Colors.yellow)
end

function Colors:White(str)
  return self:Color(str, Colors.white)
end