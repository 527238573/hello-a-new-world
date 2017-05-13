local suit = require"ui/suit"
local btn_img = love.graphics.newImage("ui/suit/assets/button.png")
local quads = 
{
  --normal = s9util.createS9Table(btn_img,0,0,75,23,2,2,2,2),
  --hovered= s9util.createS9Table(btn_img,0,23,75,23,2,2,2,2),
  --active = s9util.createS9Table(btn_img,0,46,75,23,2,2,2,2)
  
  normal = suit.createS9Table(btn_img,0,0,28,32,6,10,6,6),
  hovered= suit.createS9Table(btn_img,0,32,28,32,6,10,6,6),
  active = suit.createS9Table(btn_img,0,64,28,32,6,10,6,6)
}


local function defaultDraw(picquad,picimg, opt, x,y,w,h,theme)
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal

  love.graphics.setColor(255,255,255)
	theme.drawScale9Quad(s9t,x,y,w,h)
  love.graphics.draw(picimg,picquad,x+6,y+6,0,2,2)
end


return function(picquad,picimg, ...)
	local opt, x,y,w,h = suit.getOptionsAndSize(...)
	opt.id = opt.id or picquad
	opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
	suit:registerDraw(defaultDraw, picquad,picimg, opt, x,y,w,h,suit.theme)

	return {
		id = opt.id,
		hit = suit:mouseReleasedOn(opt.id),
    active = suit:isActive(opt.id),
		hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
	}
end