local suit = require 'suit'
local s9util = require("suit/s9util")
local btn_img = love.graphics.newImage("suit/assets/button.png")
local quads = 
{
  normal = s9util.createS9Table(btn_img,0,0,75,23,3,3,3,3),
  hovered= s9util.createS9Table(btn_img,0,23,75,23,3,3,3,3),
  active = s9util.createS9Table(btn_img,0,46,75,23,3,3,3,3)
}

local function defaultDraw(info, opt, x,y,w,h,selected,theme)
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal

  if opstate == "active" then 
    love.graphics.setColor(255,127,39)
  elseif selected then 
    love.graphics.setColor(225,107,29)
  else
    love.graphics.setColor(255,255,255)
  end
  theme.drawS9Border(s9t,x,y,w,h)
  love.graphics.setColor(255,255,255)

  if info.quad then 
    local f1,f2,imgw,imgh = info.quad:getViewport()
    local sx = 32/imgw
    local sy = 32/imgh
    love.graphics.draw(info.img,info.quad,x+3,y+3,0,sx,sy)
  else
    local sx = 32/info.img:getWidth()
    local sy = 32/info.img:getHeight()
    love.graphics.draw(info.img,x+3,y+3,0,sx,sy)
  end
end


return function (info,...)
  local opt, x,y,selected= suit.getOptionsAndSize(...)
  opt.id = opt.id or info
  local w,h = 38,38

  opt.state = suit.registerHitbox(opt,opt.id, x,y,w,h)
  suit.registerDraw(defaultDraw, info, opt, x,y,w,h, selected,suit.theme)
  return {
    id = opt.id,
    hit = suit.mouseReleasedOn(opt.id),
    active = suit.isActive(opt.id),
    hovered = suit.isHovered(opt.id) and suit.wasHovered(opt.id),
    wasHovered = suit.wasHovered(opt.id)
  }

end