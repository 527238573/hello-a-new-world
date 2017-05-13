local suit = require"ui/suit"
--物品详细信息面板
local iteminfo_img = love.graphics.newImage("assets/ui/iteminfo.png")
local iteminfo_quad = suit.createS9Table(iteminfo_img,0,0,26,30,6,8,6,6)


local tmpinfo ={}

local function createSnapshoot(curItem,w)
  --快照物品信息并保存。有变化时重制
  --可能的变化，物品变。物品里堆叠变化，容器内容变化，腐坏度损坏度变化等
  if tmpinfo.item == curItem and tmpinfo.stack_num == curItem.stack_num then 
    return--无变化，不用修改
  end
  --重置快照
  local itype = curItem.type
  
  tmpinfo ={}
  tmpinfo.item = curItem
  tmpinfo.stack_num = curItem.stack_num
  tmpinfo.name = curItem:getName()
  --tmpinfo.wv_info = string.format("%s%.2fkg %s%d",tl("重量:","Weight:"),curItem:getWeight()/100,tl("体积:","Volume:"),curItem:getVolume())
  tmpinfo.w_info = string.format("%s%.2fkg ",tl("重量:","Weight:"),curItem:getWeight()/100)
  tmpinfo.v_info = string.format("%s%d",tl("体积:","Volume:"),curItem:getVolume())
  tmpinfo.wv_text= love.graphics.newText(c.font_c16)
  tmpinfo.wv_text:add({{170,170,170},tmpinfo.w_info,{210,210,210},tmpinfo.v_info,},79,43)
  
  local textWidth = 280--默认文字宽
  local length = 0;
  local info_text = love.graphics.newText(c.font_c16)
  local function addOneLineInfo(table)--必须是一行，带换行
    info_text:addf(table,textWidth,"left",0,length)
    length = length+ info_text:getHeight()
  end
  
  addOneLineInfo{{170,170,170},itype.description,}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  tmpinfo.info_text = info_text
  tmpinfo.totalLen = length
end






local function draw_iteminfo(curItem,x,y,w,h)
  love.graphics.setColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,w,h)
  local itype = curItem.type
  
  love.graphics.setColor(255,255,255)
  love.graphics.draw(itype.img,itype.quad,x+10,y+4,0,2,2)
  love.graphics.setColor(225,225,225)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tmpinfo.name, x+79, y+18)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(tmpinfo.wv_text,x,y)
  --love.graphics.setColor(170,170,170)
  --love.graphics.setFont(c.font_c16)
  --love.graphics.print(tmpinfo.wv_info, x+79, y+43)
  
  love.graphics.draw(tmpinfo.info_text,x+15,y+74)
end

-- 自由宽高，但要一定最小值，宽太小导致物品名字超出框，长度不够会启用滚动条
function ui.iteminfo(curItem,x,y,w,h)
  createSnapshoot(curItem,w)
  suit:registerHitbox(nil,iteminfo_quad, x,y,w,h)
  suit:registerDraw(draw_iteminfo,curItem,x,y,w,h)--等于发送的是缓存的物品指针。源物品可能因为后续的操作逻辑被销毁或改变等。但最多存在本帧内
end

function ui.iteminfo_reset()--强行重置
  tmpinfo.item = nil
end
