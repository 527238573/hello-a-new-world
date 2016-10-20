
local BASE = (...):match('(.-)[^%.]+$')

local s9util = require(BASE.."s9util")


local btn_img = love.graphics.newImage("suit/assets/button.png")
local quads = 
{
  normal = s9util.createS9Table(btn_img,0,0,75,23,2,2,2,2),
  hovered= s9util.createS9Table(btn_img,0,23,75,23,2,2,2,2),
  active = s9util.createS9Table(btn_img,0,46,75,23,2,2,2,2)
}


local function defaultDraw(text, opt, x,y,w,h,theme)
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal

  love.graphics.setColor(255,255,255)
	theme.drawScale9Quad(s9t,x,y,w,h)
	love.graphics.setColor(66,66,66)
	love.graphics.setFont(opt.font)

	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end


return function(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or text
	opt.font = opt.font or love.graphics.getFont()

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
	core:registerDraw(opt.draw or defaultDraw, text, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end