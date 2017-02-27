local bit = require("bit")


local ov = ui.overmap
local bufferMapBatchs = {}
local bufferMapWidth = c.BuffMap_L * 32 --求出bufferMap的宽度 （32为每个oter32像素）

--快速局域变量
local overmapImg
local renderOter = render.overmap.drawOter

function render.overmap.initDrawOvBuffer()
  overmapImg = data.Oter_BigImage
  
end


--左下坐标为初始
local function buildBuffermapBatch(batch,x,y)
  local curz = ov.cur_Z
  local added = 0
  batch:clear()
  
  for lx = 0,c.BuffMap_L-1 do
    for ly = 0,c.BuffMap_L-1 do
      local otx = lx +c.BuffMap_L*x--oter全局坐标
      local oty = ly +c.BuffMap_L*y
      added = added +renderOter(batch,otx,oty,lx,ly,curz)
    end
  end
  return added>0
end



local function drawBuffermap(x,y)
  --先求得 buffermap 所在的overmap坐标
  local ox = bit.arshift(x,4) -- 一个overmap有16*16个buffermap
  local oy = bit.arshift(y,4)
  local om = g.overmap.get_existing_overmap(ox,oy)
  if om==nil then return end
  local om_batchs = bufferMapBatchs[om]
  if om_batchs ==nil then 
    om_batchs = {}
    bufferMapBatchs[om] = om_batchs
  end
  local sx = bit.band(x,15)
  local sy = bit.band(y,15)
  
  local bm_batch = om_batchs[sx*16+sy]
  if bm_batch ==nil then
    bm_batch = love.graphics.newSpriteBatch(overmapImg,512)
    local success = buildBuffermapBatch(bm_batch,x,y)
    if success then 
      om_batchs[sx*16+sy] = bm_batch
    else
      om_batchs[sx*16+sy] = false
      return
    end
  elseif bm_batch == false then return end
  x,y = ov.modelToScreen(x*bufferMapWidth,y*bufferMapWidth)
  love.graphics.draw(bm_batch,x,y)
end

function render.overmap.drawAllBufferMap()
  love.graphics.setColor(255,255,255)
  --算出起始结束bufferMap的坐标
  local startx = math.floor(ov.seen_minX/bufferMapWidth)
  local starty = math.floor(ov.seen_minY/bufferMapWidth)
  local endx = math.floor(ov.seen_maxX/bufferMapWidth)
  local endy = math.floor(ov.seen_maxY/bufferMapWidth)
  
  for y= starty,endy do 
    for x= startx,endx do
      drawBuffermap(x,y)
    end
  end
end

function render.overmap.clearBuffer()
  bufferMapBatchs = {}
end

