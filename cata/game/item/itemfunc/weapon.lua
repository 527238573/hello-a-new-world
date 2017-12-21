local item_mt = g.itemFactory.item_mt

--推荐武器，其实所有物品都能当武器拿

function item_mt:is_weapon()
  local stype = self.type
  local is_melee = stype.melee_dam>0 or stype.melee_cut>0 or stype.melee_stab>0 
  
  return stype.item_type == "gun" or is_melee --远程或近战
end

function item_mt:get_weapon_appearance()
  return self.type.weapon_appreance
end

function item_mt:get_weapon_hit_bonus()
  return self.type.m_to_hit --命中加成或减成
end

function item_mt:damage_bash() --这些数值会受到武器损毁减成
  return self.type.melee_dam
end

function item_mt:damage_cut()
  return self.type.melee_cut
end

function item_mt:damage_stab()
  return self.type.melee_stab
end
--是否能发动各种攻击的一种，
function item_mt:is_bashing_weapon()
  
  return self.type.melee_dam>=8
end
function item_mt:is_cutting_weapon()
  
  return self.type.melee_cut>=8
end
function item_mt:is_stabbing_weapon()
  
  return self.type.melee_stab>=8
end

--攻击消耗行动点数（参考值）
function item_mt:attack_movepoint()
  debugmsg("attackspeed weight:"..self:getWeight())
  
  return 65+3*self:getVolume() +self:getWeight()/8
end
