draw = {}
local grid = require "draw/grid"
require "draw/drawSquares"
require "draw/drawSubmap"
require "draw/drawBlock"
draw.createNewBatchDic()--初始化
draw.shiftX = 0
draw.shiftY = 0

function draw.drawMap()
  --draw.drawAllSquares()
  local curZ = editor.curZ
  
  if editor.showDownLayer then
    if curZ-1>=editor.map.lowz then
      
      love.graphics.push()
      love.graphics.translate(0,20)
      draw.shiftX = 0
      draw.shiftY = 20
      
      draw.drawAllSubmaps(curZ-1)
      draw.drawAllBlocks(curZ-1)
      love.graphics.pop()
      draw.shiftX = 0
      draw.shiftY = 0
      
    end
  end
  
  
  draw.drawAllSubmaps(curZ)
  draw.drawAllBlocks(curZ)
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




