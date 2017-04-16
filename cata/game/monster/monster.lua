
local gmon = g.monster
local monster_mt = {}
gmon.monster_mt = monster_mt
monster_mt.__index = monster_mt

require "game/monster/monMove"

function monster_mt:getAnimList()
  return self.animList
end

function monster_mt:has_flag(flagname)
  return self.type.flag[flagname]==true
end

function monster_mt:getSpeed()
  return self.type.speed
end

function monster_mt:addDelay(costTime)
  self.delay = self.delay+costTime
end

function monster_mt:setPosition(x,y,z)
  if x==self.x and y==self.y and z==self.z then return end
  g.map.leaveUnitCache(self)
  self.x = x
  self.y = y
  self.z = z
  g.map.enterUnitCache(self)
end

function monster_mt:setAnimation(anim)
  anim.pastTime = -self.delay
  self.anim = anim
end

function monster_mt:updateRL(dt)
  if dt>self.delay then
    self:planAndMove()
  end
  
  self.delay = self.delay -dt
  if self.delay <0 then self.delay  = 0 end
  
end

function monster_mt:updateAnim(dt)
  local anim = self.anim
  if anim then
    anim.pastTime = anim.pastTime+dt
    if anim.pastTime> anim.totalTime then
      --anim.pastTime = anim.pastTime - anim.totalTime
      self.anim = nil --直接删除
    end
  end
  
end



function gmon.createMonsterByid(id)
  local montype = data.monsterType[id]
  if montype==nil then
    debugmsg("create monster wrong id:"..id);return nil
  end
  local mon = {}
  setmetatable(mon,monster_mt)
  mon.face =1 -- 还有xyz坐标，基本位置信息 
  mon.type = montype --类型连接
  mon.hp = montype.hp -- 血量
  mon.dead = false --是否已死标记
  mon.animList = data.animation[montype.anim_id]
  if mon.animList ==nil then debugmsg("error no animlist monster:id:"..id)end
  
  mon.delay = rnd()/2--最多0.5秒的僵直
  
  return mon
end


