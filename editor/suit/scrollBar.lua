local BASE = (...):match('(.-)[^%.]+$')


local up_img = love.graphics.newImage("suit/assets/scroll$up.png")
local down_img = love.graphics.newImage("suit/assets/scroll$down.png")
local left_img = love.graphics.newImage("suit/assets/scroll$left.png")
local right_img = love.graphics.newImage("suit/assets/scroll$right.png")

local vbar_img = love.graphics.newImage("suit/assets/vscroll$bar.png")
local vback_img = love.graphics.newImage("suit/assets/vscroll.png")
local hbar_img = love.graphics.newImage("suit/assets/hscroll$bar.png")
local hback_img = love.graphics.newImage("suit/assets/hscroll.png")

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
local left_quads=create_btn_table(left_img)
local right_quads=create_btn_table(right_img)
local vbar_quads=
{
  img = vbar_img,
  normal = love.graphics.newQuad(0,0,17,21,17,63),
  hovered= love.graphics.newQuad(0,21,17,21,17,63),
  active = love.graphics.newQuad(0,42,17,21,17,63)
}
local hbar_quads=
{
  img = hbar_img,
  normal = love.graphics.newQuad(0,0,21,17,21,51),
  hovered= love.graphics.newQuad(0,17,21,17,21,51),
  active = love.graphics.newQuad(0,34,21,17,21,51)
}


local function defaultDraw(fraction, opt, x,y,w,h,theme)
  local xb, yb, wb, hb -- size of the progress bar
  local r =  math.min(w,h) / 2.1
  if opt.vertical then
    x, w = x + w*.25, w*.5
    xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
  else
    y, h = y + h*.25, h*.5
    xb, yb, wb, hb = x,y, w*fraction, h
  end

  local c = theme.getColorForState(opt)
  theme.drawBox(x,y,w,h, c, opt.cornerRadius)
  theme.drawBox(xb,yb,wb,hb, {bg=c.fg}, opt.cornerRadius)

  if opt.state ~= nil and opt.state ~= "normal" then
    love.graphics.setColor((opt.color and opt.color.active or {}).fg or theme.color.active.fg)
    if opt.vertical then
      love.graphics.circle('fill', x+wb/2, yb, r)
    else
      love.graphics.circle('fill', x+wb, yb+hb/2, r)
    end
  end
end

return function(core, info, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info


  info.min = info.min or math.min(info.value, 0)
  info.max = info.max or math.max(info.value, 1)
  info.step = info.step or (info.max - info.min) / 10
  local fraction = (info.value - info.min) / (info.max - info.min)
  local value_changed = false

  opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)

  if core:isActive(opt.id) then
    -- mouse update
    local mx,my = core:getMousePosition()
    if opt.vertical then
      fraction = math.min(1, math.max(0, (y+h - my) / h))
    else
      fraction = math.min(1, math.max(0, (mx - x) / w))
    end
    local v = fraction * (info.max - info.min) + info.min
    if v ~= info.value then
      info.value = v
      value_changed = true
    end


  end

  core:registerDraw(opt.draw or defaultDraw, fraction, opt, x,y,w,h,core.theme)

  return {
    id = opt.id,
    hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
    changed = value_changed,
    hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
  }
end
