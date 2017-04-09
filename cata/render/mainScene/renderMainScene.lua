render.main = {}
local rm = render.main
require "render/mainScene/animation/animation"
require "render/mainScene/terrain/drawSter"
require "render/mainScene/terrain/drawTerrain"
require "render/mainScene/block/drawBlocks"
require "render/mainScene/shadow/drawShadow"

function rm.init()
  rm.initAnimation()
  rm.initDrawSter()
  rm.initDrawTerrain()
  rm.initDrawBlocks()
end



function render.renderMainScene()
  ui.camera.clampCenter()-- 镜头范围取一个有效值
  
  local curZ = ui.camera.cur_Z
  --提前统一build好
  local zcache,rz = g.map.zLevelCache.getCache(curZ) 
  
  if zcache.floor_dirty then g.map.zLevelCache.buildFloorCache(zcache,rz) end
  if zcache.seen_dirty then g.map.zLevelCache.buildSeenCache(zcache,rz) end
  
  if curZ>c.Z_MIN then --draw low layer
    love.graphics.push()
    love.graphics.translate(0,22)
    rm.shiftX = 0
    rm.shiftY = 22  --setScissor时要加上此变量
    rm.drawLowTerrainLayer(zcache)
    rm.drawLowBlocksLayerUnder(zcache)
    rm.drawBlocksLayerUnder(zcache)
    love.graphics.pop()
    rm.shiftX = 0
    rm.shiftY = 0
    
  end
  rm.drawTerrainLayer()
  rm.drawLowBlocksLayer(zcache,false)
  --提前统一build好
  rm.drawShadowLayer(zcache)
  rm.drawBlocksLayer(zcache,false)
  --rm.drawShadowLayer()
end