local bit = require("bit")
local terrain_img = require("data/terrain_data").img


local submapBatchs --缓存对应submap的


--初始创建batch的dictionary或 重创建来清空
function draw.createNewBatchDic()
  local mt = {__mode = "k"}
  submapBatchs = {}
  setmetatable(submapBatchs,mt)
  draw.submapBatchs = submapBatchs
end



local function buildSubmapBatch(smap,batch,x,y,z)
  batch:clear()
  local startx = x*c.submapSide
  local endx = startx+c.submapSide-1
  local starty = y*c.submapSide
  local endy = starty +c.submapSide-1
  
  for sy = starty,endy do
    for sx = startx,endx do
      draw.addSquareToBatch(batch,sx,sy,z)
    end
  end
  
end

--x,y为虚拟 submap index
local function drawSubmap(subm,x,y,z,modelx,modely)
  local batchtable = submapBatchs[subm]
  if batchtable ==nil then 
    batchtable = {dirty = true, batch = love.graphics.newSpriteBatch(terrain_img)}
    submapBatchs[subm] = batchtable
  end
  if(batchtable.dirty) then 
    buildSubmapBatch(subm,batchtable.batch,x,y,z)
    batchtable.dirty = false
  end
  x,y = editor.modelToScreen(modelx,modely)
  local scale = editor.workZoom
  love.graphics.draw(batchtable.batch,x,y,0,scale,scale)--绘制，根据位置（左下点）和缩放
end



--[[
绘制顺序：从下往上绘制
34
12
]]--


function draw.drawAllSubmaps(z)--绘制屏幕内
  love.graphics.setColor(255,255,255)
  local subx = editor.map.subx
  local suby = editor.map.suby
  local perSubmapl = c.squarePixels * c.submapSide
  
  local startx = math.floor(editor.seen_minX/perSubmapl)
  local starty = math.floor(editor.seen_minY/perSubmapl)
  local endx = math.floor(editor.seen_maxX/perSubmapl)
  local endy = math.floor(editor.seen_maxY/perSubmapl)
  
  for y= starty,endy do -- 从下至上
    for x= startx,endx do
      local subm = editor.getSubmapFormVirtualXY(x,y,z)
      if subm~=nil then
        drawSubmap(subm,x,y,z,x*perSubmapl,y*perSubmapl)--传送 需要画的map及其 model坐标等
      end
    end
  end
end

function draw.setDirty(submap)
  submapBatchs[submap].dirty = true
end

function draw.dirtyAll()
  for _,v in pairs(submapBatchs) do
    v.dirty = true
  end
end

