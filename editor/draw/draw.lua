draw = {}
local grid = require "draw/grid"
require "draw/drawSquares"
require "draw/drawSubmap"
require "draw/drawBlock"
draw.createNewBatchDic()--初始化


function draw.drawMap()
  --draw.drawAllSquares()
  draw.drawAllSubmaps()
  draw.drawAllBlocks()
  if (editor.showGrid) then grid.drawMapDebugMesh() end
  
  
  draw.drawRightMouse()
end



function draw.drawRightMouse()
  if editor.brushPos then
    local x,y = 64*editor.brushPos[1], 64*(editor.brushPos[2]+1)
    x,y = editor.modelToScreen(x,y)
    love.graphics.setColor(200,200,120,120) 
    love.graphics.rectangle("fill",x,y,64*editor.workZoom,64*editor.workZoom)
  end
end




