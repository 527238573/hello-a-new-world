local BASE = (...):match('(.-)[^%.]+$')

local s9util = require(BASE.."s9util")

local bg_img = love.graphics.newImage(BASE.."/assets/bg.png")
local s9table = s9util.createS9Table(bg_img,0,0,100,79,30,4,4,4)



local function defaultDraw(text,opt,x,y,w,h,theme)
  
  love.graphics.setColor(255,255,255)
	theme.drawScale9Quad(s9table,x,y,w,h)
  love.graphics.setColor(66,66,66)
	love.graphics.setFont(opt.font)
  y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, 30)
	love.graphics.printf(text, x+8, y, w-16, opt.align or "left")
end


return function(core, idtext, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or idtext
  opt.font = opt.font or love.graphics.getFont()
  
  
	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
	core:registerDraw(opt.draw or defaultDraw, idtext,opt,x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end