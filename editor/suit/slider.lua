-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')


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

		-- keyboard update
		local key_up = opt.vertical and 'up' or 'right'
		local key_down = opt.vertical and 'down' or 'left'
		if core:getPressedKey() == key_up then
			info.value = math.min(info.max, info.value + info.step)
			value_changed = true
		elseif core:getPressedKey() == key_down then
			info.value = math.max(info.min, info.value - info.step)
			value_changed = true
		end
	end

	core:registerDraw(opt.draw or defaultDraw, fraction, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		changed = value_changed,
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end
