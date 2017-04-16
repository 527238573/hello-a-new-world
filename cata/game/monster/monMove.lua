--一些monster类的成员函数
local gmon = g.monster
local monster_mt = gmon.monster_mt
local gmap= g.map

function monster_mt:attack_at(x,y,z)
  return false
  
end


function monster_mt:bash_at(x,y,z)
  return false
end

function monster_mt:push_to(x,y,z,boost,depth)
  return false
end

function monster_mt:move_to(x,y,z)
  if z~=self.z then return end--暂不支持上下楼
  
  local dest_movecost = gmap.square_movecost(x,y,z)
  if dest_movecost<=0 then return false end --不能移动，不可移动的地点
  local destunit = gmap.getUnitInGridWithCheck(x,y,z)
  if destunit then return false end --有单位占据，不能移动
  
  local costtime  = dest_movecost/c.timeSpeed 
  costtime = (x~=self.x and y~=self.y) and costtime*1.4 or costtime 
  costtime = costtime/self:getSpeed()
  
  local dx = x - self.x;
  local dy = y - self.y;
  self:setPosition(x,y,z)
  --动画效果
  self:setAnimation({name = "move",start_x = -64*dx,start_y = -64*dy,totalTime = costtime})
  self:addDelay(costtime)
  self.face =  c.face_table[(dy+1)*3 +dx+2] 
end
  

  
function monster_mt:planAndMove()
  debugmsg("plan and move")
  --self:addDelay(1)
  self:stumbe()
end





function monster_mt:stumbe()
  local can_moveList = {}
  
  for dx =-1,1 do
    for dy = -1,1 do
      local nx = self.x+dx
      local ny = self.y+dy
      local z = self.z
      local dest_movecost = gmap.square_movecost(nx,ny,z)
      local destunit = gmap.getUnitInGridWithCheck(nx,ny,z)
      if dest_movecost>0 and destunit==nil then
        can_moveList[#can_moveList+1] = {nx,ny,z}
      end
    end
  end
  if #can_moveList==0 then return end
  local moveTo = can_moveList[rnd(#can_moveList)]
  self:move_to(moveTo[1],moveTo[2],moveTo[3])
  
end




