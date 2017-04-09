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
  gmap.zLevelCache.setSeenDirty()--使缓存重置
end

local face_table = {7,6,5,8,1,4,1,2,3}
--[[face
 123
 8 4
 765
 --]]

--平面移动,垂直移动有其他方法
function player_mt:moveAction(dx,dy)
  --先检定能否move
  local dest_x = self.x+dx
  local dest_y = self.y+dy
  local dest_z = self.z
  
  local move_cost = gmap.square_movecost(dest_x,dest_y,dest_z)
  if move_cost<=0 then return end --不能移动
  local costtime  = move_cost/75
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/3
  self:setPosition(self.x+dx,self.y+dy,self.z)
  
  self.anim = {name = "move",start_x = -64*dx,start_y = -64*dy,totalTime = costtime,pastTime = -self.delay}
  ui.camera.setZ(self.z)
  g.cameraLock.cameraMove(self.x-dx,self.y-dy,self.x,self.y,costtime,-self.delay)
  self:addDelay(costtime)
  
  self.face =  face_table[(dy+1)*3 +dx+2]
  
end

--press space key
function player_mt:spaceAction()
  debugmsg("space pressed")
  --if self:go_stairs() then return end
  local dx,dy,dz = gmap.check_stairs(self.x,self.y,self.z)
  if dx then --有楼梯
    self:go_stairs(dx,dy,dz)
  elseif dy>0 then --出口被堵住
    --todo ：提示被堵住的楼梯
    debugmsg("stairs blocked")
  end
  
end

function player_mt:go_stairs(dx,dy,dz)
  debugmsg("go stairs")
  --检查
  local costtime = 0.7
  self:setPosition(self.x+dx,self.y+dy,self.z+dz)
  local anim = {name = "move",start_x = -64*dx,start_y = -64*dy,totalTime = costtime,pastTime = -self.delay}
  if dx~=0 then anim.start_y = anim.start_y-20*dz else anim.start_y = anim.start_y-20*dz end
  if dz>0 then anim.scissor = {0,64,64,85}end
  self.face =  face_table[(dy+1)*3 +dx+2]
  self.anim = anim
  self:addDelay(costtime)
  g.cameraLock.cameraSet(self.x,self.y,self.z)
end




