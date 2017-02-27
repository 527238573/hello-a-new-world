local suit = require 'suit'

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id={}}
local squre_layer = {data={"terrain","block","field","item"},select= 1,opt= {id={}}}

local terrain_list = require "eui/painter/terrainList"
local block_list = require "eui/painter/blockList"

return function()
  local x,y,w,h = win_width-300,30,300,win_height-30
  eui.Panel(panel_opt,x,y,w,h)

  --suit.ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
  if squre_layer.select == 1 then
    terrain_list(x+10,y+60,266,500)
  elseif squre_layer.select == 2 then
    block_list(x+10,y+60,266,500)
  end
  
  
  suit.ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
  
  editor.curPainterSelct = squre_layer.select
end

