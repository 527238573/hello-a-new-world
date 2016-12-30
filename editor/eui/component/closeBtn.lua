local suit = require 'suit'
local s9util = require("suit/s9util")
local btn_img = love.graphics.newImage("assets/btn_close.png")
local quads = 
{
  normal = s9util.createS9Table(btn_img,0,0,28,20,2,2,2,2),
  hovered= s9util.createS9Table(btn_img,0,20,28,20,2,2,2,2),
  active = s9util.createS9Table(btn_img,0,40,28,20,2,2,2,2)
}

return function(...)
  local opt, x,y = suit.getOptionsAndSize(...)
  return suit.ImageButton(quads,opt, x,y,28,20)
end