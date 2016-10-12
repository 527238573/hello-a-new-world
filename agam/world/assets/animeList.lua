
animeLists = {}

local list

list =
{
  love.graphics.newImage("assets/mc1.png"),
  love.graphics.newImage("assets/mc2.png"),
  love.graphics.newImage("assets/mc3.png"),
  love.graphics.newImage("assets/mc4.png"),
  width = 64,
  height = 64,
  pingpong  = true
}
list.len = #list
animeLists["player"] = list



list =
{
  love.graphics.newImage("assets/zb1-1.png"),
  love.graphics.newImage("assets/zb1-2.png"),
  love.graphics.newImage("assets/zb1-3.png"),
  love.graphics.newImage("assets/zb1-4.png"),
  width = 64,
  height = 64,
  pingpong  = true
}
list.len = #list
animeLists["zb1"] = list