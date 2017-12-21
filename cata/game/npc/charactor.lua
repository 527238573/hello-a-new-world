
local charactorBase = {}
local cr = g.creature
g.creature.charactorBase = charactorBase

require "game/npc/charactorDo/checkCh"
require "game/npc/charactorDo/effectCh"
require "game/npc/charactorDo/equipmentCh"
require "game/npc/charactorDo/fightCh"
require "game/npc/charactorDo/rangedCh"

--将子类型的metatable 加入函数
function cr.initCharactorMetaTable(mt)
  cr.initCreatureMetaTable(mt)--父类
  for k,v in pairs(charactorBase) do
    mt[k] =v
  end
end
--创建 实例的成员变量
function cr.initCharatorValue(t)
  cr.initCreatureValue(t)
  for k,v in pairs(cr.default_charactor_base_table) do --额外加成的table
    t.base[k] = v
    t.bonus[k] = 0
  end
  
  
  --[[
  bodypart:
  1= head
  2 = torso
  3 = arm_l
  4 = arm_r
  5 = leg_l
  6 = leg_r
  --]]
  
  
  
  t.hp_part = {bp_head = 100,bp_torso =100,bp_arm_l = 100,bp_arm_r = 100,bp_leg_l = 100,bp_leg_r =100} --使用id标识身体部位，增加部位不考虑  
  --最大HP用get_max_hp(body_part)获取，不同部位不一样
  
  t.skills = g.skill.createSkills(t)
  t.inventory = g.createInventory()
  
  t.worn = {} -- 装备列表，会根据位置排序
  t.weapon = nil --武器
  t.traits = {} --特征，只有charactor才有
  
  
  t.dodge_left = 1 --只有charactor才有的属性，剩余闪避数。 阻止短时间连续闪避
  t.burst_shot = 0--连射数，暂且放在这里
  
end

--之后就是charactor类的成员函数了
function charactorBase:set_full_hp()
  for body_part,_ in pairs(self.hp_part) do
    self.hp_part[body_part] = self:get_max_hp(body_part)
  end
end



function charactorBase:is_dead_state()
  return self.hp_part.bp_torso<=0 or self.hp_part.bp_head<=0
end

function charactorBase:die(killer)
  if self.dead then return end --只能死一次
  self.dead = true
  self:set_killer(killer)
  
  --撤出unitcache
  g.map.leaveUnitCache(self)
  --添加死亡特效到effectcache
  if g.map.isUnitInbounds(self) then 
    g.animManager.addSquareEffect("green_red",self.x,self.y,self.z)--暂为默认红爆
  end
  --还有其他
end


