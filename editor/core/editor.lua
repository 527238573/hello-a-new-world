local bit = require("bit")

editor={}
local editor = editor
require "core/map"

function editor.init()
  editor.work_W = c.win_W-c.painterPanel_W
  editor.work_H = c.win_H-c.topbar_H
  editor.workx = 0
  editor.worky = c.topbar_H --工作区域在屏幕上的起始坐标
  editor.workZoom = 1; -- 可见部分缩放比例
  --可见区域在模型坐标的半长
  editor.half_seen_W = editor.work_W/editor.workZoom/2
  editor.half_seen_H = editor.work_H/editor.workZoom/2
  
  editor.curZ = 1; -- 当前层数
  editor.curDirection  =1; --朝向 1-4，顺时针 上-右-下-左
  editor.showGrid = false
  editor.showBlock = true
  editor.showDownLayer = false
  --可视中心点坐标及其移动范围，坐标系采用标准上Y右X，与屏幕坐标系不同
  editor.center_minX = 0
  editor.center_maxX = c.submapSide *c.squarePixels 
  editor.center_minY = 0
  editor.center_maxY = c.submapSide *c.squarePixels 
  
  editor.setCenter(editor.center_maxX/2,editor.center_maxY/2)--初始化
  
  editor.initMap()
  --editor.brushPos = {0,0}
end


function editor.setWorkZoom(z)
  editor.workZoom = c.clamp(z,0.5,1)
  editor.half_seen_W = editor.work_W/editor.workZoom/2
  editor.half_seen_H = editor.work_H/editor.workZoom/2
  --
  if editor.workZoom ==0.5 then 
    editor.centerX = editor.centerX -editor.centerX%2
    editor.centerY = editor.centerY -editor.centerY%2
  elseif editor.workZoom ==0.75 then 
    editor.centerX = editor.centerX -editor.centerX%(4/3)
    editor.centerY = editor.centerY -editor.centerY%(4/3)
  end
  
  editor.updateSeenRect()
end

function editor.setCenter(x,y)
  editor.centerX = c.clamp(x,editor.center_minX,editor.center_maxX)
  editor.centerY = c.clamp(y,editor.center_minY,editor.center_maxY)
  editor.updateSeenRect()
end

function editor.updateSeenRect()
  editor.seen_minX = editor.centerX -editor.half_seen_W
  editor.seen_maxX = editor.centerX +editor.half_seen_W
  editor.seen_minY = editor.centerY -editor.half_seen_H
  editor.seen_maxY = editor.centerY +editor.half_seen_H
end


--模型坐标的旋转变化
function editor.transToStandard(direction,x,y)
  if(direction==1) then 
    return x,y
  elseif(direction==2) then
    return editor.real_x_length-y,x
  elseif(direction==3) then
    return editor.real_x_length-x,editor.real_y_length-y
  elseif(direction==4) then
    return y,editor.real_y_length-x
  end
end

--x,y 为0起始 
local function toStandardDirection(direction,x,y,maxX,maxY)
  if(direction==1) then 
    return x,y
  elseif(direction==2) then
    return maxX-y,x
  elseif(direction==3) then
    return maxX-x,maxY-y
  elseif(direction==4) then
    return y,maxY-x
  end
end


function editor.transToDirection(direction,x,y)
  if(direction==1) then 
    return x,y
  elseif(direction==2) then
    return y,editor.real_x_length-x
  elseif(direction==3) then
    return editor.real_x_length-x,editor.real_y_length-y
  elseif(direction==4) then
    return editor.real_y_length-y,x
  end
end

local function transToStandardSquareXY(x,y)
  return toStandardDirection(editor.curDirection,x,y,editor.real_x_square-1,editor.real_y_square-1)
end
local function transToStandardSubmapXY(x,y)
  return toStandardDirection(editor.curDirection,x,y,editor.real_x_subnum-1,editor.real_y_subnum-1)
end


--重建模型 范围， 方向旋转时 改编虚拟宽高，左下点始终为0，0
function editor.updateMapRect()
  local map = editor.map
  editor.real_x_length = map.subx*c.submapSide *c.squarePixels
  editor.real_y_length = map.suby*c.submapSide *c.squarePixels
  editor.real_x_subnum = map.subx
  editor.real_y_subnum = map.suby
  editor.real_x_square = map.subx*c.submapSide
  editor.real_y_square = map.suby*c.submapSide
  
  if editor.curDirection==1 or editor.curDirection ==3 then
    editor.sub_x_num = map.subx   --虚拟宽高
    editor.sub_y_num = map.suby
  else
    editor.sub_x_num = map.suby
    editor.sub_y_num = map.subx
  end
  editor.square_x_num = editor.sub_x_num*c.submapSide --虚拟格子数
  editor.square_y_num = editor.sub_y_num*c.submapSide
  
  
  
  editor.center_minX = 0
  editor.center_minY = 0
  editor.center_maxX = editor.sub_x_num*c.submapSide *c.squarePixels
  editor.center_maxY = editor.sub_y_num*c.submapSide *c.squarePixels
end

function editor.changeDirection(newdirction)
  local old = editor.curDirection
  if newdirction<1 then 
    editor.curDirection = 4 
  elseif newdirction>4 then
    editor.curDirection = 1
  else
    editor.curDirection = newdirction
  end
  if(editor.curDirection~=old) then 
    editor.updateMapRect() 
    local x,y = editor.transToStandard(old,editor.centerX,editor.centerY)
    x,y= editor.transToDirection(editor.curDirection,x,y)
    editor.setCenter(x,y)
    draw.dirtyAll()
  end
end

function editor.changeLayer(newZ)
  editor.curZ = c.clamp(newZ,editor.map.lowz,editor.map.highz)
end


function editor.modelToScreen(x,y)
  return (x-editor.seen_minX)*editor.workZoom+editor.workx,(editor.seen_maxY-y)*editor.workZoom+editor.worky--注意maxY，模型坐标轴与屏幕坐标Y轴相反
end

function editor.screenToModel(x,y)
  return (x-editor.workx)/editor.workZoom+editor.seen_minX,editor.seen_maxY-(y-editor.worky)/editor.workZoom
end

function editor.clampInSeen(x,y)--模型坐标
  return c.clamp(x,editor.seen_minX,editor.seen_maxX),c.clamp(y,editor.seen_minY,editor.seen_maxY)
end



function editor.getSubmapFormVirtualXY(x,y,z)
  
  x,y = transToStandardSubmapXY(x,y)
  if(x>=0 and x< editor.real_x_subnum and y>=0 and y< editor.real_y_subnum) then
    return submap(x,y,z)
  else
    return nil
  end
end

function editor.getSquareFormVirtualXY(x,y,z)
  x,y = transToStandardSquareXY(x,y)
  local sx = bit.rshift(x,4)--不用arshift因为始终大于0
  local sy = bit.rshift(y,4)
  local lx = bit.band(x,15)
  local ly = bit.band(y,15)
  if(sx<0 or sx>= editor.real_x_subnum or sy<0 or sy>= editor.real_y_subnum) then
    return nil
  end
  local subm = submap(sx,sy,z)
  return subm[lx][ly]
end


