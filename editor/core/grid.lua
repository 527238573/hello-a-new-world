
local grid = {}

--输入坐标为模型坐标
function grid.drawLine(sx,sy,ex,ey)
  sx,sy = editor.clampInSeen(sx,sy)
  ex,ey = editor.clampInSeen(ex,ey)
  sx,sy = editor.modelToScreen(sx,sy)
  ex,ey = editor.modelToScreen(ex,ey)
  
  love.graphics.line(sx,sy,ex,ey)
end



function grid.drawMapDebugMesh()--绘制网格
  love.graphics.setColor(240,240,240,150)
  
  for i= 0,c.submapSide do
    local linex =  i*64
    if(linex >= editor.seen_minX and linex <=editor.seen_maxX) then 
      grid.drawLine(linex,0,linex,64 * c.submapSide)
    end
  end
  
  for i= 0,c.submapSide do
    local liney =  i*64
    if(liney>= editor.seen_minY and liney <=editor.seen_maxY) then 
      grid.drawLine(0,liney,64 * c.submapSide,liney)
    end
  end
  love.graphics.setColor(255,255,255) -- 画完还原颜色
end

return grid