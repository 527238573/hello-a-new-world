render.main = {}
local rm = render.main
require "render/mainScene/animation/animation"
require "render/mainScene/terrain/drawSter"
require "render/mainScene/terrain/drawTerrain"
require "render/mainScene/block/drawBlocks"


function rm.init()
  rm.initAnimation()
  rm.initDrawSter()
  rm.initDrawTerrain()
  rm.initDrawBlocks()
end



function render.renderMainScene()
  ui.camera.clampCenter()-- 镜头范围取一个有效值
  
  rm.drawTerrainLayer()
  rm.drawBlocksLayer()
  
end