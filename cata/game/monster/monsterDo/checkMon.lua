local gmon = g.monster
local monster_mt = gmon.monster_mt

function monster_mt:is_monster()
  return true
end

function monster_mt:has_flag(flagname)
  return self.type.flags[flagname]==true
end

function monster_mt:get_speed()
  return math.max((1+self.bonus.speed_percent/100)*(self.base.speed + self.bonus.speed),1)-- 速度最小为1，不能为0或负数
end

function monster_mt:get_size()
  return self.type.size
end

function monster_mt:get_max_hp()
  return math.max(self.type.hp+self.base.bonus_hp+self.bonus.bonus_hp,1)--最大血量不能小于1吧。
end

function monster_mt:made_of(material)
  return self.type.material == material
end

--重载
function monster_mt:is_immune_effect(eff)
  --是否存在blockeffect
  for _,eff_ins in pairs(self.effects) do
    local blocks = eff_ins.type.blocks_effects
    if blocks then
      for _,v in ipairs(blocks) do
        if v==eff_id then return true end --被阻挡
      end
    end
  end --还需检测flag提供的免疫效果
  return false
end
function monster_mt:bash_skill()
  local ret = self.type.melee_dice * self.type.melee_dice_sides --攻击最大值
  if self:has_flag("MF_BORES") then ret=ret*15 elseif self:has_flag("MF_DESTROYS") then ret=ret*2.5 end --加成
  return ret
end

function monster_mt:stability_roll()
  local stability = 0
  if self.type.size ==1 then
    stability = -7
  elseif self.type.size ==2 then
    stability = -3
  elseif self.type.size ==4 then
    stability = 5
  elseif self.type.size ==5 then
    stability = 10
  end
  stability = stability+dice( self.type.melee_dice, self.type.melee_dice_sides)
  if self:has_effect("stunned") then
    stability = stability- rnd(1,5)
  end
  return stability
  
end
