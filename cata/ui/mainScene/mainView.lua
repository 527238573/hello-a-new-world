ui.camera = {}
local camera = ui.camera
local grid--g.map.grid

function camera.init()
  camera.right_w = 280
  
  camera.cur_Z = 1-- 当前观察Z层数
  camera.zoom = 1
  
  camera.view_W = c.win_W - camera.right_w
  camera.view_H = c.win_H
  camera.viewX=0
  camera.viewY=0
  
  camera.half_seen_W = camera.view_W/2/camera.zoom
  camera.half_seen_H = camera.view_H/2/camera.zoom
  
  grid = g.map.grid
  
  camera.setCenter(0,0)
end


function camera.setCenter(x,y)
  camera.centerX = c.clamp(x,grid.field_minX,grid.field_maxX)--读取grid内部的数据
  camera.centerY = c.clamp(y,grid.field_minY,grid.field_maxY)
  camera.updateSeenRect()
end

function camera.setZ(z)
  z = c.clamp(z,grid.minZsub,grid.maxZsub)
  z = c.clamp(z,c.Z_MIN,c.Z_MAX)
  --小地图也变幻
  if z~= camera.cur_Z then g.map.minimap_dirty = true end
  camera.cur_Z = z
end

function camera.setZoom(zoom)
  camera.zoom = c.clamp(zoom,0.5,1)
  camera.half_seen_W = camera.view_W/2/camera.zoom
  camera.half_seen_H = camera.view_H/2/camera.zoom
  camera.updateSeenRect()
end

function camera.updateSeenRect()
  camera.seen_minX = camera.centerX -camera.half_seen_W
  camera.seen_maxX = camera.centerX +camera.half_seen_W
  camera.seen_minY = camera.centerY -camera.half_seen_H
  camera.seen_maxY = camera.centerY +camera.half_seen_H
end

function camera.modelToScreen(x,y)
  return (x-camera.seen_minX)*camera.zoom+camera.viewX,(camera.seen_maxY-y)*camera.zoom+camera.viewY--注意maxY，模型坐标轴与屏幕坐标Y轴相反
end
function camera.screenToModel(x,y)
  return (x-camera.viewX)/camera.zoom+camera.seen_minX,camera.seen_maxY-(y-camera.viewY)/camera.zoom
end

function camera.update()
  local lock  =g.cameraLock
  if lock.locked then
    local rate = lock.cur/lock.total
    local cx = (lock.fx +(lock.tx -lock.fx)*rate)
    local cy = (lock.fy +(lock.ty -lock.fy)*rate)
    camera.setCenter(cx,cy)
  end
end


function camera.clampCenter()
  --
  local cx,cy
  if camera.zoom ==1 then
    cx = math.floor(camera.centerX)
    cy = math.floor(camera.centerY)
  elseif camera.zoom ==0.5 then 
    cx = camera.centerX -camera.centerX%2
    cy = camera.centerY -camera.centerY%2
  elseif camera.zoom ==0.75 then 
    cx = camera.centerX -camera.centerX%(4/3)
    cy = camera.centerY -camera.centerY%(4/3)
  end
  camera.setCenter(cx,cy)
end


function camera.clampXY(x,y)
  if camera.zoom ==1 then
    x = math.floor(x)
    y = math.floor(y)
  elseif camera.zoom ==0.5 then 
    x = x -x%2
    y = y -y%2
  elseif camera.zoom ==0.75 then 
    x = x -x%(4/3)
    y = y -y%(4/3)
  end
  return x,y
end


function camera.resetToPlayerPosition()
  camera.setCenter(player.x*64,player.y*64)
end
