
local gmon = g.monster
local monster_mt = {}
g.creature.initCreatureMetaTable(monster_mt)
gmon.monster_mt = monster_mt
monster_mt.__index = monster_mt

function gmon.createMonsterByid(id)
  local montype = data.monsterType[id]
  if montype==nil then
    debugmsg("create monster wrong id:"..id);return nil
  end
  local mon = {}
  g.creature.initCreatureValue(mon)--继承的初始化
  setmetatable(mon,monster_mt)
  mon.face =1 -- 还有xyz坐标，基本位置信息 
  mon.type = montype --类型连接
  mon.hp = montype.hp -- 血量
  mon.base.speed = montype.speed --登记速度
  mon.base.dodge = montype.dodge --登记闪避（方便相关buff百分比变化）
  --mon.base.max_hp = montype.hp --  ,不登记 ，额外血量
  mon.dead = false --是否已死标记  重复
  mon.animList = data.animation[montype.anim_id]
  
  if mon.animList ==nil then debugmsg("error no animlist monster:id:"..id)end
  mon.delay = rnd()/2--最多0.5秒的僵直
  
  mon.inventory = g.createInventory()--mon也有inventory，一般没东西，死了会全掉
  return mon
end

require "game/monster/monsterDo/checkMon"
require "game/monster/monsterDo/moveMon"
require "game/monster/monsterDo/fightMon"

--显示名字，可能根据个体会变，先这样
function monster_mt:getName()
  return self.type.name
end

function monster_mt:getAnimList()
  return self.animList
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

function monster_mt:updateRL(dt)
  if self.dead then return end
  if self:is_dead_state() then
    self:die(nil) --自死亡 
    return
  end
  self:update_effects(dt)
  self:update_damage(dt)
  if dt>self.delay then
    self:planAndMove()
  end
  
  self.delay = self.delay -dt
  if self.delay <0 then self.delay  = 0 end
  
end



function monster_mt:is_dead_state()
  return self.hp<=0
end

--死亡
function monster_mt:die(killer)
  if self.dead then return end --只能死一次
  self.dead = true
  self:set_killer(killer)
  
  --撤出unitcache
  --monster列表则在循环中自动删除死亡的单位
  g.map.leaveUnitCache(self)
  --添加死亡特效到effectcache
  if g.map.isUnitInbounds(self) then 
    g.animManager.addSquareEffect("green_dead",self.x,self.y,self.z)--暂为默认绿爆
  end
  --todo:致死伤害太高会爆炸，hp的负值
  --一般掉落
  self.inventory:dropAll(self.x,self.y,self.z)
  
  --特殊陷阱effect 掉落
  --所持物掉落（非幻觉）
  
  --负罪，蜂后，击杀计数记忆等（非幻觉）
  --如果是幻觉，执行deathfunction 的 disappear 然后return
  --//Not a hallucination, go process the death effects.
  --调用deathfunction，灵活分配给monster  type的函数
  gmon.mondeath.normal(self)--暂时嗲用
  
  --// If our species fears seeing one of our own die, process that
  --士气的影响
end

