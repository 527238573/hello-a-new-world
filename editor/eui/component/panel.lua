local suit = require 'suit'
local s9util = require("suit/s9util")
local back_img = love.graphics.newImage("assets/border.png")
local back_s9t = s9util.createS9Table(back_img,0,0,50,14,3,3,3,3)


return function(...)
  return suit.Image(back_s9t,...)
end