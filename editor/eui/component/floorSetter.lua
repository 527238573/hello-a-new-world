local suit = require 'suit'
local up_img = love.graphics.newImage("suit/assets/scroll$up.png")
local down_img = love.graphics.newImage("suit/assets/scroll$down.png")
local function create_btn_table(bimg)
  return {
    img = bimg,
    normal = love.graphics.newQuad(0,0,17,17,17,51),
    hovered= love.graphics.newQuad(0,17,17,17,17,51),
    active = love.graphics.newQuad(0,34,17,17,17,51)
  }
end

local up_quads=create_btn_table(up_img)
local down_quads=create_btn_table(down_img)
local back_img = love.graphics.newImage("suit/assets/textback.png")
local up_opt = {id ={}}
local down_opt = {id ={}}
local label_opt = {color={33,33,33},block = true,id={},font = c.btn_font,}
return function(x,y)
  
  --local s3 = suit.Image(back_img,x-2,y-2,100,26)
  local s3= suit.Label("floor:"..editor.curZ,label_opt,x-2,y-2,118,26)
  local s1=suit.ImageButton(up_quads,up_opt, x,y,22,22)
  local s2=suit.ImageButton(down_quads,down_opt, x+92,y,22,22)
  
  if s1.hit then 
    editor.changeLayer(editor.curZ +1)
  end
  if s2.hit then 
    editor.changeLayer(editor.curZ -1)
  end
  local state = suit.combineState(nil,s1,s2,s3)
  if state.hovered and state.wasHovered then
    local dy  = suit.getWheelNumber()
    editor.changeLayer(editor.curZ +dy)
  end
  
end