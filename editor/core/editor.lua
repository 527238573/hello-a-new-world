

editor={}
local editor = editor
editor.grid = require "core/grid"
editor.touch = require "core/touch"
require "core/map"

function editor.init()
  editor.work_W = c.win_W-c.painterPanel_W
  editor.work_H = c.win_H-c.topbar_H
  editor.workx = 0
  editor.worky = c.topbar_H --工作区域在屏幕上的起始坐标
  editor.workZoom = 1; -- 可见部分缩放比例
  
  editor.curZ = 1; -- 当前层数
  editor.curDirection  =1; --朝向 1-4，顺时针 上-右-下-左
  
  --可视中心点坐标及其移动范围，坐标系采用标准上Y右X，与屏幕坐标系不同
  editor.center_minX = 0
  editor.center_maxX = c.submapSide *c.squarePixels 
  editor.center_minY = 0
  editor.center_maxY = c.submapSide *c.squarePixels 
  
  
  --可见区域在模型坐标的半长
  editor.half_seen_W = editor.work_W/editor.workZoom/2
  editor.half_seen_H = editor.work_H/editor.workZoom/2
  editor.setCenter(editor.center_maxX/2,editor.center_maxY/2)--初始化
  
  editor.initMap()
  
end


function editor.setWorkZoom(z)
  editor.workZoom = c.clamp(z,0.5,1)
  editor.half_seen_W = editor.work_W/editor.workZoom/2
  editor.half_seen_H = editor.work_H/editor.workZoom/2
  editor.seen_minX = editor.centerX -editor.half_seen_W
  editor.seen_maxX = editor.centerX +editor.half_seen_W
  editor.seen_minY = editor.centerY -editor.half_seen_H
  editor.seen_maxY = editor.centerY +editor.half_seen_H
end

function editor.setCenter(x,y)
  editor.centerX = c.clamp(x,editor.center_minX,editor.center_maxX)
  editor.centerY = c.clamp(y,editor.center_minY,editor.center_maxY)
  editor.seen_minX = editor.centerX -editor.half_seen_W
  editor.seen_maxX = editor.centerX +editor.half_seen_W
  editor.seen_minY = editor.centerY -editor.half_seen_H
  editor.seen_maxY = editor.centerY +editor.half_seen_H
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

function editor.handleKeyPressed(key)
  if(key == 'w') then 
    editor.curZ = c.clamp(editor.curZ +1,editor.map.lowz,editor.map.highz)
  elseif (key == 's') then 
    editor.curZ = c.clamp(editor.curZ -1,editor.map.lowz,editor.map.highz)
  elseif (key == 'a') then 
    editor.curDirection = editor.curDirection -1; if editor.curDirection<1 then editor.curDirection = 4 end
  elseif (key == 'd') then 
    editor.curDirection = editor.curDirection +1; if editor.curDirection>4 then editor.curDirection = 1 end 
  end
end


function editor.drawMap()
  editor.grid.drawMapDebugMesh()
end