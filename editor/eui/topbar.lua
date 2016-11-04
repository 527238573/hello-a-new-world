local suit = require 'suit'
local s9util = require("suit/s9util")
local back_img = love.graphics.newImage("assets/greybar.png")
local back_s9t = s9util.createS9Table(back_img,0,0,96,27,3,3,3,3)

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id={}}
local btn1_opt = {id={}}
local btn2_opt = {id={}}
local btn3_opt = {id={}}
return function()
  local x,y,w,h = 0,0,win_width,30
  suit.Image(back_s9t,panel_opt,x,y,w,h)
  --eui.Panel(panel_opt,x,y,w,h)
  suit.S9Button("turn<",btn1_opt,800,2,80,26)
  suit.S9Button("turn>",btn2_opt,880,2,80,26)
  suit.S9Button("reset",btn3_opt,960,2,80,26)
end
