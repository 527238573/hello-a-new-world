local rm = render.main
local camera = ui.camera

local batchs--弱table，只关联submap和batch
local batchStrong --强引用，缓存batch一定时间

--快捷变量
local submapLength = 64*16
local ster_img

function rm.initDrawTerrain()
  local mt = {__mode = "kv"}
  batchs = {}
  setmetatable(batchs,mt)
  
  batchStrong = {}
  
  ster_img = data.Ster_BigImage
end


local curTimestamp = 0
local drawSubmap--函数声明
local null_t = c.null_t
--local getsubmap = g.map.lookupSubmap
getsubmap = g.map.getSubmapInGrid
local checkCache -- 检查缓存，释放一段时间未使用的


function rm.drawTerrainLayer()
  curTimestamp = love.timer.getTime()
  
  love.graphics.setColor(255,255,255)
  
  local tmp_cx,tmp_cy = camera.centerX,camera.centerY
  
  
  local startx = math.floor(camera.seen_minX/submapLength)
  local starty = math.floor(camera.seen_minY/submapLength)
  local endx = math.floor((camera.seen_maxX)/submapLength) 
  local endy = math.floor((camera.seen_maxY+32)/submapLength)--额外多画的部分
  
  
  
  local z = camera.cur_Z
  for y= starty,endy do -- 从下至上
    for x= startx,endx do
      local subm = getsubmap(x,y,z)
      if subm~=nil and subm ~=null_t then
        drawSubmap(subm,x,y,z)--传送 需要画的map及其 model坐标等
      end
    end
  end
  checkCache()
  --camera.setCenter(tmp_cx,tmp_cy)
end

-- todo:缓存起来的地形对边缘部分 未生成的submap未能正确处理，新生成的submap边缘不能反应在旧地图中

function drawSubmap(subm,x,y,z)
  local batch = batchs[subm]
  if batch ==nil then 
    batch = love.graphics.newSpriteBatch(ster_img)
    batchs[subm] = batch
    batchStrong[batch] = curTimestamp --标记最后使用的时间戳
    subm.dirty = true
  else
    batchStrong[batch] = curTimestamp --标记最后使用的时间戳
  end
  if(subm.dirty) then 
    subm.dirty = false
    rm.buildSubmapBatch(subm,batch,x,y,z)
    subm.dirty = false
  end
  x,y = camera.modelToScreen(x*submapLength,y*submapLength)
  local scale = camera.zoom--editor.workZoom
  love.graphics.draw(batch,x,y,0,scale,scale)--绘制，根据位置（左下点）和缩放
end



local lastCheckTimestamp
function checkCache()
  
  if lastCheckTimestamp and lastCheckTimestamp+10>curTimestamp then return end
  lastCheckTimestamp = curTimestamp
  
  
  local newhold=  {}
  for k,v in pairs(batchStrong) do
    if curTimestamp< v+10 then
      newhold[k] =v
    end
  end
  batchStrong =newhold --更换为新table,旧的删除 
  
  
end




