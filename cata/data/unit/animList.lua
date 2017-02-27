--以name作为id
local list = {}



list[#list+1] = {
  name = "player_mc",
  num = 4,
  width = 32,
  height = 32,
  scalefactor = 2,
  type = "twoSide", -- single oneSide twoSide
  pingpong  = true,
  love.graphics.newImage("data/unit/mc/mc1.png"),
  love.graphics.newImage("data/unit/mc/mc2.png"),
  love.graphics.newImage("data/unit/mc/mc3.png"),
  love.graphics.newImage("data/unit/mc/mc4.png"),
  love.graphics.newImage("data/unit/mc/mc5.png"),
  love.graphics.newImage("data/unit/mc/mc6.png"),
  love.graphics.newImage("data/unit/mc/mc7.png"),
  love.graphics.newImage("data/unit/mc/mc8.png"),
};











return list


