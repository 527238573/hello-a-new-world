local suit = require 'suit'

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id={}}
local squre_layer = {data={"terrain","furniture","field","item"},select= 1,opt= {id={}}}

local function terrain_list(x,y,w,h)
  
  
end


return function()
  local x,y,w,h = win_width-300,30,300,win_height-30
  eui.Panel(panel_opt,x,y,w,h)

  suit.ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
end

