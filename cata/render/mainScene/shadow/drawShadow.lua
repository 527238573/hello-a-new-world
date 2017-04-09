local rm = render.main


local gmap = g.map
local grid = g.map.grid
local camera = ui.camera


function rm.drawShadowLayer(zcache)
  
  local startx = math.floor(camera.seen_minX/64)
  local starty = math.ceil(camera.seen_maxY/64)
  local endx = math.ceil((camera.seen_maxX)/64)
  local endy = math.floor((camera.seen_minY)/64)
  
  local width = 64*camera.zoom
  love.graphics.setColor(20,20,20,150)
  
  
  for y= starty,endy,-1 do -- 从上至下
    for x= startx,endx do
      --取得在grid中的相对坐标
      local rx = x-grid.minXsquare
      local ry = y-grid.minYsquare
      if rx>=0 and rx<=143 and ry>=0 and ry<=143 then
        --确定在grid的范围内
        if(zcache.seen[rx][ry]<=0) then
          local screenx,screeny = camera.modelToScreen(x*64,y*64+64)
          
          --不可见的square
          love.graphics.rectangle("fill",screenx,screeny,width,width)
        end
      end
    end
  end
  
  
end