local suit = require 'suit'
local left_img = love.graphics.newImage("suit/assets/scroll$left.png")
local right_img = love.graphics.newImage("suit/assets/scroll$right.png")
local function create_btn_table(bimg)
  return {
    img = bimg,
    normal = love.graphics.newQuad(0,0,17,17,17,51),
    hovered= love.graphics.newQuad(0,17,17,17,17,51),
    active = love.graphics.newQuad(0,34,17,17,17,51)
  }
end
local left_quads=create_btn_table(left_img)
local right_quads=create_btn_table(right_img)



return function(info,...)
  local opt, x,y = suit.getOptionsAndSize(...)
  opt.id = opt.id or info
  
  info.ns_left_opt = info.ns_left_opt or {id ={}}
  info.ns_right_opt = info.ns_right_opt or {id ={}}
  info.ns_label_opt = info.ns_label_opt or {id ={},color = {66,66,66}}
  
  local s1=suit.ImageButton(left_quads,info.ns_left_opt, x,y,17,22)
  local s2=suit.ImageButton(right_quads,info.ns_right_opt, x+55,y,17,22)
  suit.Label(tostring(info.value),info.ns_label_opt,x+17,y,38,22)
  
  if s1.hit then 
    info.value = c.clamp(info.value -1,info.min,info.max)
  end
  if s2.hit then
    info.value = c.clamp(info.value +1,info.min,info.max)
  end
  return suit.combineState(opt.id,s1,s2)
end