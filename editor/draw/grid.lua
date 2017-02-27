
local grid = {}

--输入坐标为模型坐标
function grid.drawLine(sx,sy,ex,ey)
  sx,sy = editor.clampInSeen(sx,sy)
  ex,ey = editor.clampInSeen(ex,ey)
  sx,sy = editor.modelToScreen(sx,sy)
  ex,ey = editor.modelToScreen(ex,ey)
  
  love.graphics.line(sx,sy,ex,ey)
end


local function checkSubmapInSeen(x,y)
  local s_minx,s_maxx,s_miny,s_maxy = x,x+c.submapSide*64,y,y+c.submapSide*64
  return editor.seen_maxX>s_minx and s_maxx>editor.seen_minX and editor.seen_maxY>s_miny and s_maxy>editor.seen_minY
end

function grid.drawSubmap(x,y)
  
  if not checkSubmapInSeen(x,y) then return end
  love.graphics.setColor(240,240,240,150)
  
  for i= 1,c.submapSide-1 do
    local linex =  i*64 +x
    if(linex >= editor.seen_minX and linex <=editor.seen_maxX) then 
      grid.drawLine(linex,y,linex,64 * c.submapSide+y)
    end
  end
  
  for i= 1,c.submapSide-1 do
    local liney =  i*64 +y
    if(liney>= editor.seen_minY and liney <=editor.seen_maxY) then 
      grid.drawLine(x,liney,64 * c.submapSide+x,liney)
    end
  end
  love.graphics.setColor(240,110,110,150)
  local linex =  x
  if(linex >= editor.seen_minX and linex <=editor.seen_maxX) then 
      grid.drawLine(linex,y,linex,64 * c.submapSide+y)
  end
  linex =  x+c.submapSide*64
  if(linex >= editor.seen_minX and linex <=editor.seen_maxX) then 
      grid.drawLine(linex,y,linex,64 * c.submapSide+y)
  end
  local liney =  y
  if(liney>= editor.seen_minY and liney <=editor.seen_maxY) then 
      grid.drawLine(x,liney,64 * c.submapSide+x,liney)
  end
  liney = y+c.submapSide*64
  if(liney>= editor.seen_minY and liney <=editor.seen_maxY) then 
      grid.drawLine(x,liney,64 * c.submapSide+x,liney)
  end
  
  love.graphics.setColor(255,255,255) -- 画完还原颜色
  
end




function grid.drawMapDebugMesh()--绘制网格
  
  for x = 1,editor.sub_x_num do
    for y =1,editor.sub_y_num do
      grid.drawSubmap((x-1)*c.submapSide*64,(y-1)*c.submapSide*64)
      
    end
  end
end

return grid