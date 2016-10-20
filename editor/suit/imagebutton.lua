-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

-- 可兼容  image 或quad
local function defaultDraw(opt,quads,x,y,scalex,scaley)
  local todraw = quads.normal
  if opt.state == "active" then
    todraw = quads.active
  elseif opt.state == "hovered" then
    todraw = quads.hovered
  end
  love.graphics.setColor(255,255,255)
  if todraw:typeOf("Image")  then 
    love.graphics.draw(todraw,x,y,0,scalex,scaley)
  else
    love.graphics.draw(quads.img,todraw,x,y,0,scalex,scaley)
  end

end


return function(core, quads, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  quads.normal = quads.normal or quads[1]
  quads.hovered = quads.hovered or quads[2] or quads.normal
  quads.active = quads.active or quads[3] or quads.hovered
  opt.id = opt.id or quads
  assert(quads.normal, "Need at least `normal' state image")

  local f1,f2,imgw,imgh

  if quads.normal:typeOf("Image")  then 
    imgw = quads.normal:getWidth()
    imgh = quads.normal:getHeight()
  else
    f1,f2,imgw,imgh = quads.normal:getViewport()
  end
  w = w or imgw
  h = h or imgh


  opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  core:registerDraw(opt.draw or defaultDraw, opt, quads,x,y,w/imgw,h/imgh)

  return {
    id = opt.id,
    hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
    hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
  }
end
