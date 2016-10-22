local BASE = (...):match('(.-)[^%.]+$')
local s9util = require(BASE.."s9util")

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
  normal = s9util.createS9Table(vbar_img,0,0,17,21,3,3,3,3),
  hovered= s9util.createS9Table(vbar_img,0,21,17,21,3,3,3,3),
  active = s9util.createS9Table(vbar_img,0,42,17,21,3,3,3,3)
}
local hbar_quads=
{
  img = hbar_img,
  normal = s9util.createS9Table(hbar_img,0,0,21,17,3,3,3,3),
  hovered= s9util.createS9Table(hbar_img,0,17,21,17,3,3,3,3),
  active = s9util.createS9Table(hbar_img,0,34,21,17,3,3,3,3)
}



return function(core, info, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  local value_changed = false
  
  
  if opt.vertical then -- 横向滚动
    if(w<50) then w = 50 end -- 最小
    h=17 --固定的
    local fang = 17
    local midw =  w -fang*2
    info.vbar_percent = info.vbar_percent or 0.5
    info.min = info.min or math.min(info.value, 0)
    info.max = info.max or math.max(info.value, 1)
    
    --bar宽度
    local bar_w = math.floor(info.vbar_percent * midw)
    local maxBarX = midw - bar_w
    
    info.sc_vback_opt = info.sc_vback_opt or {id ={}}
    info.sc_left_opt = info.sc_left_opt or {id ={}}
    info.sc_right_opt = info.sc_right_opt or {id ={}}
    info.sc_vbar_opt = info.sc_vbar_opt or {id ={}}
    
    local bar_x
    -- doDrag
    local beforeActive = core:isActive(info.sc_vbar_opt.id)
    if beforeActive then-- doDrag
      -- mouse update
      local mx = love.mouse.getX()
      mx = mx - info.sc_vbar_opt.drag_offset -x -fang
      if mx <0 then mx =0 elseif mx>maxBarX then mx =maxBarX end
      bar_x = mx + x +fang
      --改变的
      local fraction = mx/maxBarX
      local v = fraction * (info.max - info.min) + info.min
      if v ~= info.value then
        info.value = v
        value_changed = true
      end
    else  --noDrag
      --根据数据算出bar_x
      local fraction = (info.value - info.min) / (info.max - info.min)
      bar_x = math.floor(fraction *maxBarX) +x +fang
    end
    
    
    local s1=core:Image(vback_img,info.sc_vback_opt,x+fang,y,midw,h)
    local s2=core:ImageButton(left_quads,info.sc_left_opt,x,y,fang,h)
    local s3=core:ImageButton(right_quads,info.sc_right_opt,x+fang+midw,y,fang,h)
    local s4=core:ImageButton(hbar_quads,info.sc_vbar_opt,bar_x,y,bar_w,h)
    
    if core:isActive(info.sc_vbar_opt.id) and not beforeActive then
      -- mouse update
      local mx = love.mouse.getX()
      info.sc_vbar_opt.drag_offset = mx -bar_x
    end
    
    local combineS = core:combineState(opt.id,s1,s2,s3,s4)
    combineS.change = value_changed
    return combineS
  end
  



  return {
    id = opt.id,
    hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
    changed = value_changed,
    hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
  }
end
