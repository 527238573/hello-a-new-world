
local suit = require"ui/suit"

local iteminfo_img = ui.res.iteminfo_img
local iteminfo_quad = ui.res.iteminfo_quad --已被通用化

local empty_t = {}
local tmpinfo =empty_t
local info_text = love.graphics.newText(c.font_c16)

local function createSnapshoot(toolid,level,w)
  if tmpinfo.toolid == toolid and tmpinfo.level == level then 
    return--无变化，不用修改
  end
  tmpinfo ={}
  tmpinfo.toolid = toolid
  tmpinfo.level = level
  tmpinfo.tooldata = data.qualities[toolid]
  tmpinfo.namestr = string.format(tl("%s 等级%d 的工具","Tools with %s Lv%d or more"),tmpinfo.tooldata.name,level)
  local namelist= {}
  info_text:clear()
  for i=1,#tmpinfo.tooldata.typelist do
    local oneType = tmpinfo.tooldata.typelist[i]
    if oneType.toolLevel[toolid]>=level then
      table.insert(namelist,oneType.name)
      table.insert(namelist,", ")
    end
  end
  info_text:add(tl("满足条件的工具:","tools meet the condition:"),0,0)
  info_text:addf(table.concat(namelist), w-40,"left", 0,20)
  
  
  
end


local function draw_toolLevelInfo(x,y,w,h)
  love.graphics.setColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,w,h)
  love.graphics.draw(tmpinfo.tooldata.img,tmpinfo.tooldata.quad,x+10,y+4,0,2,2)
  love.graphics.setColor(225,225,225)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tmpinfo.namestr, x+79, y+18)
  love.graphics.setColor(170,170,170)
  love.graphics.draw(info_text,x+15,y+74)
  
end


function ui.toolLevelInfo(toolid,level,x,y,w,h,reserved_h)
  createSnapshoot(toolid,level,w)
  suit:registerHitbox(nil,iteminfo_quad, x,y,w,h)
  suit:registerDraw(draw_toolLevelInfo,x,y,w,h)
end

function ui.toolLevelInfo_reset()--强行重置
  tmpinfo =empty_t
end
