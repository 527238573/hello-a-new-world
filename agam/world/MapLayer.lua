require"core/ZoneMap"

ONE_PIECE = 64

mapLayer = {}
mapLayer.allmaps = {}

local firstmap = Zonemap() -- 测试map
mapLayer.allmaps[firstmap.id] = firstmap

mapLayer.currentMap = firstmap
mapLayer.width = firstmap.width
mapLayer.height = firstmap.height
 

 
function mapLayer.isLegal(x,y)
   return x>=1 and x<=mapLayer.width and y>=1 and y<=mapLayer.height
end
 
 
--地图坐标从1 开始
function mapLayer.mapToRootCrood(mapx,mapy) 
  return (mapx-0.5)*ONE_PIECE,(mapy-1) *ONE_PIECE
end

 
 
 
 
local function zclamp(x ,min,max)
  if x<min then x = min end
  if x>max then x = max end
  return x
end

local function drawMapDebugLine(x, y, tox, toy)
  x = zclamp(x,camera.minX,camera.maxX)
  y = zclamp(y,camera.minY,camera.maxY)
  tox = zclamp(tox,camera.minX,camera.maxX)
  toy  = zclamp(toy,camera.minY,camera.maxY)
  
  
  x,y = worldToScreen(x,y)
  tox,toy = worldToScreen(tox,toy)
  love.graphics.line(x,y,tox,toy)
end


local function drawMapDebugMesh()--绘制网格
  love.graphics.setColor(240,240,240,150)
  
  for i= 0,mapLayer.currentMap.width do
    local linex =  i*64
    if(linex >= camera.minX and linex <=camera.maxX) then 
      drawMapDebugLine(linex,0,linex,64 * mapLayer.currentMap.height)
    end
  end
  
  for i= 0,mapLayer.currentMap.height do
    local liney =  i*64
    if(liney>= camera.minY and liney <=camera.maxY) then 
      drawMapDebugLine(0,liney,64 * mapLayer.currentMap.width,liney)
    end
  end
  
  love.graphics.setColor(255,255,255) -- 画完还原颜色
end


Vrotation = 1

local function rotateXY(x,y)
  local sin = math.sin(Vrotation)
  local cos = math.cos(Vrotation)
  return cos * x -sin *y , sin*x + cos *y
end

local function drawtoMouse(x, y, tox, toy)
  x,y = rotateXY(x,y)
  tox,toy = rotateXY(tox,toy)
  
  local mousex,mousey = love.mouse.getPosition()
  love.graphics.line(x+mousex,y+mousey,tox+mousex,toy+mousey)
end

local function drawDebugTestV()
  local w,h = 3,4
  for i= 0,w do
    local fx,fy = 0,64*i;
    local tx,ty = h*64,64*i;
    
    drawtoMouse(fx,fy,tx,ty)
  end
  
  for i= 0,h do
    local fx,fy = 64*i,0;
    local tx,ty = 64*i,64*w;
    
    drawtoMouse(fx,fy,tx,ty)
  end
  
end



function mapLayer.draw()
  --drawDebugTestV()
  drawMapDebugMesh()
end
  
  
