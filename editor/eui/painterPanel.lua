local suit = require 'suit'

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id={}}
local squre_layer = {data={"terrain","furniture","field","item"},select= 1,opt= {id={}}}

local tile_data = require "data/tilesdata"
local X_num = 7
local Y_num = math.ceil(#tile_data/X_num)
local tiles_info = {w=266 , h= Y_num*38,opt ={id={}},scrollrect_opt={id={},vertical = true}}

local tile_select --选择的index在tile_data中

local function terrain_list(x,y,w,h)
  local opt = tiles_info.opt
  
  suit.ScrollRect(tiles_info,tiles_info.scrollrect_opt,x,y,w,h)
  suit.registerHitbox(opt,opt.id, x,y,w-17,h) -- 底板
  local itemstates ={
		id = opt.id,
		hit = suit.mouseReleasedOn(opt.id),
    active = suit.isActive(opt.id),
		hovered = suit.isHovered(opt.id) and suit.wasHovered(opt.id),
    wasHovered = suit.wasHovered(opt.id)
	}
  for i=1,#tile_data do
    local xoff = i%7*38-38
    local yoff = math.floor(i/7)*38
    local memberState = eui.PicButton(tile_data[i],x+xoff,y+yoff,tile_select ==i)
    if memberState.hit then tile_select = i end
    --suit.mergeState(itemstates,memberState)
  end
  suit.endScissor()
  suit.wheelRoll(itemstates,tiles_info)
end


return function()
  local x,y,w,h = win_width-300,30,300,win_height-30
  eui.Panel(panel_opt,x,y,w,h)

  --suit.ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
  
  terrain_list(x+10,y+60,266,500)
  
  suit.ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
end

