local player_mt = g.player_mt
local gmap= g.map

function player_mt:setPosition(x,y,z)
  if z<c.Z_MIN or z>c.Z_MAX then debugmsg("error: set player postion :z out of range");return end
  gmap.leaveUnitCache(self)
  self.x = x
  self.y = y
  self.z = z
  gmap.enterUnitCache(self)
  gmap.setGridCenterSquare(x,y,z)
end

local face_table = {7,6,5,8,4,4,1,2,3}
--[[face
 123
 8 4
 765
 --]]

--平面移动,垂直移动有其他方法
function player_mt:moveAction(dx,dy)
  
  self:setPosition(self.x+dx,self.y+dy,self.z)
  local costtime = (dx~=0 and dy~=0) and 140 or 100
  costtime = costtime/75/3
  
  self.anim = {name = "move",start_x = -64*dx,start_y = -64*dy,totalTime = costtime,pastTime = -self.delay}
  g.cameraLock.cameraMove(self.x-dx,self.y-dy,self.x,self.y,costtime,-self.delay)
  self:addDelay(costtime)
  
  self.face =  face_table[(dy+1)*3 +dx+2]
  
end