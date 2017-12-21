local damage_mt = {}
damage_mt.__index = damage_mt

function g.create_damage_instance()
  local dam_ins= {}
  setmetatable(dam_ins,damage_mt)
  return dam_ins
end

--类型，伤害数值， 固定穿甲，  （百分比）穿透系数， 
function damage_mt:add_damage(dtype,amount,resist_pen,resist_mul,dam_mul)
  resist_pen = resist_pen or 0
  resist_mul = resist_mul or 1
  dam_mul = dam_mul or 1
  local dam_t = {type = dtype,amount = amount,res_pen = resist_pen,res_mult = resist_mul,dam_mul = dam_mul}
  table.insert(self,dam_t)
end

--没有系数修正
function damage_mt:total_dam()
  local total = 0
  for i=1,#self do total= total+self[i].amount end
  return total
end
